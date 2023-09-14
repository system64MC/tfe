import std/[times, os, tables, sets, options, strutils]
import ./actors/implementations/player
import ./actors/bulletList
import common/[vectors, message, events, constants, credentials, hitbox, commonActors]
import room/[room, roomImplementation]
import netty
import flatty
import gameInfos
import ./actors/actors
import database/orm/models
import database/db
import hub/[hub, hubImplementation]
import crypto
import database/orm/models

type
    GameInstance* = ref object
        infos*: GameInfos
        server*: Reactor
        game*: GameORM
        master*: PlayerORM
        players*: array[4, PlayerORM]
        connectionsToVerify: HashSet[Address]

var chan*: Channel[string]
chan.open()

# proc createInstanceToDatabase(game: GameInstance) =
#     game.game.state = HAS_STARTED
#     for i in 0..<4:
#         let playerHub = game.infos.hub.playerList[i]
#         let playerDb = game.players[i]
#         if(playerHub == nil or playerDb == nil): continue
#         playerDb.character = playerHub.character
#         playerDb.game = game.game

#     insertPlayers(game.players, game.game)

proc findPlayerIndexByName(instance: GameInstance, name: string): int =
    for i in 0..<instance.players.len:
        let p = instance.players[i]
        if(p == nil): continue
        if(p.user.pseudo == name): return i
    return -1

proc saveGameGameOver(instance: GameInstance) =
    var game = instance.game
    game.state = GAME_OVER
    var fScore = 0
    var playerSeq = newSeq[PlayerORM](0)
    for p in instance.infos.loadedRoom.playerList:
        if(p == nil): continue
        fScore += p.score.int
        var playerO = instance.players[instance.findPlayerIndexByName(p.name)]
        playerO.score = p.score.int
        playerO.lifes = p.lifes
        playerO.powerup = p.powerUp.uint8
        playerO.bombs = p.bombs
        playerO.character = p.character
        playerSeq.add(playerO)
    echo fScore
    game.totalScore = fScore
    var gameSeq = @[game]
    playerSeq.save()
    gameSeq.save()
    echo "game saved!"

proc saveGameFinished(instance: GameInstance) =
    var game = instance.game
    game.state = HAS_FINISHED
    var fScore = 0
    var playerSeq = newSeq[PlayerORM](0)
    for p in instance.infos.loadedRoom.playerList:
        if(p == nil): continue
        fScore += p.score.int
        var playerO = instance.players[instance.findPlayerIndexByName(p.name)]
        playerO.score = p.score.int
        playerO.lifes = p.lifes
        playerO.powerup = p.powerUp.uint8
        playerO.bombs = p.bombs
        playerO.character = p.character
        playerSeq.add(playerO)
    echo fScore
    game.totalScore = fScore
    var gameSeq = @[game]
    playerSeq.save()
    gameSeq.save()
    echo "game saved!"

proc saveGameLevel(instance: GameInstance) =
    var game = instance.game
    game.state = HAS_STARTED
    game.level.inc
    var playerSeq = newSeq[PlayerORM](0)
    for p in instance.infos.loadedRoom.playerList:
        if(p == nil): continue
        var playerO = instance.players[instance.findPlayerIndexByName(p.name)]
        playerO.score = p.score.int
        playerO.lifes = p.lifes
        playerO.powerup = p.powerUp.uint8
        playerO.bombs = p.bombs
        playerO.character = p.character
        playerSeq.add(playerO)
    var gameSeq = @[game]
    playerSeq.save()
    gameSeq.save()
    echo "game saved!"

proc hasFreeSlots(pList: array[4, Player]): int =
    for i in 0..<pList.len:
        let p = pList[i]
        if(p == nil): return i
    return -1

proc isInGame(name: string, pList: array[4, Player]): (bool, int) =
    for i in 0..<pList.len:
        let p = pList[i]
        if(p == nil): continue
        if(name == p.name): return (true, i)
    return (false, -1)

proc notifyLoadLevel(game: GameInstance, c: Connection) =
    game.server.send(c, toFlatty(message.Message(header: EVENT_LOAD_LEVEL, data: toFlatty(EventLevelLoad(
        level: game.game.level, 
        tileData: game.infos.loadedRoom.destroyableTilesList, 
        switchState: game.infos.loadedRoom.switchOn)))))

