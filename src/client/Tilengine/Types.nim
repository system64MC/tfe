type
    WindowFlags* = enum
        FULLSCREEN  = 1 shl 0
        VSYNC       = 1 shl 1
        SIZE1       = 1 shl 2
        SIZE2       = 2 shl 2
        SIZE3       = 3 shl 2
        SIZE4       = 4 shl 2
        SIZE5       = 5 shl 2
        NEAREST     = 1 shl 6

type
    TileFlags* = object
        index*: uint16
        tileset*: uint8
        masked*: bool
        priority*: bool
        rotated*: bool
        flipy*: bool
        flipx*: bool
        
proc getTileFlags*(index: uint16 = 0, tileset: uint8 = 0, masked: bool = false, priority: bool = false, rotated: bool = false, flipy: bool = false, flipx: bool = false): TileFlags =
    var tf: TileFlags
    tf.index = index
    tf.tileset = tileset
    tf.masked = masked
    tf.priority = priority
    tf.rotated = rotated
    tf.flipy = flipy
    tf.flipx = flipx
    return tf

type
    BlendFlags* {.pure.} = enum
        NONE#/*!< blending disabled */
        MIX25#/*!< color averaging 1 */
        MIX50#/*!< color averaging 2 */
        MIX75#/*!< color averaging 3 */
        ADD#/*!< color is always brighter (simulate light effects) */
        SUB#/*!< color is always darker (simulate shadow effects) */
        MOD#/*!< color is always darker (simulate shadow effects) */
        CUSTOM#/*!< user provided blend function with TLN_SetCustomBlendFunction() */
        MAX
        # MIX = MIX50

type
    LayerType* {.pure.} = enum
        NONE#/*!< undefined */
        TILE#/*!< tilemap-based layer */
        OBJECT#/*!< objects layer */
        BITMAP#/*!< bitmapped layer */

type
    Affine* = object
        angle:  float
        dx:     float
        dy:     float
        sx:     float
        sy:     float

type
  SubObject = object
    index, flags: uint16
  TileM* {.union.} = object
     value:uint
     a: SubObject

type
    SequenceFrame* = object
        index: int
        delay: int
    
type
    ColorStrip* = object
        delay: int
        first: uint8
        count: uint8
        dir: uint8

type
    SequenceInfo* = object
        name: string
        numFrame: int

type
    SpriteData* = object
        name: string
        x: int
        y: int
        w: int
        h: int

type
    SpriteInfo* = object
        w: int
        h: int

type
    TileInfo* = object
        index: uint16
        flags: uint16
        raw, col, xoffset, yoffset: int
        color, tType: uint8
        empty: bool

type
    ObjectInfo* = object
        id, gid, flags: uint16
        x, y, w, h: int
        oType: uint8
        visible: bool
        name: string

type
    TileAttributes* = object
        tType: uint8
        priority: bool

type
    Overlay* {.pure.} = enum
        NONE
        SHADOWMASK
        APERTURE
        SCANLINES
        CUSTOM
        MAX
type
    Crt* {.pure.} = enum
        SLOT
        APERTURE
        SHADOW

type
    PixelMap* = object
        dx, dy: uint16

type
    Color* = object
        r*, g*, b*, a*: uint8

type
    LogLevel* {.pure.} = enum
        NONE
        ERRORS
        VERBOSE

