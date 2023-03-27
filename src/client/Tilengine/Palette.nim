import Types
import TilengineBinding
import Math
import strutils

# PALETTE
proc createPalette*(entries: int): TLN_Palette =
    return TLN_CreatePalette(entries.cint)

proc loadPalette*(file: string): TLN_Palette =
    return TLN_LoadPalette(file.cstring)

proc clonePalette*(self: TLN_Palette): TLN_Palette =
    return TLN_ClonePalette(self)

proc setPaletteColor*(palette: TLN_Palette, index: int, r: uint8, g: uint8, b: uint8): bool =
    return TLN_SetPaletteColor(palette, index.cint, r, g, b)

proc setPaletteColor*(palette: TLN_Palette, index: int, rgb: uint): bool =
    var r = ((rgb shr 8) shr 8).uint8
    var g = ((rgb shr 8) and 0x0000FF).uint8
    var b = (rgb and 0x0000FF).uint8
    return TLN_SetPaletteColor(palette, index.cint, r, g, b)

proc setPaletteColorRGBA*(palette: TLN_Palette, index: int, rgb: uint): bool =
    var r = (rgb shr 24).uint8
    var g = ((rgb shr 16) and 0x000000FF).uint8
    var b = ((rgb shr 8)and 0x000000FF).uint8
    return TLN_SetPaletteColor(palette, index.cint, r, g, b)

proc setPaletteColor*(palette: TLN_Palette, index: int, color: Color): bool =
    return TLN_SetPaletteColor(palette, index.cint, color.r, color.g, color.b)

proc mixPalettes*(src1: TLN_Palette, src2: TLN_Palette, dest: TLN_Palette, factor: uint8): bool =
    return TLN_MixPalettes(src1, src2, dest, factor)

proc addPaletteColor*(palette: TLN_Palette, r: uint8, g: uint8, b: uint8, start: uint8, num: uint8): bool =
    return TLN_AddPaletteColor(palette, r, g, b, start, num)

proc addPaletteColor*(palette: TLN_Palette, rgb: uint, start: uint8, num: uint8): bool =
    var r = (rgb shr 16).uint8
    var g = ((rgb shr 8) and 0x0000FF).uint8
    var b = (rgb and 0x0000FF).uint8
    return TLN_AddPaletteColor(palette, r, g, b, start, num)

proc addPaletteColor*(palette: TLN_Palette, color: Color, start: uint8, num: uint8): bool =
    return TLN_AddPaletteColor(palette, color.r, color.g, color.b, start, num)

proc subPaletteColor*(palette: TLN_Palette, r: uint8, g: uint8, b: uint8, start: uint8, num: uint8): bool =
    return TLN_SubPaletteColor(palette, r, g, b, start, num)

proc subPaletteColor*(palette: TLN_Palette, rgb: uint, start: uint8, num: uint8): bool =
    var r = (rgb shr 16).uint8
    var g = ((rgb shr 8) and 0x0000FF).uint8
    var b = (rgb and 0x0000FF).uint8
    return TLN_SubPaletteColor(palette, r, g, b, start, num)

proc subPaletteColor*(palette: TLN_Palette, color: Color, start: uint8, num: uint8): bool =
    return TLN_SubPaletteColor(palette, color.r, color.g, color.b, start, num)

proc modPaletteColor*(palette: TLN_Palette, r: uint8, g: uint8, b: uint8, start: uint8, num: uint8): bool =
    return TLN_ModPaletteColor(palette, r, g, b, start, num)

proc modPaletteColor*(palette: TLN_Palette, rgb: uint, start: uint8, num: uint8): bool =
    var r = (rgb shr 16).uint8
    var g = ((rgb shr 8) and 0x0000FF).uint8
    var b = (rgb and 0x0000FF).uint8
    return TLN_ModPaletteColor(palette, r, g, b, start, num)