proc `==`(a, b: Port): bool {.borrow.}
proc authenticateLevel(instance: GameInstance, msg: netty.Message): bool {.gcsafe.} =
    let mess = fromFlatty(msg.data, message.Message)
    if(instance.connectionsToVerify.contains(msg.conn.address)):
        if(mess.header != ENCRYPTED_CREDENTIALS_DATA or mess.data == ""):
            instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
            instance.connectionsToVerify.excl(msg.conn.address)
            # instance.server.kick(msg.conn)
            echo "Connection not OK 1"
            return false
        else:
            let credentials = fromFlatty(mess.data, CredentialsEncrypted)
            let user = getUserByNameAndPassword($(credentials.name.cstring), $(decrypt(credentials.password).cstring))

            if user.isNone:
                instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
                instance.connectionsToVerify.excl(msg.conn.address)
                # instance.server.kick(msg.conn)
                echo "Connection not OK 2"
                return false

            let (inGame, index) = isInGame(user.get.pseudo, instance.infos.loadedRoom.playerList)
            if(not inGame):
                instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_STARTED, data: "")))
                instance.connectionsToVerify.excl(msg.conn.address)
                return false
            
            if(instance.infos.loadedRoom.playerList[index].address.isSome):
                instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_ALREADY_CONNECTED, data: "")))
                instance.connectionsToVerify.excl(msg.conn.address)
                return false
            instance.infos.loadedRoom.playerList[index].address = some(msg.conn.address)
        
            instance.notifyLoadLevel(msg.conn)
            # instance.server.send(msg.conn, toFlatty(message.Message(header: OK_JOIN_LEVEL, data: $instance.game.level)))
            instance.connectionsToVerify.excl(msg.conn.address)
        echo "Connection OK"
    return true

proc authenticateHub(instance: GameInstance, msg: netty.Message): bool {.gcsafe.} =
    let mess = fromFlatty(msg.data, message.Message)
    echo "address : ", msg.conn.address
    if(instance.connectionsToVerify.contains(msg.conn.address)):
        let slot = instance.infos.hub.playerList.hasFreeSlots()
        if slot < 0:
            instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_FULL, data: "")))
            instance.connectionsToVerify.excl(msg.conn.address)
            return false
        echo "header : ", mess.header
        echo "Checking connection"
        if(mess.header != ENCRYPTED_CREDENTIALS_DATA or mess.data == ""):
            instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
            instance.connectionsToVerify.excl(msg.conn.address)
            # instance.server.kick(msg.conn)
            echo "Connection not OK 1"
            return false
        else:
            let credentials = fromFlatty(mess.data, CredentialsEncrypted)
            let user = getUserByNameAndPassword($(credentials.name.cstring), $(decrypt(credentials.password).cstring))

            if user.isNone:
                instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
                instance.connectionsToVerify.excl(msg.conn.address)
                # instance.server.kick(msg.conn)
                echo "Connection not OK 2"
                return false

            let (inGame, index) = isInGame(user.get.pseudo, instance.infos.hub.playerList)
            if(inGame and instance.infos.hub.playerList[index].address.isSome):
                instance.server.send(msg.conn, toFlatty(message.Message(header: ERROR_ALREADY_CONNECTED, data: "")))
                instance.connectionsToVerify.excl(msg.conn.address)
                return false
        
            if(user.get().pseudo == instance.master.user.pseudo):
                instance.infos.master.address = some(msg.conn.address)
            else:
                instance.infos.hub.playerList[slot] = Player(name: user.get().pseudo, address: some(msg.conn.address))
                instance.players[slot] = newPlayer(user.get(), instance.game)
            instance.server.send(msg.conn, toFlatty(message.Message(header: OK_JOIN_HUB, data: "")))
            instance.connectionsToVerify.excl(msg.conn.address)
        echo "Connection OK"
    return true

proc authenticate(instance: GameInstance, msg: netty.Message): bool {.gcsafe.} =
    if(instance.infos.state == GameState.HUB): return authenticateHub(instance, msg)
    else: return authenticateLevel(instance, msg)
    
proc findPlayerByAddress(playerList: array[4, Player], address: Address): Player =
    for p in playerList:
        if p == nil: continue
        if p.address.isNone: continue
        if p.address.get == address: return p
    return nil

