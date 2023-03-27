import Types, TilengineBinding


var nimRasterCallback: proc (scanline: cint)

var timeStart* = 0.0
var timeFinish* = 0.0
var delta* = 0.0

const FPS* = 60
const DELAY* = (1000.0 / FPS.float)

# ENGINE FUNCTIONS
proc initEngine*(hres: int = 384, vres: int = 216, numLayers: int = 4, numSprites: int = 128, numAnim: int = 64): TLN_ENGINE =
    return TLN_Init(hres.cint, vres.cint, numLayers.cint, numSprites.cint, numAnim.cint)

proc deleteEngine*(self: TLN_Engine): bool =
    return TLN_DeleteContext(self)

proc getNumObjects*(): uint =
    return TLN_GetNumObjects().uint

proc getUsedMemory*(): uint =
    return TLN_GetUsedMemory().uint

proc getEngineVer*(): uint =
    return TLN_GetVersion().uint

proc getNumLayers*(): uint = 
    return TLN_GetNumLayers().uint

proc getNumSprites*(): uint =
    return TLN_GetNumSprites().uint

proc setBgColor*(rgb: uint): void =
    var r = (rgb shr 16).uint8
    var g = ((rgb shr 8) and 0x0000FF).uint8
    var b = (rgb and 0x0000FF).uint8
    TLN_SetBGColor(r, g, b)

proc setBgColor*(r: uint8, g: uint8, b: uint8): void =
    TLN_SetBGColor(r, g, b)

proc setBgColor*(self: Color): void =
    TLN_SetBGColor((self.r).uint8, (self.g).uint8, (self.b).uint8)

proc setBgColorFromTilemap*(self: TLN_Tilemap): bool =
    return TLN_SetBGColorFromTilemap(self)

proc disableBgColor*(): void =
    TLN_DisableBGColor()

proc setBgBitmap*(self: TLN_Bitmap): bool =
    return TLN_SetBGBitmap(self)

proc setBgPalette*(self: TLN_Palette): bool =
    return TLN_SetBGPalette(self)

# proc setRasterCallback*(self: TLN_VideoCallback): void =
#     TLN_SetRasterCallback(self)

proc cRasterCallback*(scanline: cint) {.cdecl.} =
  if not nimRasterCallback.isNil:
    nimRasterCallback(scanline)

proc setRasterCallback*(callback: proc (scanline: cint)) =
  nimRasterCallback = callback
  TLN_SetRasterCallback(cRasterCallback)

proc setFrameCallback*(self: TLN_VideoCallback): void =
    TLN_SetFrameCallback(self)

proc setRenderTarget*(data: ptr uint8, pitch: int): void =
    TLN_SetRenderTarget(data, pitch.cint)

proc updateFrame*(frame: int): void =
    TLN_UpdateFrame(frame.cint)

proc setLoadPath*(path: string): void = 
    TLN_SetLoadPath(path.cstring)

proc setCustomBlendFunc*(self: TLN_BlendFunction): void =
    TLN_SetCustomBlendFunction(self)

proc setLogLevel*(logLevel: LogLevel): void =
    TLN_SetLogLevel(logLevel.TLN_LogLevel)

proc openResPack*(file: string, key: string): bool =
    return TLN_OpenResourcePack(file, key)

proc closeResPack*(): void =
    TLN_CloseResourcePack()

proc deInit*(): void =
    TLN_DeInit()

proc getTicks*(): int =
    TLN_Getticks().int

proc delay*(delay: uint32): void =
    TLN_Delay(delay.cuint)

proc getScanline*(): int =
    TLN_GetScanline().int