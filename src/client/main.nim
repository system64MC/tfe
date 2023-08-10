# import Tilengine/tilengine
import tilengine/tilengine
import netty
import flatty
import flatty/hexprint

import ../common/vectors
import ../common/message
import ../common/events
import ../common/constants
import actors/player
import actors/bullet
import room/background
import camera
import tilengine/bitmapUtils
import std/monotimes
import std/[times, os]

proc serializeInputs(): string =
  var input = (
    getInput(InputButton3).uint8 shl 6 or
    getInput(InputButton2).uint8 shl 5 or
    getInput(InputButton1).uint8 shl 4 or

    getInput(Inputup).uint8 shl 3 or
    getInput(Inputdown).uint8 shl 2 or
    getInput(Inputleft).uint8 shl 1 or
    getInput(Inputright).uint8)
  return toFlatty(EventInput(input: input, sentAt: getTime().toUnixFloat()))



proc `$`(vec: VectorI16): string = return ("x: " & $vec.x & " y: " & $vec.y)

proc unserializePos(data: string): VectorI16 = return fromFlatty(data, VectorI16)

var bulletList*: array[512, Bullet]

var cam = Camera(position: VectorF64(x: 0, y: 0))

# proc getTile*(pos: VectorF64, currentRoom: Room): Tile =
#     return currentRoom.collisions.getTile(pos.y.int shr 4, pos.x.int shr 4)

# TODO : This part needs to be optimized. Is it possible to use animations instead?
# Maybe I should contact Tilengine's developer to know if there is an easy way to take
# advantage of animations.
proc switchTiles(map: Tilemap, switchOn: bool) =
  for j in 0..<map.getRows:
    for i in 0..<map.getCols:
      var tile = map.getTile(j, i)
      if(tile.index > 1 and tile.index < 8):
        if(switchOn):
          if tile.index == 3: tile.index = 2
          if tile.index == 5: tile.index = 4
          if tile.index == 6: tile.index = 7
          map.setTile(j, i, tile)
          continue
        if tile.index == 2: tile.index = 3
        if tile.index == 4: tile.index = 5
        if tile.index == 7: tile.index = 6
        map.setTile(j, i, tile)

var switchState = true
var needSwitching = false

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

  var map = loadTilemap("assets/tilemaps/testRoom.tmx", "background")
  foreground.setTilemap(map)

  setTargetFps(120)
  var sp = map.getTileset.getSequencePack()
  
  createWindow(flags = {cwfNoVsync})
  
  while processWindow():
    client.tick()
    var input = serializeInputs()
    client.send(connection, toFlatty(message.Message(header: EVENT_INPUT, data: input)))

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
      of MessageHeader.EVENT_DESTROY_TILE:
        let e = fromFlatty(myMsg.data, EventTileChange)
        var tile = map.getTile(e.coordinates.y, e.coordinates.x)
        tile.index = e.tileType
        map.setTile(e.coordinates.y, e.coordinates.x, tile)
      of MessageHeader.EVENT_SWITCH:
        needSwitching = true
        let e = fromFlatty(myMsg.data, events.EventSwitch)
        switchState = e.state
        # for i in 0..<1:
        #   # echo ()
        #   if(myArr[i] == $((1).char)): continue
        #   echo hexPrint(myArr[i])
        #   bulletList[i] = fromFlatty(myArr[i], bullet.Bullet)
      else:
        continue
    
    map.switchTiles(switchState)
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
    # sleep(100)
  client.disconnect(connection)
main()