proc createInstanceToDatabase(game: GameInstance) =
    game.game.state = HAS_STARTED
    for i in 0..<4:
        let playerHub = game.infos.hub.playerList[i]
        let playerDb = game.players[i]
        if(playerHub == nil or playerDb == nil): continue
        playerDb.character = playerHub.character
        playerDb.game = game.game

    insertPlayers(game.players, game.game)



proc startGame(game: GameInstance) =
    game.createInstanceToDatabase()
    game.infos.state = WAIT_READY
    game.infos.loadedRoom = Room()
    game.infos.loadedRoom.bulletList = initBulletList()
    # var player = constructPlayer(VectorF64(x: 50, y: 50), 0, 5)
    game.infos.loadedRoom.playerList = game.infos.hub.playerList
    for p in game.infos.loadedRoom.playerList:
        if(p == nil): continue
        p.position = VectorF64(x: 50, y: 50)
        p.hitbox = Hitbox(size: VectorU8(x: 15, y: 23))
        p.state = PLAYER_CONNECTING
    # We load the test room.
    game.infos.loadedRoom.setupMap(game.game.level)

proc fetchMessages*(game: GameInstance) {.gcsafe.} =
    let t = getTime().toUnixFloat()
    for msg in game.server.messages:
        if not game.authenticate(msg): continue
        let data = fromFlatty(msg.data, message.Message)
        
        if(data.header == MessageHeader.EVENT_SELECT_CHAR):
            if(game.infos.state != GameState.HUB): continue
            var p = findPlayerByAddress(game.infos.hub.playerList, msg.conn.address)
            if p != nil: game.infos.hub.assignCharacter(p, data.data.parseInt())
        
        if(data.header == MessageHeader.EVENT_VALIDATE_CHAR):
            if(game.infos.state != GameState.HUB): continue
            var p = findPlayerByAddress(game.infos.hub.playerList, msg.conn.address)
            if p != nil: game.infos.hub.selectCharacter(p)
        
        if(data.header == MessageHeader.EVENT_INPUT):
            if(game.infos.state == GameState.HUB): continue
            let e = fromFlatty(data.data, events.EventInput)
            let p = findPlayerByAddress(game.infos.loadedRoom.playerList, msg.conn.address)
            if(p != nil): p.input = p.input or e.input
            
            let duration = (t - e.sentAt)
            p.deltaTimeAccumulator += duration
            p.deltaTimeHowManyValues.inc

        if(data.header == MessageHeader.PLAYER_READY):
            if(game.infos.state == GameState.HUB): continue
            let p = game.infos.loadedRoom.playerList.findPlayerByAddress(msg.conn.address)
            if(game.infos.state == GameState.WAIT_READY): p.state = PLAYER_READY
            else:
                if(p.lifes > 0):
                    p.state = PLAYER_INVINCIBLE
                    p.timers[7] = 2 * 60
                else:
                    p.state = PLAYER_GAMEOVER
        
        if(data.header == MessageHeader.EVENT_START_GAME):
            if(game.infos.state != GameState.HUB or game.game.state == HAS_STARTED): continue
            if((msg.conn.address == game.infos.master.address.get()) and game.infos.hub.isEveryoneReady()):
                game.startGame()
                for c in game.server.connections:
                    game.notifyLoadLevel(c)

    
    if(game.infos.state == GameState.HUB or game.infos.state == GameState.DEAD_GAME): return
    for p in game.infos.loadedRoom.playerList:
        if(p == nil or p.address.isNone): continue
        if(p.deltaTimeHowManyValues >= 64):
            let avg = p.deltaTimeAccumulator / p.deltaTimeHowManyValues.float
            p.deltaTime = clamp(avg, MINIMAL_LATENCY, MAX_LATENCY)
            p.deltaTimeAccumulator = 0
            p.deltaTimeHowManyValues = 0

proc isEveryoneGameOver(game: GameInstance): bool =
    for p in game.infos.loadedRoom.playerList:
        if(p == nil): continue
        if(p.lifes > 0): return false
    return true

proc notifyGameOver(game: GameInstance) =
    for c in game.server.connections:
        game.server.send(c, toFlatty(message.Message(header: EVENT_GAME_OVER, data: $game.game.totalScore)))
    game.server.tick()