proc modPaletteColor*(palette: TLN_Palette, color: Color, start: uint8, num: uint8): bool =
    return TLN_ModPaletteColor(palette, color.r, color.g, color.b, start, num)

proc getPaletteData*(palette: TLN_Palette, index: int): ptr uint8 =
    return TLN_GetPaletteData(palette, index.cint)

proc deletePalette*(palette: TLN_Palette): bool =
    return TLN_DeletePalette(palette)

proc rgbCompToColor*(r: uint8, g: uint8, b: uint8): uint =
    var r2 = r.uint shl 16
    var g2 = g.uint shl 8
    return (r2 or g2 or b.uint).uint

proc setGlobalPal*(index: int, pal: TLN_Palette): bool =
    return TLN_SetGlobalPalette(index.cint, pal)

proc getGlobalPal*(index: int): TLN_Palette =
    return TLN_GetGlobalPalette(index.cint)

proc getPaletteColor*(palette: TLN_Palette, index: int): uint =
    var colorArray = getPaletteData(palette, index)
    # echo ("")
    if not (colorArray == nil):

        
        var r = (cast[ptr UncheckedArray[uint8]](colorArray)[2])
        var g = (cast[ptr UncheckedArray[uint8]](colorArray)[1])
        var b = (cast[ptr UncheckedArray[uint8]](colorArray)[0])
        return rgbCompToColor(r, g, b)
    # echo("Problem")
    # return 0x7FFFFFFF # If the index is nil, I return an impossible colorù
    # var ptrColor = getPaletteData(palette, index)
    # if not (ptrColor == nil):
    #     return (cast[ptr uint32](ptrColor)[]) shr 8 # PROBLEME
    return 0x7FFFFFFF # If the index is nil, I return an impossible color



type
    Palettes* = enum
        GB          # GameBoy
        VB          # VirtualBoy
        SMS         # SEGA Master System
        WEBSAFE     # Web Safe (6 levels palette)
        MEGADRIVE   # SEGA MegaDrive
        AMIGA       # Commodore AMIGA / GameGear
        SNES        # Super Nintendo / GameBoy Color / GBA
        ZXSPECTRUM  # ZX Spectrum



proc rgbToSystem*(rgb: uint, palette: Palettes = WEBSAFE, mult: uint8 = 3): uint =
    var r = (rgb shr 16).uint8
    var g = ((rgb shr 8) and 0x0000FF).uint8
    var b = (rgb and 0x0000FF).uint8

    if(palette == ZXSPECTRUM):
        r = round(r.float / 255).uint8 * 255
        g = round(g.float / 255).uint8 * 255
        b = round(b.float / 255).uint8 * 255

    if(palette == GB):
        var avg = round(((r.float + g.float + b.float) / 3)).uint8
        avg = ((avg div 85) * 85)
        return rgbCompToColor(avg, avg, avg)

    if(palette == VB):
        var avg = round(((r.float + g.float + b.float) / 3)).uint8
        avg = ((avg div 85) * 85)
        return rgbCompToColor(avg, 0, 0)

    if(palette == SMS):
        r = (r shr 6) * 85
        g = (g shr 6) * 85
        b = (b shr 6) * 85

    if(palette == WEBSAFE):
        r = round(r.float / 51).uint8 * 16 * mult
        g = round(g.float / 51).uint8 * 16 * mult
        b = round(b.float / 51).uint8 * 16 * mult

    if(palette == MEGADRIVE):
        r = (r shr 5) * 36
        g = (g shr 5) * 36
        b = (b shr 5) * 36

    if(palette == AMIGA):
        r = (r shr 4) * 17
        g = (g shr 4) * 17
        b = (b shr 4) * 17

    if(palette == SNES):
        r = (r shr 3) shl 3
        g = (g shr 3) shl 3
        b = (b shr 3) shl 3

    return rgbCompToColor(r, g, b)

# proc colorToSystem*(color: Color, palette: Palettes): Color =
    