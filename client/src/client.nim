# import Tilengine/tilengine
import tilengine/tilengine
import netty
import flatty
import flatty/hexprint

import common/vectors
import common/message
import common/events
import common/constants
import room/background
import tilengine/bitmapUtils
import std/monotimes
import std/[json, times, os, tables, httpclient, asyncdispatch, strformat]
import loginWindow
import common/[credentials, commonActors, serializedObjects]
import drawing
import game/[game, gameImplementation]
import globals

var creds: CredentialsEncrypted

proc main() =

  let json = readFile("./assets/config.json")
  let jNode = parseJson(json)
  serverAddressGlobal = jNode["serverAddress"].getStr()

  httpClientGlobal = newAsyncHttpClient()
  creds = waitFor openLoginWindow(httpClientGlobal)
  # initBitmapLayer()

  # var client = newReactor()
  # var connection = client.connect("127.0.0.1", 5173)
  
  # var playerSprite = loadSpriteset("./assets/sprites/player.png")
  # let sprPlayer = Sprite(room.playerList[0].character)
  # sprPlayer.setSpriteSet(playerSprite)

  # let foreground = Layer(0)

  # var map = loadTilemap("assets/tilemaps/testRoom.tmx", "background")
  # foreground.setTilemap(map)
  var game = gameImplementation.init(creds)

  while processWindow():
    game.update()
    game.draw()

  if(game.connection != nil):
    game.client.disconnect(game.connection)
    
    
  
  # while processWindow():
  #   client.tick()
  #   var input = serializeInputs()
  #   client.send(connection, toFlatty(message.Message(header: EVENT_INPUT, data: input)))

    # for msg in client.messages:
    #   let myMsg = fromFlatty(msg.data, message.Message)
    #   case myMsg.header:
    #   of MessageHeader.ROOM_DATA: unserializeRoom(myMsg.data)
    #   of MessageHeader.EVENT_DESTROY_TILE:
    #     let e = fromFlatty(myMsg.data, EventTileChange)
    #     var tile = map.getTile(e.coordinates.y, e.coordinates.x)
    #     tile.index = e.tileType
    #     map.setTile(e.coordinates.y, e.coordinates.x, tile)
    #   of MessageHeader.EVENT_SWITCH:
    #     needSwitching = true
    #     let e = fromFlatty(myMsg.data, events.EventSwitch)
    #     switchState = e.state
    #   of MessageHeader.DESTROYABLE_TILES_DATA:
    #     echo "Received data!"
    #     let list = fromFlatty(myMsg.data, Table[VectorI64, bool])
    #     for coordinates, isHere in list:
    #       if(not isHere):
    #         var tile = map.getTile(coordinates.y, coordinates.x)
    #         tile.index = 1
    #         map.setTile(coordinates.y, coordinates.x, tile)
    #   else:
    #     continue
    
  #   map.switchTiles(switchState)
  #       # continue
  #   # bulletList = fromFlatty(client.messages[0].data, array[512, Bullet])
  #   # player = unserialize(client.messages[1].data)
  #   Background.bitmap.clearBitmap()
  #   # foreground.setPosition(cam.position.x.int, cam.position.y.int)
  #   foreground.setPosition(room.camera.position.x.int, room.camera.position.y.int)
  #   room.playerList[0].draw()
  #   for b in room.bulletList:
  #     if(b == nil): continue
  #     b.draw()
  #   drawFrame(0)
  #   # sleep(100)
  # client.disconnect(connection)

when isMainModule:
  main()