proc notifyGameFinished(game: GameInstance) =
    for c in game.server.connections:
        game.server.send(c, toFlatty(message.Message(header: EVENT_GAME_FINISHED, data: $game.game.totalScore)))
    game.server.tick()

proc doGameOverStuff(game: GameInstance) =
    game.saveGameGameOver()
    game.notifyGameOver()

proc doGameFinishedStuff(game: GameInstance) =
    game.saveGameFinished()
    game.notifyGameFinished()

proc doLevelFinishedStuff(game: GameInstance) =
    game.saveGameLevel()
    for p in game.infos.loadedRoom.playerList:
        if(p == nil or p.address.isNone()): continue
        p.state = PLAYER_CONNECTING
    game.infos.state = WAIT_READY
    game.infos.loadedRoom.setupMap(game.game.level)
    echo "level loaded!"
    for c in game.server.connections:
        game.notifyLoadLevel(c)



proc update*(game: GameInstance): void {.gcsafe.} =
    game.infos.eventList.setLen(0)
    case game.infos.state:
    of HUB:
        game.infos.hub.update()
    of LEVEL:
        if(game.isEveryoneGameOver()): game.infos.state = GameState.GAME_OVER
        else: game.infos.loadedRoom.update(game.infos, game.game.level)
    of DEAD_GAME, GAME_OVER, LEVEL_FINISHED, GAME_FINISHED: return
    of WAIT_READY:
        # echo "waiting"
        for p in game.infos.loadedRoom.playerList:
            if(p == nil or p.address.isNone()): continue
            if(p.state == PLAYER_CONNECTING): return
            if(p.lifes > 0):
                p.state = PLAYER_INVINCIBLE
                p.timers[7] = 2 * 60
            else:
                p.state = PLAYER_GAMEOVER
        game.infos.state = GameState.LEVEL
    else:
        game.infos.loadedRoom.update(game.infos, game.game.level)

proc notifyDeadServer*(game: GameInstance) =
    for c in game.server.connections:
        game.server.send(c, toFlatty(message.Message(header: EVENT_SERVER_DEAD, data: "")))
    game.server.tick()

import supersnappy
proc serialize*(game: GameInstance): void {.gcsafe.} =
    if(game.infos.state == DEAD_GAME):
        game.notifyDeadServer()
        return
    if(game.infos.state == GAME_OVER):
        game.doGameOverStuff()
        return
    if(game.infos.state == LEVEL_FINISHED):
        game.doLevelFinishedStuff()
        return
    if(game.infos.state == GAME_FINISHED):
        game.doGameFinishedStuff()
        return
    if(game.infos.state != GameState.HUB):
        let d = compress(game.infos.loadedRoom.serialize())
        let roomData = toFlatty(message.Message(header: MessageHeader.ROOM_DATA, data: d))

        # Sending data to the server.
        for connection in game.server.connections:
            game.server.send(connection, roomData)
    elif(game.infos.state == GameState.HUB):
        let h = compress(game.infos.hub.serialize(game.game.gameCode))
        let hubData = toFlatty(message.Message(header: MessageHeader.HUB_DATA, data: h))
        # Sending data to the server.
        for connection in game.server.connections:
            game.server.send(connection, hubData)

    # Sending events to the server.
    for e in game.infos.eventList:
        let data = e.toFlatty()
        for connection in game.server.connections:
            game.server.send(connection, data)

