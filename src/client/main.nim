import Tilengine/tilengine
import netty
import flatty
import ../common/vectors
import actors/player

proc serializeInputs(): uint8 =
  var input = (
    getInput(Inputup).uint8 shl 3 or
    getInput(Inputdown).uint8 shl 2 or
    getInput(Inputleft).uint8 shl 1 or
    getInput(Inputright).uint8)
  return input



proc `$`(vec: VectorI16): string = return ("x: " & $vec.x & " y: " & $vec.y)

proc unserializePos(data: string): VectorI16 = return fromFlatty(data, VectorI16)

proc main() =
  var e = initEngine()
  discard createWindow("e")

  var client = newReactor()
  var connection = client.connect("127.0.0.1", 5173)

  var player = Player()

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
      player = unserialize(msg.data)


    player.draw()
    # echo playerPos
    drawFrame(0)

main()