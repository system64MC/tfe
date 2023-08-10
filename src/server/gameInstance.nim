import std/[times, os]
import ./actors/implementations/player
import ./actors/implementations/bullet
import ../common/vectors
import ../common/message
import ../common/events
import ../common/constants
import camera
import room/room
import netty
import flatty
import std/threadpool
import tilengine/tilengine
import math
import gameInfos
import ./actors/actors
import std/monotimes

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
        game.infos.playerList[0].input = game.infos.playerList[0].input or e.input
        let t = getTime().toUnixFloat()
        let duration = (t - e.sentAt)
        # echo(duration * TPS)
        game.infos.playerList[0].deltaTimeAccumulator += duration
        game.infos.playerList[0].deltaTimeHowManyValues.inc
    if(game.infos.playerList[0].deltaTimeHowManyValues >= 64):
      let avg = game.infos.playerList[0].deltaTimeAccumulator / game.infos.playerList[0].deltaTimeHowManyValues.float
      # echo avg * TPS
      game.infos.playerList[0].deltaTime = clamp(avg, MINIMAL_LATENCY, MAX_LATENCY)
      game.infos.playerList[0].deltaTimeAccumulator = 0
      game.infos.playerList[0].deltaTimeHowManyValues = 0
    game.infos.playerList[0].update(game.infos)
    
    for i in 0..<game.infos.bulletList.len:
      var b = game.infos.bulletList[i]
      if(b == nil): continue
      if(b.bulletType < 0):
        game.infos.bulletList[i] = nil
        continue
      if(b.position.x > SCREEN_X or b.position.x < 0 or
        b.position.y > SCREEN_Y or b.position.y < 0):
        game.infos.bulletList[i] = nil
        continue
      b.update(game.infos)

proc serialize*(game: GameInstance): void =
    # Serializing the bullet list
    var bulletListSerialize: array[512, BulletSerialize]
    for i in 0..<game.infos.bulletList.len:
        let b = game.infos.bulletList[i]
        if(b == nil):
          bulletListSerialize[i] = nil
          continue
        bulletListSerialize[i] = game.infos.bulletList[i].toSerializeObject()
    let bList = toFlatty(message.Message(header: MessageHeader.BULLET_LIST, data: toFlatty(bulletListSerialize)))
    let camData = game.infos.loadedRoom.camera.serialize()

    # Sending data to the server.
    for connection in game.server.connections:
      game.server.send(connection, camData)
      game.server.send(connection, bList)
      game.server.send(connection, game.infos.playerList[0].serialize())

    # Sending events to the server.
    for e in game.infos.eventList:
      let data = e.toFlatty()
      for connection in game.server.connections:
        game.server.send(connection, data)

proc addBullet*(game: GameInstance, isPlayer: bool = true, bType: int = 0, direction: VectorF64 = VectorF64(x: 0, y: 1), position: VectorF64): void =
  for i in 0..<512:
    if(game.infos.bulletList[i] != nil): continue
    game.infos.bulletList[i] = Bullet(
      isPlayer: isPlayer, 
      bulletType: bType, 
      vector: direction, 
      position: position, 
      bulletId: i.uint16, 
      currentRoom: game.infos.loadedRoom,
      )
    break
  

proc init*(game: GameInstance): void =
  game.infos.eventList = newSeq[message.Message](0)
  var player = constructPlayer(VectorF64(x: 50, y: 50), 0, 5)

  game.infos.playerList[0] = player

  # Creating the server, listening on the ELIS port (Port 5173)
  game.server = newReactor("127.0.0.1", 5173)
  # We load the test room.
  game.infos.loadedRoom = loadRoom("assets/tilemaps/testRoom.tmx")
  # Setting the current room to the player, so we can check collisions
  player.currentRoom = game.infos.loadedRoom
  echo "Server booted! Listening for 📦 packets! 📦"

proc bootGameInstance*() {.thread.} =
  var game = GameInstance()
  game.init()
  
  # Main game loop
  while true:
    game.server.tick()
    game.infos.timeStart = cpuTime().float
    game.infos.delta = (game.infos.timeStart - game.infos.timeFinish).float

    for connection in game.server.newConnections:
      echo "[new] ", connection.address

    for connection in game.server.deadConnections:
      echo "[dead] ", connection.address

    game.update()
    game.serialize()

    game.infos.timeFinish = cpuTime()
    game.infos.delta = game.infos.timeFinish - game.infos.timeStart
    game.infos.frame.inc
    if(game.infos.delta < TPS_DELAY):
        sleep((TPS_DELAY - game.infos.delta).int)
