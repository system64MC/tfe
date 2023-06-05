import std/[times, os]
import netty
import flatty
import ./actors/player
import ../common/vectors
import room/room

var timeStart* = 0.0
var timeFinish* = 0.0
var delta* = 0.0

const FPS* = 60.0
const DELAY* = (1000.0 / FPS.float)


# proc serializePos(vec: VectorI16): string = return toFlatty(vec)

proc main() =
  # var playerPos = VectorI16(x: 50, y: 50)

  var player = constructPlayer(VectorI16(x: 50, y: 50), 0, 5)

  player.setPlayerCallback(
    (
      proc() =
        echo "Delta : " & $delta
    ),
    0
  )

  var server = newReactor("127.0.0.1", 5173)
  room.loadedRoom = loadRoom("assets/tilemaps/testRoom.tmx")
  echo "Server booted! Listening for 📦 packets! 📦"
  while true:
    server.tick()
    timeStart = cpuTime().float
    delta = (timeStart - timeFinish).float

    for connection in server.newConnections:
      echo "[new] ", connection.address

    for connection in server.deadConnections:
      echo "[dead] ", connection.address
    for msg in server.messages:
      playerInput = msg.data[0].uint8


    player.update()
      # echo "[msg]", msg.data[0].uint8

    # echo "[Player's Position] ", playerPos

    # echo serializePos(playerPos)
    # echo player.serialize()
    for connection in server.connections:
      server.send(connection, player.serialize())

    timeFinish = cpuTime()
    delta = timeFinish - timeStart
    if(delta < DELAY):
        sleep((DELAY - delta).int)

main()