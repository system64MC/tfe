import std/[times, os]
import ./actors/player
import ./actors/bullet
import ../common/vectors
import ../common/message
import ../common/constants
import room/room
import netty
import flatty
import std/threadpool
import tilengine/tilengine
import math

type
  GameInstance* = ref object
    playerList*: array[4, player.Player]
    actorList*: array[512, int] # TODO : Replace int by Actor
    # bulletList*:array[512, Bullet] # TODO : Replace int by Bullet
    bulletList*:seq[Bullet]
    timeStart*: float64
    timeFinish*: float64
    delta*: float64
    server*: Reactor
    frame*: int
    loadedRoom*: Room


# var timeStart* = 0.0
# var timeFinish* = 0.0
# var delta* = 0.0

const FPS* = 60.0
const DELAY* = (1000.0 / FPS.float)


proc update*(game: GameInstance): void {.gcsafe.} =
    for msg in game.server.messages:
      game.playerList[0].input = msg.data[0].uint8

    game.playerList[0].update()
    
    for i in 0..<game.bulletList.len:
      var b = game.bulletList[i]
      if(b == nil): continue
      if(b.position.x > SCREEN_X or b.position.x < 0 or
        b.position.y > SCREEN_Y or b.position.y < 0):
        game.bulletList[i] = nil
        continue
      b.update()

proc serialize*(game: GameInstance): void =
    
    for connection in game.server.connections:
      # var bList = newSeq[string](512)
      # for i in 0..<512:
      #   bList[i] = toFlatty(game.bulletList[i])
      game.server.send(connection,  toFlatty(message.Message(header: MessageHeader.BULLET_LIST, data: toFlatty(game.bulletList))))
      # game.server.send(connection,  toFlatty(message.Message(header: MessageHeader.BULLET_LIST, data: toFlatty(bList))))
      game.server.send(connection, game.playerList[0].serialize())

proc addBullet*(game: GameInstance, isPlayer: bool = true, bType: int = 0, direction: VectorF64 = VectorF64(x: 0, y: 1), position: VectorF64): void =
  for i in 0..<512:
    if(game.bulletList[i] != nil): continue
    game.bulletList[i] = Bullet(isPlayer: isPlayer, bulletType: bType, vector: direction, position: position)
    break
  

proc init*(game: GameInstance): void =
  var player = constructPlayer(VectorF64(x: 50, y: 50), 0, 5)
  game.bulletList = newSeq[bullet.Bullet](512)

  player.setPlayerCallback(
    (
      proc() =
        game.addBullet(position = VectorF64(
          x: player.position.x + player.hitbox.size.x.float64,
          y: player.position.y + player.hitbox.size.y.float64 / 2),
          direction = VectorF64(x: sin(game.frame.float64)*4.0, y: 8))
        # echo "Position : " & $player.position.x
    ),
    0
  )


  

  game.playerList[0] = player

  game.server = newReactor("127.0.0.1", 5173)
  game.loadedRoom = loadRoom("assets/tilemaps/testRoom.tmx")
  player.currentRoom = game.loadedRoom
  echo "Server booted! Listening for 📦 packets! 📦"

proc bootGameInstance*() {.thread.} =
  var game = GameInstance()
  game.init()

  while true:
    game.server.tick()
    game.timeStart = cpuTime().float
    game.delta = (game.timeStart - game.timeFinish).float

    for connection in game.server.newConnections:
      echo "[new] ", connection.address

    for connection in game.server.deadConnections:
      echo "[dead] ", connection.address

    game.update()
    game.serialize()

    game.timeFinish = cpuTime()
    game.delta = game.timeFinish - game.timeStart
    game.frame.inc
    if(game.delta < DELAY):
        sleep((DELAY - game.delta).int)
