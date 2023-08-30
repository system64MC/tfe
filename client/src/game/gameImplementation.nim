import tilengine/[tilengine, bitmapUtils]
import common/[constants, message, events, serializedObjects, vectors, credentials]
import ../music/music
import game
import ../room/[room, roomImplementation]
import netty
import flatty
import std/[times, tables, strutils, strformat]
import supersnappy
import tinydialogs
# import background

proc init*(credentials: CredentialsEncrypted): Game =
    discard init(SCREEN_X, SCREEN_Y, 4, 512, 64)
    initMusic(44100)
    var game = Game()
    game.credentials = credentials
    game.room = Room() # create base object
    game.room.kind = RoomKind.ROOM_TITLE
    game.room.init("./assets/musics/magica.kt") # Execute init method on base object
    
    setTargetFps(120)
    createWindow(flags = {cwfNoVsync})
    setWindowTitle(fmt"Magica Online ~ {credentials.name}")
    game.client = newReactor()
    return game

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

proc unserializeRoom(data: string): RoomSerialize =
    let r = fromFlatty(uncompress(data), RoomSerialize)
    return r

proc unserializeHub(data: string): HubSerialize =
    let h = fromFlatty(uncompress(data), HubSerialize)
    return h

proc fetchMessages*(game: Game) =
    game.client.tick()
    if(game.connection != nil and game.room.kind == ROOM_LEVEL):
        game.client.send(game.connection, toFlatty(message.Message(header: EVENT_INPUT, data: serializeInputs())))
    for msg in game.client.messages:
        let myMsg = fromFlatty(msg.data, message.Message)
        case myMsg.header:
        of MessageHeader.ROOM_DATA: 
            # echo "room data"
            game.room.data = unserializeRoom(myMsg.data)
        of MessageHeader.EVENT_DESTROY_TILE:
            let e = fromFlatty(myMsg.data, EventTileChange)
            var tile = game.room.layers[1].layer.getTile(e.coordinates.y, e.coordinates.x)
            tile.index = e.tileType
            game.room.layers[1].layer.setTile(e.coordinates.y, e.coordinates.x, tile)
        of MessageHeader.EVENT_SWITCH:
            game.room.needSwitching = true
            let e = fromFlatty(myMsg.data, events.EventSwitch)
            game.room.switchState = e.state
        of MessageHeader.DESTROYABLE_TILES_DATA:
            echo "Received data!"
            let list = fromFlatty(myMsg.data, Table[VectorI64, bool])
            for coordinates, isHere in list:
                if(not isHere):
                    var tile = game.room.layers[1].layer.getTile(coordinates.y, coordinates.x)
                    tile.index = 1
                    game.room.layers[1].layer.setTile(coordinates.y, coordinates.x, tile)
        of MessageHeader.OK_JOIN_SERVER:
            let port = myMsg.data.parseInt()
            game.client.disconnect(game.connection)
            game.connection = game.client.connect("127.0.0.1", port)
            game.client.send(game.connection, toFlatty(message.Message(header: ENCRYPTED_CREDENTIALS_DATA, data: toFlatty(game.credentials))))
        of MessageHeader.OK_JOIN_HUB:
            echo "Welcome to hub"
            game.room.kind = ROOM_HUB
            game.room.state = NONE
            game.room.init("./assets/musics/select.kt")
        of MessageHeader.ERROR_CREATE_GAME:
            game.client.disconnect(game.connection)
            # TODO : Display error message window
        of MessageHeader.EVENT_SERVER_DEAD:
            game.client.disconnect(game.connection)
            game.room.kind = ROOM_TITLE
            game.room.state = NONE
            game.room.init("./assets/musics/magica.kt")
            var a = messageBox("Warning", "You got disconnected because the Master left the game", DialogType.Ok, IconType.Warning, Button.Yes)
        of MessageHeader.HUB_DATA:
            game.room.hubData = unserializeHub(myMsg.data)
        of MessageHeader.ERROR_FULL:
            var a = messageBox("Error!", "The game is full!", DialogType.Ok, IconType.Error, Button.Yes)
            game.room.state = NONE
        of MessageHeader.EVENT_LOAD_LEVEL:
            game.room.kind = ROOM_LEVEL
            game.room.state = NONE
            game.room.init(level = myMsg.data.parseInt())
        else:
            continue

proc update*(game: Game) =
    game.fetchMessages()
    # echo "a"
    game.room.update(game)
    # case game.state
    # of TITLE_SCREEN:
    # else:
    #     discard
    
    return

proc draw*(game: Game) =
    game.room.bitmap.clearBitmap()
    game.room.draw(game)
    drawFrame()
    game.frame.inc
    frame.inc
    return