proc init*(game: GameInstance): void =
    game.infos.eventList = newSeq[message.Message](0)
    # game.infos.loadedRoom = Room()
    # game.infos.loadedRoom.bulletList = initBulletList()
    # var player = constructPlayer(VectorF64(x: 50, y: 50), 0, 5)
    # game.infos.loadedRoom.playerList[0] = player
    # We load the test room.
    # game.infos.loadedRoom.setupMap(0)

    
    echo "Server booted! Listening for 📦 packets! 📦"
    echo "\e[49m                \e[38;2;0;52;32;49m▄▄\e[48;2;0;52;32m \e[38;2;0;110;132;48;2;0;52;32m▄▄▄▄\e[48;2;0;52;32m  \e[38;2;0;52;32;49m▄\e[49m           \e[m\n\e[49m              \e[38;2;0;52;32;49m▄\e[48;2;0;52;32m   \e[38;2;0;110;132;48;2;0;52;32m▄▄▄▄\e[48;2;0;52;32m  \e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m  \e[49m  \e[38;2;0;110;132;49m▄\e[38;2;255;208;180;48;2;0;110;132m▄▄▄▄\e[38;2;0;110;132;49m▄\e[49m  \e[m\n\e[49m             \e[48;2;0;52;32m  \e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;110;132m \e[38;2;0;52;32;48;2;0;110;132m▄▄▄▄▄▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;52;32m \e[38;2;0;52;32;49m▄\e[49;38;2;0;52;32m▀\e[38;2;0;110;132;49m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;255;208;180m    \e[38;2;0;110;132;48;2;255;208;180m▄\e[48;2;255;208;180m \e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;52;32;49m▄\e[m\n\e[49m            \e[48;2;0;52;32m  \e[48;2;0;110;132m \e[38;2;0;52;32;48;2;0;110;132m▄\e[38;2;255;208;180;48;2;0;52;32m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;255;208;180m \e[48;2;0;110;132m \e[48;2;255;208;180m \e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;255;208;180;48;2;0;52;32m▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m  \e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;255;208;180m  \e[38;2;0;110;132;48;2;255;208;180m▄▄\e[48;2;0;110;132m   \e[48;2;255;208;180m \e[48;2;0;52;32m \e[m\n\e[49m           \e[48;2;0;52;32m    \e[38;2;0;110;132;48;2;255;208;180m▄\e[48;2;0;110;132m \e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;0;110;132m \e[38;2;0;110;132;48;2;255;208;180m▄\e[48;2;0;110;132m   \e[38;2;0;110;132;48;2;255;208;180m▄\e[48;2;0;110;132m \e[48;2;0;52;32m  \e[49;38;2;0;52;32m▀\e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;255;208;180m \e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;0;110;132m   \e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[49;38;2;0;52;32m▀\e[m\n\e[49m           \e[48;2;0;52;32m  \e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;255;208;180m \e[48;2;0;110;132m \e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;110;132;48;2;255;208;180m▄\e[48;2;255;208;180m   \e[38;2;0;110;132;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;0;110;132m \e[48;2;255;208;180m \e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;0;52;32m \e[49m  \e[48;2;0;52;32m \e[38;2;0;52;32;48;2;255;208;180m▄▄▄▄\e[49;38;2;0;52;32m▀\e[49m  \e[m\n\e[49m           \e[49;38;2;0;52;32m▀\e[48;2;0;52;32m \e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;110;132m  \e[48;2;255;208;180m \e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;255;208;180m   \e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;255;208;180m \e[48;2;0;110;132m  \e[48;2;0;52;32m \e[49;38;2;0;52;32m▀\e[49m \e[48;2;0;52;32m \e[48;2;255;208;180m \e[48;2;0;52;32m \e[49m      \e[m\n\e[48;2;0;110;132m \e[38;2;255;208;180;48;2;0;110;132m▄▄\e[38;2;0;110;132;49m▄\e[49m        \e[48;2;0;52;32m \e[48;2;0;110;132m    \e[38;2;0;110;132;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;110;132m▄▄▄\e[38;2;0;110;132;48;2;255;208;180m▄\e[48;2;0;110;132m   \e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;0;52;32;49m▄\e[48;2;0;52;32m \e[48;2;255;208;180m \e[48;2;0;52;32m \e[49m       \e[m\n\e[49;38;2;0;110;132m▀\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;52;32m▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;110;132;49m▄\e[49m     \e[38;2;0;52;32;49m▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;110;132m     \e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;52;32m  \e[48;2;0;110;132m     \e[48;2;0;52;32m \e[48;2;255;208;180m \e[48;2;0;52;32m \e[49m        \e[m\n\e[49m  \e[49;38;2;0;52;32m▀\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;52;32m▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;110;132;49m▄\e[49m   \e[48;2;0;52;32m \e[48;2;0;110;132m  \e[38;2;0;52;32;48;2;0;110;132m▄▄\e[38;2;0;110;132;48;2;0;52;32m▄▄▄\e[48;2;0;110;132m  \e[38;2;0;110;132;48;2;0;52;32m▄▄\e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;110;132m \e[38;2;255;208;180;48;2;0;52;32m▄\e[48;2;0;110;132m \e[48;2;0;52;32m \e[49m         \e[m\n\e[49m    \e[49;38;2;0;52;32m▀\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;52;32m▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;110;132;48;2;0;52;32m▄▄▄\e[38;2;0;52;32;48;2;0;110;132m▄\e[38;2;255;208;180;48;2;0;52;32m▄\e[48;2;255;208;180m \e[48;2;0;52;32m \e[38;2;0;52;32;48;2;0;110;132m▄▄▄\e[48;2;0;52;32m \e[38;2;0;52;32;48;2;0;110;132m▄▄▄\e[48;2;0;52;32m \e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;255;208;180m \e[38;2;255;208;180;48;2;0;52;32m▄\e[38;2;0;52;32;49m▄\e[49m        \e[m\n\e[49m    \e[38;2;0;52;32;49m▄▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;255;208;180m \e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;0;52;32m \e[38;2;255;208;180;48;2;0;52;32m▄\e[48;2;255;208;180m \e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;0;52;32m \e[38;2;0;110;132;48;2;255;208;180m▄▄▄▄▄▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;0;52;32m \e[48;2;0;110;132m \e[48;2;0;52;32m \e[38;2;0;52;32;48;2;255;208;180m▄▄\e[48;2;0;52;32m  \e[38;2;0;52;32;49m▄\e[49m      \e[m\n\e[49m  \e[38;2;0;52;32;49m▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;110;132m  \e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m \e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m \e[48;2;255;208;180m  \e[38;2;0;52;32;48;2;255;208;180m▄▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;110;132m   \e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;110;132m  \e[48;2;0;52;32m \e[48;2;255;208;180m \e[48;2;0;52;32m  \e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;255;208;180m \e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;0;52;32m \e[48;2;0;110;132m \e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;0;52;32;49m▄\e[49m    \e[m\n\e[49m \e[49;38;2;0;52;32m▀\e[38;2;0;52;32;48;2;0;110;132m▄▄▄\e[48;2;0;52;32m \e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;52;32m      \e[48;2;0;110;132m   \e[48;2;0;52;32m \e[48;2;0;110;132m  \e[48;2;0;52;32m \e[48;2;255;208;180m \e[48;2;0;52;32m    \e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;52;32m   \e[48;2;0;110;132m  \e[38;2;0;110;132;48;2;0;52;32m▄▄\e[38;2;0;52;32;49m▄\e[49m \e[m\n\e[49m    \e[49;38;2;0;52;32m▀\e[48;2;0;52;32m  \e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m \e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;255;208;180;48;2;0;110;132m▄\e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;52;32m  \e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;110;132m \e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m \e[48;2;0;110;132m  \e[48;2;0;52;32m \e[48;2;255;208;180m \e[48;2;0;52;32m \e[48;2;0;110;132m \e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;52;32m \e[38;2;0;52;32;48;2;0;110;132m▄\e[38;2;0;110;132;48;2;255;208;180m▄\e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m \e[38;2;255;208;180;48;2;0;52;32m▄\e[48;2;255;208;180m \e[38;2;255;208;180;48;2;0;110;132m▄\e[48;2;0;110;132m \e[38;2;0;52;32;48;2;0;110;132m▄▄\e[49;38;2;0;52;32m▀\e[m\n\e[49m       \e[49;38;2;0;52;32m▀▀\e[48;2;0;52;32m \e[38;2;0;52;32;48;2;0;110;132m▄\e[48;2;0;52;32m   \e[48;2;0;110;132m \e[48;2;0;52;32m  \e[38;2;0;110;132;48;2;0;52;32m▄\e[48;2;0;110;132m \e[38;2;0;110;132;48;2;0;52;32m▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[48;2;0;52;32m   \e[48;2;0;110;132m \e[48;2;0;52;32m    \e[38;2;0;52;32;48;2;0;110;132m▄▄\e[38;2;0;52;32;48;2;255;208;180m▄\e[38;2;0;52;32;48;2;0;110;132m▄\e[49;38;2;0;52;32m▀\e[49m   \e[m\n"

