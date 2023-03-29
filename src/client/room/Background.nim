import ../Tilengine/Tilengine
import ../../common/vectors

type
    Background* = ref object of RootObj
        layer*: TLN_Tilemap
        # collisions*: TLN_Tilemap
        scrollMults*: VectorF32
        isCollidable*: bool
        offset*: VectorI16
        isPrimary*: bool

proc createBackground*(path: string, scrollMullts: VectorF32 = VectorF32(x: 0, y: 0), isCollidable: bool, x: int = 0, y: int = 0): Background =
    var bg = Background()
    bg.layer = loadTilemap(path, "layer")
    if(bg.layer == nil):
        echo("FATAL ERROR")
    # if(isCollidable):
    #     bg.collisions = loadTilemap(path, "collisions")
    # else:
    #     bg.collisions = nil
    bg.scrollMults = scrollMullts
    # bg.offsetX = x
    # bg.offsetY = y
    return bg