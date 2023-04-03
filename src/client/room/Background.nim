import tilengine/tilengine
import ../../common/vectors

type
    Background* = ref object of RootObj
        layer*: Tilemap
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
    bg.scrollMults = scrollMullts
    return bg