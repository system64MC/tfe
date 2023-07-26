# import Tilengine/tilengine
import tilengine/tilengine
import netty
import flatty
import flatty/hexprint

import ../common/vectors
import ../common/message
import ../common/constants
import actors/player
import actors/bullet
import room/background
import camera
import tilengine/bitmapUtils

proc serializeInputs(): uint8 =
  var input = (
    getInput(InputButton3).uint8 shl 6 or
    getInput(InputButton2).uint8 shl 5 or
    getInput(InputButton1).uint8 shl 4 or

    getInput(Inputup).uint8 shl 3 or
    getInput(Inputdown).uint8 shl 2 or
    getInput(Inputleft).uint8 shl 1 or
    getInput(Inputright).uint8)
  return input



proc `$`(vec: VectorI16): string = return ("x: " & $vec.x & " y: " & $vec.y)

proc unserializePos(data: string): VectorI16 = return fromFlatty(data, VectorI16)

var bulletList*: array[512, Bullet]

var cam = Camera(position: VectorF64(x: 0, y: 0))

proc main() =
  cam = Camera()
  var e = init(SCREEN_X, SCREEN_Y, 3, 128, 64)
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

  setTargetFps(60)
  createWindow(flags = {cwfNoVsync})
  
  while processWindow():
    client.tick()
    var input = serializeInputs()
    client.send(connection, $(input.chr))
    for msg in client.messages:
      let myMsg = fromFlatty(msg.data, message.Message)
      # if(msg.)
      case myMsg.header:
      of MessageHeader.PLAYER_DATA:
        player = unserialize(myMsg.data)
      of MessageHeader.BULLET_LIST:
        bulletList = fromFlatty(myMsg.data, array[512, Bullet])
      of MessageHeader.BULLET_NULL:
        let i = fromFlatty(myMsg.data, uint16)
        bulletList[i] = nil
      of MessageHeader.CAMERA_DATA:
        cam = fromFlatty(myMsg.data, Camera)
        # for i in 0..<1:
        #   # echo ()
        #   if(myArr[i] == $((1).char)): continue
        #   echo hexPrint(myArr[i])
        #   bulletList[i] = fromFlatty(myArr[i], bullet.Bullet)
      else:
        continue
        # continue
    # bulletList = fromFlatty(client.messages[0].data, array[512, Bullet])
    # player = unserialize(client.messages[1].data)
    bitmap.clearBitmap()
    foreground.setPosition(cam.position.x.int, cam.position.y.int)
    player.draw()
    for b in bulletList:
      if(b == nil): continue
      b.draw()
    drawFrame(0)

main()