proc checkNewDeadConnections(game: GameInstance): void {.gcsafe.} =
    for connection in game.server.newConnections:
        game.connectionsToVerify.incl(connection.address)
        echo game.connectionsToVerify
        # game.server.send(connection, toFlatty(message.Message(header: DESTROYABLE_TILES_DATA, data: toFlatty(game.infos.loadedRoom.destroyableTilesList))))
        # let switchEvent = EventSwitch(state: game.infos.loadedRoom.switchOn)
        # let m = message.Message(header: message.EVENT_SWITCH, data: toFlatty(switchEvent))
        # game.server.send(connection, toFlatty(m))
        echo "[new] ", connection.address
        echo "[SERVER : ]", game.server.address

    for connection in game.server.deadConnections:
        echo "[dead] ", connection.address
        if(game.infos.state == GameState.HUB):
            game.infos.hub.onDisconnect(connection.address, game.infos, game.players)
        else: game.infos.loadedRoom.onDisconnect(connection.address, game.infos)

proc beginTick(game: GameInstance) =
    game.server.tick()
    game.infos.timeStart = cpuTime().float
    game.infos.delta = (game.infos.timeStart - game.infos.timeFinish).float

proc endTick(game: GameInstance) =
    game.infos.timeFinish = cpuTime()
    game.infos.delta = game.infos.timeFinish - game.infos.timeStart
    game.infos.frame.inc
    if(game.infos.delta < TPS_DELAY):
        sleep((TPS_DELAY - game.infos.delta).int)



