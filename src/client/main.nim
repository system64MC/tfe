import Tilengine/tilengine
import netty
import flatty

proc serializeInputs(): uint8 =

  var input = (
    getInput(Inputup).uint8 shl 3 or
    getInput(Inputdown).uint8 shl 2 or
    getInput(Inputleft).uint8 shl 1 or
    getInput(Inputright).uint8)


  return input

type
  VectorI16 = object
    x: int16
    y: int16

proc `$`(vec: VectorI16): string = return ("x: " & $vec.x & " y: " & $vec.y)

proc unserializePos(data: string): VectorI16 = return fromFlatty(data, VectorI16)

proc main() =
  var e = initEngine()
  discard createWindow("e")

  var client = newReactor()
  var connection = client.connect("127.0.0.1", 5173)
  var playerPos: VectorI16
  var playerSprite = loadSpriteset("./assets/sprites/player.png")
  discard setSpriteSet(0, playerSprite)
  
  echo playerSprite == nil

  while processWindow():
    
    client.tick()
    # for msg in client.messages:
      # echo msg.data[0].uint8

    var input = serializeInputs()
    # echo input

    client.send(connection, $(input.chr))
    for msg in client.messages:
      playerPos = unserializePos(msg.data)
    # echo playerPos
    discard setSpritePosition(0, playerPos.x.int, playerPos.y.int)
    drawFrame(0)

main()