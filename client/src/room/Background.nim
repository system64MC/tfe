import tilengine/tilengine
import common/vectors
import common/constants

const MAX_BGS = 3

type
    Background* = object
        layer*: Tilemap
        # collisions*: TLN_Tilemap
        scrollMults*: VectorF32
        # isCollidable*: bool
        offset*: VectorI16
        isPrimary*: bool

proc createBackground*(path: string, layerName: string = "layer", scrollMullts: VectorF32 = VectorF32(x: 0, y: 0), x: int = 0, y: int = 0): Background =
    var bg = Background()
    bg.layer = loadTilemap(path, layerName)
    if(bg.layer == nil):
        quit("FATAL ERROR")
    bg.scrollMults = scrollMullts
    return bg



var bitmap*:Bitmap
var bitmapLayer* = Layer(2)

proc initBitmapLayer*(): void =
    bitmap = createBitmap(SCREEN_X, SCREEN_Y, 8)
    bitmap.setPalette(createPalette(16))
    bitmap.getPalette().setColor(1, 255, 0, 0)
    bitmapLayer.setBitmap(bitmap)
    bitmapLayer.setPosition(0, 0)
    bitmapLayer.setPriority(true)