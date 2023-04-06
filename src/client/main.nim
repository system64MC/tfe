# import Tilengine/tilengine
import tilengine/tilengine
import netty
import flatty
import ../common/vectors
import actors/player
import room/background
import tilengine/bitmapUtils

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
  var e = init(256, 144, 2, 128, 64)
  initBitmapLayer()
  discard ("e")

  var client = newReactor()
  var connection = client.connect("127.0.0.1", 5173)
  
  var player = player.Player()

  var playerSprite = loadSpriteset("./assets/sprites/player.png")
  let sprPlayer = Sprite(player.character)
  sprPlayer.setSpriteSet(playerSprite)


  createWindow()
  
  while processWindow():
    client.tick()
    var input = serializeInputs()
    client.send(connection, $(input.chr))
    for msg in client.messages:
      player = unserialize(msg.data)
    bitmap.clearBitmap()
    player.draw()
    drawFrame(0)

main()