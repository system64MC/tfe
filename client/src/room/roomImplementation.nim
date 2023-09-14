import room
import tilengine/[tilengine, bitmapUtils]
import common/[constants, serializedObjects, commonActors, vectors, message, credentials]
import background
import ../music/music
import ../game/game
import netty
import ../[drawing, rasterEffects, globals]
import flatty
import tinydialogs
import json
import strformat
import std/[httpclient, asyncdispatch, strutils, marshal]

proc loadLevel*(room: Room, level: int) {.inline.} =
    let json = readFile(fmt"./assets/levels/{level}.json")
    let jNode = parseJson(json)
    let tmxPath = jNode["tilemap"].getStr()
    let musicPath = jNode["music"].getStr()
    room.layers[1] = createBackground(tmxPath, "background")
    Layer(1).setTilemap(room.layers[1].layer)
    if(musicPath != ""): startMusic(musicPath)
    return



proc init*(room: Room, musicPath: string = "", level: int = 0) =
    setRasterCallback(nil)
    # We free the tilemaps to avoid memory leaks...
    # TODO : Temporary disabled because investigating a segfault.
    # for i in 0..<room.layers.len:
    #     try:
    #         if(Layer(i).getTilemap != nil):
    #             Layer(i).disable
    #             Layer(i).getTilemap.delete
    #             room.layers[i].layer = nil
    #     except:
    #         discard

        # if(room.layers[i].layer != nil):
        #     room.layers[i].layer.delete
        #     room.layers[i].layer = nil

    room.data = RoomSerialize(
            camera: Camera(position: VectorF64(x: 0, y: 0)),
            playerList: [PlayerSerialize(), nil, nil, nil]
        )
    if(room.bitmap == nil):
        room.bitmap = createBitmap(SCREEN_X, SCREEN_Y, 8)
        room.bitmap.setPalette(createPalette(16))
        room.bitmap.getPalette().setColor(1, 255, 0, 0)
        room.bitmap.getPalette().setColor(2, 255, 255, 255)
        room.bitmap.getPalette().setColor(3, 0, 255, 0)
        Layer(3).setBitmap(room.bitmap)
        Layer(3).setPriority(true)
    for i in 0..<512:
        Sprite(i).disable
    Layer(0).disable
    case room.kind:
    of ROOM_TITLE:
        Sprite(0).setSpriteSet(sprites[SpriteTypes.CURSOR.int])
        room.layers[2] = createBackground("./assets/tilemaps/floor.tmx")
        room.layers[1] = createBackground("./assets/tilemaps/titlescreen.tmx")
        Layer(2).setTilemap(room.layers[2].layer)
        Layer(1).setTilemap(room.layers[1].layer)
        setRasterCallback(titleScreenRasterEffect)
        room.cursor.position = 0
    of ROOM_LEVEL:
        Layer(2).disableAffineTransform()
        Layer(1).setBlendMode(BlendNone, 255)
        # Sprite(1).setSpriteSet(sprites[SpriteTypes.PLAYER.int])
        # room.layers[1] = createBackground("./assets/tilemaps/testRoom.tmx", "background")
        # Layer(1).setTilemap(room.layers[1].layer)
        # room.loadLevel(level)
        let json = readFile(fmt"./assets/levels/{level}.json")
        let jNode = parseJson(json)
        let tmxPath = jNode["tilemap"].getStr()
        let tmxPath2 = jNode["background"].getStr()
        let musicPath = jNode["music"].getStr()
        # room.layers[1] = createBackground(tmxPath, "background")
        # Layer(2).disable()
        room.layers[1] = createBackground(tmxPath, "background")
        room.layers[2] = createBackground(tmxPath2, "background")
        Layer(1).setTilemap(room.layers[1].layer)
        Layer(2).setTilemap(room.layers[2].layer)
        if(musicPath != ""): startMusic(musicPath)

        let scrollTab = jNode["scrollTable"].getElems()
        var idx = 0
        for item in scrollTab:
            scrollTable[idx] = item.getFloat()
            idx.inc

        setRasterCallback(levelRasterEffect)
        Layer(0).setTilemap(hud)
        Layer(0).enable

    of ROOM_HUB:
        room.layers[1] = createBackground("./assets/tilemaps/charSelect.tmx", "frames")
        room.layers[2] = createBackground("./assets/tilemaps/charSelect.tmx", "circle")
        Layer(1).setTilemap(room.layers[1].layer)
        Layer(2).setTilemap(room.layers[2].layer)
        setRasterCallback(selectScreenRasterEffect)
        room.cursor.position = -1
        Sprite(0).setSpriteSet(sprites[SpriteTypes.CHARACTERS.int])
        Sprite(1).setSpriteSet(sprites[SpriteTypes.CHARACTERS.int])
        Sprite(2).setSpriteSet(sprites[SpriteTypes.CHARACTERS.int])
        Sprite(3).setSpriteSet(sprites[SpriteTypes.CHARACTERS.int])
    of ROOM_GAMEOVER:
        Layer(0).disable
        Layer(2).disable
        Layer(1).setTilemap(gameOver)
    of ROOM_FINISHED:
        Layer(0).disable
        Layer(2).disable
        Layer(1).setTilemap(gameFinish)
    of ROOM_SCORE:
        room.scoreList.setLen(0)
        proc getScores(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
            var a = await client.get(fmt"http://{serverAddressGlobal}:5000/top")
            return a

        Layer(2).disable
        room.layers[1] = createBackground("./assets/tilemaps/scores.tmx", "background")
        Layer(1).setTilemap(room.layers[1].layer)

        var f = httpClientGlobal.getScores()
        asyncfutures.addCallback(f,
            proc (f: Future[AsyncResponse]) {.closure, gcsafe.} =
                try:
                    var res = f.read()
                    {.cast(gcsafe).}:
                        if(res.status.startsWith("409")):
                            echo "error"
                        room.scoreList = to[seq[GameScoreSerialize]](res.body.read)
                        # echo res.body.read()
                        # room.kind = ROOM_SCORE
                except:
                    echo "error"
        )

    else:
        discard
    if(musicPath != ""): startMusic(musicPath)
    return

proc updateTitleScreen(room: Room, game: Game) =
    room.cursor.timer.dec
    room.validateCounter.dec
    if(room.cursor.timer <= 0):
        if(getInput(InputDown)):
            room.cursor.position = min(room.cursor.position + 1, EXIT.int)
            room.cursor.timer = 8
        if(getInput(InputUp)):
            room.cursor.position = max(room.cursor.position - 1, JOIN_GAME.int)
            room.cursor.timer = 8
    if(getInput(InputStart)):
        if(room.validateCounter > 0): return
        case room.cursor.position.TitleChoices:
        of JOIN_GAME:
            if(room.state == WAITING_HUB_TRANSFER): return
            let code = inputBox("Join a game", "Please enter game code", "")
            room.state = WAITING_HUB_TRANSFER
            game.connection = game.client.connect(serverAddressGlobal, 51730)
            game.client.send(game.connection, toFlatty(message.Message(header: MessageHeader.ENCRYPTED_CREDENTIALS_WITH_CODE, data: toFlatty(CredentialsEncWithCode(gameCode: code, credentials: game.credentials)))))
            # game.room.kind = ROOM_LEVEL
            # game.room.init("./assets/musics/goddess.kt")
            # game.connection = game.client.connect("127.0.0.1", 5173)
            echo "Join game..."
        of CREATE_GAME:
            if(room.state == WAITING_HUB_TRANSFER): return
            echo "Create new game..."
            room.state = WAITING_HUB_TRANSFER
            game.connection = game.client.connect(serverAddressGlobal, 51730)
            game.client.send(game.connection, toFlatty(message.Message(header: MessageHeader.ENCRYPTED_CREDENTIALS_DATA, data: toFlatty(game.credentials))))
            # game.room.kind = ROOM_HUB
            # game.room.init("./assets/musics/select.kt")
        of SCORES:
            room.kind = ROOM_SCORE
            room.init("./assets/musics/select.kt")
            return
            echo "Scores list..."
        of MUSIC_ROOM:
            echo "Open music room"
        of EXIT:
            quit()
    return

proc updateLevel(room: Room) =
    return

proc updateMusicRoom(room: Room) =
    return

proc isCharacterAvaillable(selectCharacter: int8, myName: string, playerList: array[4, PlayerSerialize]): bool =
    for p in playerList:
        if(p == nil): continue
        if(p.name == myName):
            continue
        if(p.state == PlayerState.CHAR_SELECTED and selectCharacter == p.character): return false

    return true


proc updateHub(room: Room, game: Game) =
    room.cursor.timer.dec
    if(room.cursor.timer <= 0):
        if(room.state != CHARACTER_SELECTED):
            if(getInput(InputRight)):
                room.cursor.position = (room.cursor.position + 1) and 0b11
                room.cursor.timer = 8
                game.client.send(game.connection, toFlatty(message.Message(header: MessageHeader.EVENT_SELECT_CHAR, data: $room.cursor.position)))
            if(getInput(InputLeft)):
                room.cursor.position = (room.cursor.position.int8 - 1) and 0b11
                room.cursor.timer = 8
                game.client.send(game.connection, toFlatty(message.Message(header: MessageHeader.EVENT_SELECT_CHAR, data: $room.cursor.position)))
            if(getInput(InputButton1) and room.cursor.position >= 0):
                if(isCharacterAvaillable(room.cursor.position.int8, game.credentials.name, room.hubData.playerList)):
                    room.state = CHARACTER_SELECTED
                    game.client.send(game.connection, toFlatty(message.Message(header: MessageHeader.EVENT_VALIDATE_CHAR, data: $room.cursor.position)))
                    echo "character selected"

        if(getInput(InputStart)):
            game.client.send(game.connection, toFlatty(message.Message(header: MessageHeader.EVENT_START_GAME, data: "")))
    return

proc updateScoreScreen(room: Room) =
    drain(16)
    if(getInput(InputButton2)):
        room.kind = ROOM_TITLE
        room.init("./assets/musics/magica.kt")
    return

proc updateGameOver(room: Room) =
    if(getInput(InputStart)):
        room.kind = ROOM_TITLE
        room.validateCounter = 8
        room.init("./assets/musics/magica.kt")

proc update*(room: Room, game: Game) =
    case room.kind:
    of ROOM_TITLE:
        room.updateTitleScreen(game)
    of ROOM_HUB:
        room.updateHub(game)
    of ROOM_GAMEOVER, ROOM_FINISHED:
        room.updateGameOver()
    of ROOM_SCORE:
        room.updateScoreScreen()
    else:
        discard
    return

# TODO : This part needs to be optimized. Is it possible to use animations instead?
# Maybe I should contact Tilengine's developer to know if there is an easy way to take
# advantage of animations.
proc switchTiles(room: Room, switchOn: bool) =
  let map = room.layers[1].layer
  for j in 0..<map.getRows:
    for i in 0..<map.getCols:
      var tile = map.getTile(j, i)
      if(tile.index > 1 and tile.index < 8):
        if(switchOn):
          if tile.index == 3: tile.index = 2
          if tile.index == 5: tile.index = 4
          if tile.index == 6: tile.index = 7
          map.setTile(j, i, tile)
          continue
        if tile.index == 2: tile.index = 3
        if tile.index == 4: tile.index = 5
        if tile.index == 7: tile.index = 6
        map.setTile(j, i, tile)
    room.needSwitching = false


proc drawTitleScreen(room: Room) =
    Sprite(0).setPosition(80, 48 + (16 * room.cursor.position))
    Layer(1).setBlendMode(BlendNone, 255)
    return

import std/strformat
proc countBullets(room: Room) =
    var c = 0
    for b in room.data.bulletList:
        if(b != nil): c.inc
    echo c

proc isSomeoneBombing(room: Room): bool =
    for p in room.data.playerList:
        if(p == nil): continue
        if(p.bombTimer > 0): return true
    return false

proc drawLevel(room: Room, game: Game) =
    for i in 0..511:
        Sprite(i).disable()
    
    if(room.isSomeoneBombing()): Layer(3).setBlendMode(BlendAdd, 255'u8) 
    else: Layer(3).setBlendMode(BlendNone, 255'u8)
    # Layer(2).disable
    camPos = room.data.camera.position
    Layer(1).setPosition(room.data.camera.position.x.int, room.data.camera.position.y.int)
    if room.needSwitching: room.switchTiles(room.switchState)
    # Draw players
    for p in room.data.playerList:
        if(p == nil): continue
        if(p.bombTimer > 0): p.drawBombing(room.bitmap)
        if(p.name == game.credentials.name):
            p.drawHud()
        if(p.lifes > 0): p.draw(room.bitmap)

    # Draw bonuses
    for b in room.data.bonusList:
        if(b == nil): continue
        let spr = getAvailableSprite()
        Sprite(spr).setSpriteSet(sprites[3])
        Sprite(spr).setPicture(b.bType.int)
        Sprite(spr).setPosition(b.position.x.int, b.position.y.int)
        # Sprite(spr).setPosition(50, 50)

    
    # Draw actors
    for e in room.data.enemyList:
        if(e == nil or e.state notin {GO_IN, SHOOTING, SHOOTED, GO_OUT, DYING}): continue
        # if(e.position.x < 0 or e.position.x >= SCREEN_X - e.hitbox.size.x.float): continue
        e.draw(room.bitmap, room.data.camera.position.x)

    # Draw boss
    if(room.data.boss != nil and room.data.boss.state in {GO_IN, SHOOTING, SHOOTED, GO_OUT, DYING}):
        room.data.boss.draw(room.bitmap, room.data.camera.position.x)

    # Draw boss lifes
    if(room.data.isBoss):
        room.bitmap.drawText(Point(x: 64, y: 130), fmt"boss : {room.data.boss.lifePoints}/{room.data.boss.totalLifePoints}", 1)

    # Draw bullets
    for b in room.data.bulletList:
        if(b != nil): 
            b.draw(room.bitmap)

proc drawMusicRoom(room: Room) =
    return

const names = @[
    "",
    "Ombrage Magica",
    "System64",
    "Elis Bloodthorns",
    "PlaceHolder"
]

proc drawHubCharacters(room: Room, game: Game) =
    var count = 0
    for i in 0..<room.hubData.playerList.len:
        let p = room.hubData.playerList[i]
        if p == nil:
            Sprite(i).setPosition(count * 80 + 24, 24)
            Sprite(i).setPicture(0)
            count.inc
            continue
        let color: uint8 = if(isCharacterAvaillable(room.cursor.position.int8, game.credentials.name, room.hubData.playerList)): 2 else: 1
        let colReady: uint8 = if(p.state == CHAR_SELECTED): 3 else: 1
        if p.name == game.credentials.name:
            Sprite(i).setPosition(104, 88)
            room.bitmap.drawText(Point(x: 128 - (names[p.character + 1].len shr 1) * 4, y: 128), names[p.character + 1], color)
            room.bitmap.drawText(Point(x: 128 - (p.name.len shr 1) * 4, y: 128 + 8), p.name, colReady)
        else:
            Sprite(i).setPosition(count * 80 + 24, 24)
            room.bitmap.drawText(Point(x: count * 80 + 48 - (names[p.character + 1].len shr 1) * 4, y: 64), names[p.character + 1],2)
            room.bitmap.drawText(Point(x: count * 80 + 48 - (p.name.len shr 1) * 4, y: 64 + 8), p.name, colReady)
            count.inc
        Sprite(i).setPicture(p.character.int + 1)

proc drawCode(room: Room) =
    room.bitmap.drawText(Point(x: 16, y: 6 * 16), "Game code :", 2)
    room.bitmap.drawText(Point(x: 16, y: 6 * 16 + 8), room.hubData.code, 2)
    
proc drawHub(room: Room, game: Game) =
    setBgColor(0, 0, 0)
    Layer(2).setPosition(256 - (SCREEN_X shr 1), 256 - (SCREEN_Y shr 1))
    Layer(2).setTransform(frame.float / 2, SCREEN_X / 2, SCREEN_Y / 2, 0.5, 0.5)
    Layer(1).setBlendMode(BlendSub, 255)
    drawHubCharacters(room, game)
    drawCode(room)
    return

proc drawScoreScreen(room: Room) =
    const fetchStr = "Fetching scores..."
    if(room.scoreList.len == 0):
        var i = 0
        for c in fetchStr:
            Layer(1).getTilemap().getTiles(5, 0)[i].index = (c.uint16 + 1)
            i.inc
        return
    else:
        for i in 0..<fetchStr.len:
            Layer(1).getTilemap().getTiles(5, 0)[i].index = (1)
        
        var idx = 0
        for s in room.scoreList:
            let creator = s.creator.alignLeft(16, '.')
            let score = ($s.score).align(9, '0')
            var i = 0
            for c in creator:
                Layer(1).getTilemap().getTiles(7 + idx, 4)[i].index = (c.uint16 + 1)
                i.inc
            i = 0
            for c in score:
                Layer(1).getTilemap().getTiles(7 + idx, 22)[i].index = (c.uint16 + 1)
                i.inc
            idx.inc
        

import strutils
proc drawGameOver(room: Room) =
    Layer(1).setPosition(0, 0)
    let str = ($room.finalScore).align(9, '0')
    var i = 0
    for c in str:
        gameOver.getTiles(5, 4)[i].index = (c.uint16 - 22 + 1)
        i.inc

proc drawGameFinished(room: Room) =
    Layer(1).setPosition(0, 0)
    let str = ($room.finalScore).align(9, '0')
    var i = 0
    for c in str:
        gameFinish.getTiles(5, 4)[i].index = (c.uint16 - 22 + 1)
        i.inc


proc draw*(room: Room, game: Game) =
    # room.bitmap.drawCircleFill(Point(x: 100, y: 64), 10)
    case room.kind:
    of ROOM_TITLE:
        room.drawTitleScreen()
    of ROOM_LEVEL:
        room.drawLevel(game)
    of ROOM_HUB:
        room.drawHub(game)
    of ROOM_GAMEOVER:
        room.drawGameOver()
    of ROOM_FINISHED:
        room.drawGameFinished()
    of ROOM_SCORE:
        room.drawScoreScreen()
    else:
        discard
    return

proc setMusic*(room: Room, musicPath: string) =
    if(musicPath != ""): startMusic(musicPath)