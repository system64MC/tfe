import std/[times, os]
import ./actors/implementations/player
import ./actors/implementations/bullet
import ./actors/bulletList
import ../common/[vectors, message, events, constants]
import camera
import room/[room, roomImplementation]
import netty
import flatty
import std/threadpool
import tilengine/tilengine
import math
import gameInfos
import ./actors/actors
import std/monotimes
import std/tables

type
  GameInstance* = ref object
    infos*: GameInfos
    server*: Reactor
# var timeStart* = 0.0
# var timeFinish* = 0.0
# var delta* = 0.0




proc update*(game: GameInstance): void {.gcsafe.} =
    game.infos.eventList.setLen(0)
    for msg in game.server.messages:
      let data = fromFlatty(msg.data, message.Message)
      if(data.header == MessageHeader.EVENT_INPUT):
        let e = fromFlatty(data.data, events.EventInput)
        game.infos.loadedRoom.playerList[0].input = game.infos.loadedRoom.playerList[0].input or e.input
        let t = getTime().toUnixFloat()
        let duration = (t - e.sentAt)
        # echo(duration * TPS)
        game.infos.loadedRoom.playerList[0].deltaTimeAccumulator += duration
        game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues.inc
    if(game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues >= 64):
      let avg = game.infos.loadedRoom.playerList[0].deltaTimeAccumulator / game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues.float
      # echo avg * TPS
      game.infos.loadedRoom.playerList[0].deltaTime = clamp(avg, MINIMAL_LATENCY, MAX_LATENCY)
      game.infos.loadedRoom.playerList[0].deltaTimeAccumulator = 0
      game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues = 0
    game.infos.loadedRoom.playerList[0].update(game.infos)
    
    for i in 0..<game.infos.loadedRoom.bulletList.list.len:
      var b = game.infos.loadedRoom.bulletList[i]
      if(b == nil): continue
      if(b.bulletType < 0):
        game.infos.loadedRoom.bulletList.remove(i)
        # game.infos.bulletList[i] = nil
        continue
      if(b.position.x > SCREEN_X or b.position.x < 0 or
        b.position.y > SCREEN_Y or b.position.y < 0):
        game.infos.loadedRoom.bulletList.remove(i)
        # game.infos.bulletList[i] = nil
        continue
      b.update(game.infos)

proc serialize*(game: GameInstance): void {.gcsafe.} =
    # Serializing the bullet list
    var bulletListSerialize: array[512, BulletSerialize]
    for i in 0..<game.infos.loadedRoom.bulletList.list.len:
        let b = game.infos.loadedRoom.bulletList[i]
        if(b == nil):
          bulletListSerialize[i] = nil
          continue
        bulletListSerialize[i] = game.infos.loadedRoom.bulletList[i].toSerializeObject()
    let bList = toFlatty(message.Message(header: MessageHeader.BULLET_LIST, data: toFlatty(bulletListSerialize)))
    let camData = game.infos.loadedRoom.camera.serialize()

    # Sending data to the server.
    for connection in game.server.connections:
      game.server.send(connection, camData)
      game.server.send(connection, bList)
      game.server.send(connection, game.infos.loadedRoom.playerList[0].serialize())

    # Sending events to the server.
    for e in game.infos.eventList:
      let data = e.toFlatty()
      for connection in game.server.connections:
        game.server.send(connection, data)

# proc addBullet*(game: GameInstance, isPlayer: bool = true, bType: int = 0, direction: VectorF64 = VectorF64(x: 0, y: 1), position: VectorF64): void =
#   for i in 0..<512:
#     if(game.infos.loadedRoom.bulletList[i] != nil): continue
#     game.infos.bulletList[i] = Bullet(
#       isPlayer: isPlayer, 
#       bulletType: bType, 
#       vector: direction, 
#       position: position, 
#       bulletId: i.uint16, 
#       currentRoom: game.infos.loadedRoom,
#       )
#     break
  

proc init*(game: GameInstance): void =
  game.infos.eventList = newSeq[message.Message](0)
  game.infos.loadedRoom = loadRoom("assets/tilemaps/testRoom.tmx")
  game.infos.loadedRoom.bulletList = initBulletList()
  var player = constructPlayer(VectorF64(x: 50, y: 50), 0, 5)

  game.infos.loadedRoom.playerList[0] = player

  # Creating the server, listening on the ELIS port (Port 5173)
  game.server = newReactor("127.0.0.1", 5173)
  # We load the test room.
  # Setting the current room to the player, so we can check collisions
  # player.currentRoom = game.infos.loadedRoom
  echo "Server booted! Listening for 📦 packets! 📦"

proc checkNewDeadConnections(game: GameInstance): void {.gcsafe.} =
  for connection in game.server.newConnections:
      game.server.send(connection, toFlatty(message.Message(header: DESTROYABLE_TILES_DATA, data: toFlatty(game.infos.loadedRoom.destroyableTilesList))))
      let switchEvent = EventSwitch(state: game.infos.loadedRoom.switchOn)
      let m = message.Message(header: message.EVENT_SWITCH, data: toFlatty(switchEvent))
      game.server.send(connection, toFlatty(m))
      echo "[new] ", connection.address
      echo "[SERVER : ]", game.server.address

  for connection in game.server.deadConnections:
      echo "[dead] ", connection.address

proc bootGameInstance*() {.thread.} =
  var game = GameInstance()
  game.init()
  
  # Main game loop
  while true:
    game.server.tick()
    game.infos.timeStart = cpuTime().float
    game.infos.delta = (game.infos.timeStart - game.infos.timeFinish).float

    game.update()
    game.serialize()
    game.checkNewDeadConnections()

    game.infos.timeFinish = cpuTime()
    game.infos.delta = game.infos.timeFinish - game.infos.timeStart
    game.infos.frame.inc
    if(game.infos.delta < TPS_DELAY):
        sleep((TPS_DELAY - game.infos.delta).int)