proc bootGameInstance*() {.thread.} =
    var game = GameInstance()
    # Creating the server, listening on the ELIS port (Port 5173)
    game.server = newReactor("0.0.0.0", 5173)
    game.init()

    # Main game loop
    while true:
        game.beginTick()

        game.checkNewDeadConnections()
        game.fetchMessages()
        game.update()
        game.serialize()

        game.endTick()

proc bootGameInstance2*(game: GameInstance) {.thread.} =
    defer:
        let code = game.game.gameCode
        # game.game = nil
        # game.infos = GameInfos()
        # game.players = [nil, nil, nil, nil]
        # game.server = nil
        # game.master = nil
        chan.send(code)

    game.init()

    # Main game loop
    while game.infos.state notin {DEAD_GAME, GAME_OVER}:
        # echo "begin :", game.infos.state
        game.beginTick()
        # echo "tick start :", game.infos.state
        game.checkNewDeadConnections()
        # echo "check conns :", game.infos.state
        game.fetchMessages()
        # echo "fetchMess :", game.infos.state
        game.update()
        # echo "update :", game.infos.state
        game.serialize()
        # echo "serialize :", game.infos.state
        game.endTick()
        # echo "end :", game.infos.state
    echo "closing server"

proc loadGameInstanceSave*(save: var GameORM, players: var seq[PlayerORM], master: UserORM, port: Port): GameInstance =
    var instance = GameInstance()
    instance.game = save
    # setup players
    var playersGame: array[4, Player]
    for i in 0..<players.len:
        let pOrm = players[i]
        playersGame[i] = Player(
            name: pOrm.user.pseudo,
            address: none(Address),
            lifes: pOrm.lifes,
            state: if(pOrm.lifes == 0): PLAYER_GAMEOVER else: PLAYER_DISCONNETED,
            bombs: pOrm.bombs,
            powerUp: pOrm.powerup.Powerup,
            position: VectorF64(x: 50, y: 50),
            hitbox: Hitbox(size: VectorU8(x: 15, y: 23))
        )
        if(master.pseudo == playersGame[i].name):
            instance.infos.master = playersGame[i]
            instance.master = players[i]
        instance.players[i] = pOrm

    instance.infos.eventList = newSeq[message.Message](0)
    instance.infos.loadedRoom = Room()
    instance.infos.loadedRoom.bulletList = initBulletList()
    instance.infos.loadedRoom.setupMap(save.level)
    instance.infos.loadedRoom.playerList = playersGame
    instance.infos.state = GameState.LEVEL
    instance.server = newReactor("0.0.0.0", port.int)

    return instance
    

proc newGameInstance*(port: Port, master: UserORM, code: string): GameInstance =
    var instance = GameInstance()
    instance.infos.hub = hub.Hub()
    instance.game = newGame(master, code)
    instance.master = newPlayer(master, instance.game)
    instance.players[0] = instance.master
    instance.infos.master = Player()
    instance.infos.master.name = master.pseudo
    instance.infos.hub.playerList[0] = instance.infos.master
    instance.server = newReactor("0.0.0.0", port.int)
    return instance