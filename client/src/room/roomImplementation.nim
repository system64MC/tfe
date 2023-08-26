import room
import tilengine/[tilengine, bitmapUtils]
import common/[constants, serializedObjects, commonActors, vectors, message]
import background
import ../music/music
import ../game/game
import netty
import ../drawing
import ../rasterEffects
import flatty

proc init*(room: Room, musicPath: string = "") =
    # We free the tilemaps to avoid memory leaks...
    for i in 0..<room.layers.len:
        if(room.layers[i].layer != nil):
            room.layers[i].layer.delete
            room.layers[i].layer = nil
    room.data = RoomSerialize(
            camera: Camera(position: VectorF64(x: 0, y: 0)),
            playerList: [PlayerSerialize(), nil, nil, nil]
        )
    setRasterCallback(nil)
    if(room.bitmap == nil):
        room.bitmap = createBitmap(SCREEN_X, SCREEN_Y, 8)
        room.bitmap.setPalette(createPalette(16))
        room.bitmap.getPalette().setColor(1, 255, 0, 0)
        Layer(3).setBitmap(room.bitmap)
        Layer(3).setPriority(true)
    for i in 0..<512:
        Sprite(i).disable
    case room.kind:
    of ROOM_TITLE:
        Sprite(0).setSpriteSet(sprites[SpriteTypes.CURSOR.int])
        room.layers[2] = createBackground("./assets/tilemaps/floor.tmx")
        room.layers[1] = createBackground("./assets/tilemaps/titlescreen.tmx")
        Layer(2).setTilemap(room.layers[2].layer)
        Layer(1).setTilemap(room.layers[1].layer)
        setRasterCallback(titleScreenRasterEffect)
    of ROOM_LEVEL:
        Sprite(1).setSpriteSet(sprites[SpriteTypes.PLAYER.int])
        room.layers[1] = createBackground("./assets/tilemaps/testRoom.tmx", "background")
        Layer(1).setTilemap(room.layers[1].layer)
        discard
    of ROOM_HUB:
        room.layers[1] = createBackground("./assets/tilemaps/charSelect.tmx", "frames")
        room.layers[2] = createBackground("./assets/tilemaps/charSelect.tmx", "circle")
        Layer(1).setTilemap(room.layers[1].layer)
        Layer(2).setTilemap(room.layers[2].layer)
        setRasterCallback(selectScreenRasterEffect)
    else:
        discard
    if(musicPath != ""): startMusic(musicPath)
    return

proc updateTitleScreen(room: Room, game: Game) =
    room.cursor.timer.dec
    if(room.cursor.timer <= 0):
        if(getInput(InputDown)):
            room.cursor.position = min(room.cursor.position + 1, EXIT.int)
            room.cursor.timer = 8
        if(getInput(InputUp)):
            room.cursor.position = max(room.cursor.position - 1, JOIN_GAME.int)
            room.cursor.timer = 8
    if(getInput(InputStart)):
        case room.cursor.position.TitleChoices:
        of JOIN_GAME:
            game.room.kind = ROOM_LEVEL
            game.room.init("./assets/musics/goddess.kt")
            game.connection = game.client.connect("127.0.0.1", 5173)
            echo "Join game..."
        of CREATE_GAME:
            echo "Create new game..."
            game.connection = game.client.connect("127.0.0.1", 51730)
            game.client.send(game.connection, toFlatty(message.Message(header: MessageHeader.ENCRYPTED_CREDENTIALS_DATA, data: toFlatty(game.credentials))))
            # game.room.kind = ROOM_HUB
            # game.room.init("./assets/musics/select.kt")
        of SCORES:
            echo "Scores list..."
        of MUSIC_ROOM:
            echo "Open music room"
        of EXIT:
            quit()
    return

proc updateLevel(room: Room) =
    return

proc updateMusicRoom(room: Room) =
    return

proc updateHub(room: Room) =
    return

proc updateScoreScreen(room: Room) =
    return




proc update*(room: Room, game: Game) =
    case room.kind:
    of ROOM_TITLE:
        room.updateTitleScreen(game)
    else:
        discard
    return

# TODO : This part needs to be optimized. Is it possible to use animations instead?
# Maybe I should contact Tilengine's developer to know if there is an easy way to take
# advantage of animations.
proc switchTiles(room: Room, switchOn: bool) =
  let map = room.layers[1].layer
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
    room.needSwitching = false


proc drawTitleScreen(room: Room) =
    Sprite(0).setPosition(80, 48 + (16 * room.cursor.position))
    return

import std/strformat
proc drawLevel(room: Room) =
    # echo fmt"x: {room.data.playerList[0].position.x}, y: {room.data.playerList[0].position.y}"
    Layer(1).setPosition(room.data.camera.position.x.int, room.data.camera.position.y.int)
    if room.needSwitching: room.switchTiles(room.switchState)
    room.data.playerList[0].draw(room.bitmap)
    for b in room.data.bulletList:
        if(b != nil): 
            b.draw(room.bitmap)
    return

proc drawMusicRoom(room: Room) =
    return

proc drawHub(room: Room) =
    setBgColor(0, 0, 0)
    Layer(2).setPosition(256 - (SCREEN_X shr 1), 256 - (SCREEN_Y shr 1))
    Layer(2).setTransform(frame.float / 2, SCREEN_X / 2, SCREEN_Y / 2, 0.5, 0.5)
    Layer(1).setBlendMode(BlendSub, 255)
    return

proc drawScoreScreen(room: Room) =
    return


proc draw*(room: Room) =
    # room.bitmap.drawCircleFill(Point(x: 100, y: 64), 10)
    case room.kind:
    of ROOM_TITLE:
        room.drawTitleScreen()
    of ROOM_LEVEL:
        room.drawLevel()
    of ROOM_HUB:
        room.drawHub()
    else:
        discard
    return