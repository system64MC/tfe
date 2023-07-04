# import Tilengine/tilengine
import tilengine/tilengine
import netty
import flatty
import flatty/hexprint

import ../common/vectors
import ../common/message
import actors/player
import actors/bullet
import room/background
import tilengine/bitmapUtils

proc serializeInputs(): uint8 =
  var input = (
    getInput(InputButton1).uint8 shl 4 or

    getInput(Inputup).uint8 shl 3 or
    getInput(Inputdown).uint8 shl 2 or
    getInput(Inputleft).uint8 shl 1 or
    getInput(Inputright).uint8)
  return input



proc `$`(vec: VectorI16): string = return ("x: " & $vec.x & " y: " & $vec.y)

proc unserializePos(data: string): VectorI16 = return fromFlatty(data, VectorI16)

var bulletList*:seq[Bullet]

proc main() =
  var e = init(256, 144, 3, 128, 64)
  initBitmapLayer()
  discard ("e")

  var client = newReactor()
  var connection = client.connect("127.0.0.1", 5173)
  
  var player = player.Player()

  var playerSprite = loadSpriteset("./assets/sprites/player.png")
  let sprPlayer = Sprite(player.character)
  sprPlayer.setSpriteSet(playerSprite)

  let foreground = Layer(0)

  var map = loadTilemap("assets/tilemaps/testRoom.tmx", "collisions")
  foreground.setTilemap(map)


  createWindow()
  
  while processWindow():
    client.tick()
    var input = serializeInputs()
    client.send(connection, $(input.chr))
    echo client.messages.len
    for msg in client.messages:
      let myMsg = fromFlatty(msg.data, message.Message)
      # if(msg.)
      case myMsg.header:
      of MessageHeader.PLAYER_DATA:
        player = unserialize(myMsg.data)
      of MessageHeader.BULLET_LIST:
        var myArr = fromFlatty(myMsg.data, seq[string])
        for i in 0..<1:
          echo hexPrint(myArr[i])
          # echo ()
          if(myArr[i] == $((1).char)): continue
          bulletList[i] = fromFlatty(myArr[i], Bullet)
        # continue
    # bulletList = fromFlatty(client.messages[0].data, array[512, Bullet])
    # player = unserialize(client.messages[1].data)
    bitmap.clearBitmap()
    player.draw()
    drawFrame(0)

main()