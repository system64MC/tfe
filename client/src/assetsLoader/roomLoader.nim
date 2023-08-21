import ../utils/vectors
import ../room/room
import std/json
import ../room/background



proc loadRoom*(path: string, position: VectorU16 = VectorU16(x: 0, y: 0)): Room =

    var room = Room()

    var jsonNode = parseFile(path)
    echo jsonNode    # echo(room.camera.posY)
    var myArray: array[NUM_BACKGRONDS, Background]
    room.layers = myArray
    
    echo jsonNode["room"]["foreground"]["tilemap"].getStr()

    room.layers[0] = createBackground(jsonNode["room"]["foreground"]["tilemap"].getStr(), VectorF32(
        x: jsonNode["room"]["foreground"]["hscrollmul"].getFloat().float32,
        y: jsonNode["room"]["foreground"]["vscrollmul"].getFloat().float32
        ),
        
        isCollidable = jsonNode["room"]["foreground"]["isCollidable"].getBool())

    # room.camera = getCamera()
    room.music = jsonNode["room"]["music"].getStr()

    # Backgrounds = room.layers

    return room