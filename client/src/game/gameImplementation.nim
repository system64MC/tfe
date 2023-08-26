import tilengine/[tilengine, bitmapUtils]
import common/[constants, message, events, serializedObjects, vectors, credentials]
import ../music/music
import game
import ../room/[room, roomImplementation]
import netty
import flatty
import std/[times, tables]
import supersnappy
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
    # echo data.len
    let r = fromFlatty(uncompress(data), RoomSerialize)
    return r

proc fetchMessages*(game: Game) =
    game.client.tick()
    if(game.connection != nil and game.room.kind != ROOM_TITLE):
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
    game.room.draw()
    drawFrame()
    game.frame.inc
    frame.inc
    return