import std/[times, os]
import netty
import flatty

var timeStart* = 0.0
var timeFinish* = 0.0
var delta* = 0.0

const FPS* = 60.0
const DELAY* = (1000.0 / FPS.float)

var playerInput: uint8 = 0b0000_0000 # Input of player.

proc inputUp():    bool = return ((playerInput and 0b0000_1000) > 0)
proc inputDown():  bool = return ((playerInput and 0b0000_0100) > 0)
proc inputLeft():  bool = return ((playerInput and 0b0000_0010) > 0)
proc inputRight(): bool = return ((playerInput and 0b0000_0001) > 0)


type
  VectorI16 = object
    x: int16
    y: int16

proc `$`(vec: VectorI16): string = return ("x: " & $vec.x & " y: " & $vec.y)
proc serializePos(vec: VectorI16): string = return toFlatty(vec)

proc main() =
  var playerPos = VectorI16(x: 50, y: 50)
  var server = newReactor("127.0.0.1", 5173)
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
      # echo "[msg]", msg.data[0].uint8

    if(inputUp()):    playerPos.y -= 4
    if(inputDown()):  playerPos.y += 4
    if(inputLeft()):  playerPos.x -= 4
    if(inputRight()): playerPos.x += 4

    echo "[Player's Position] ", playerPos

    # echo serializePos(playerPos)

    for connection in server.connections:
      server.send(connection, serializePos(playerPos))

    timeFinish = cpuTime()
    delta = timeFinish - timeStart
    if(delta < DELAY):
        sleep((DELAY - delta).int)

main()