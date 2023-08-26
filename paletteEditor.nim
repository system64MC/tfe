const PAL64_VER = 2 and 0x7F

import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]#, nimgl/imnodes
import nimgl/[opengl, glfw]
import tilengine/tilengine
import streams
import std/[math, os]
import strutils
import tinydialogs
import parseutils

proc store(fn: string, data: array[(384 * 216 * 4), byte]) =
  var s = newFileStream(fn, fmWrite)
#   s.write(data.len)
  for x in data:
    s.write(data[x])
  s.close()


type
  color = object
      r: int32
      g: int32
      b: int32
      nes: int32


var rawPalettes: array[16, array[16, color]]  # creates a 2D array with 16 rows and 16 columns
var displayPalettes: array[16, array[16, color]]  # creates a 2D array with 16 rows and 16 columns

var selectedPal: int32 = 0
var paletteMode : int32 = 0

type
  PalMode = enum
    RGB_332
    RGB_323
    RGB_233
    CPC
    SMS
    LEVELS_5
    WEBSAFE
    MEGADRIVE
    AMIGA
    SNES
    DS
    RGB_24
    NES

const nesArrROM: array[256, uint32] = [5592405.uint32, 6003, 1926, 3016056, 5833293, 7471121, 7208960, 4982784, 1514240, 10752, 12544, 11784, 9797, 0, 0, 0, 10855845, 22470, 2244581, 7219417, 11410086, 13768537, 13705479, 10958592, 6508800, 1599232, 29184, 29489, 27268, 0, 0, 0, 16711679, 3123455, 6128127, 10252543, 16216831, 16742333, 16744053, 16747051, 13475840, 8501250, 4048944, 1232251, 902608, 3947580, 0, 0, 16711679, 10804991, 11651327, 13418239, 16040703, 16762346, 16762825, 16764330, 15718038, 13688981, 11790245, 10480323, 10152166, 11513775, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var nesPalette: array[16, array[16, color]]

proc initPalettes() = 
  for i in 0..15:
    for j in 0..15:
      rawPalettes[j][i].r = 0
      rawPalettes[j][i].g = 0
      rawPalettes[j][i].b = 0
      rawPalettes[j][i].nes = 0

      
      
  if(paletteMode.PalMode != NES):
    for i in 0..15:
      for j in 0..15:
        displayPalettes[j][i].r = 0
        displayPalettes[j][i].g = 0
        displayPalettes[j][i].b = 0
        displayPalettes[j][i].nes = 0
    return

  for i in 0..15:
      for j in 0..15:
        displayPalettes[j][i].r = (nesArrROM[0] shr 16).int32
        displayPalettes[j][i].g = ((nesArrROM[0] shr 8) and 0xFF).int32
        displayPalettes[j][i].b = (nesArrROM[0] and 0xFF).int32
        displayPalettes[j][i].nes = 0


var tlnPalette = createPalette(16)

var selectedColor: uint8 = 00





proc translateColorToRGB24(x: uint8, y: uint8) = 
  case paletteMode.PalMode:
    of RGB_332:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 36.42).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 36.42).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 85).int32
    of RGB_323:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 36.42).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 85).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 36.42).int32
    of RGB_233:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 85).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 36.42).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 36.42).int32
    of CPC:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 127.5).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 127.5).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 127.5).int32
    of SMS:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 85).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 85).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 85).int32
    of LEVELS_5:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 63).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 63).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 63).int32
    of WEBSAFE:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 51).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 51).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 51).int32
    of MEGADRIVE:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 36).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 36).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 36).int32
    of AMIGA:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 15.9375).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 15.9375).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 15.9375).int32
    of SNES:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 8).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 8).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 8).int32
    of DS:
      displayPalettes[x][y].r = round(rawPalettes[x][y].r.float64 * 4.0476).int32
      displayPalettes[x][y].g = round(rawPalettes[x][y].g.float64 * 4.0476).int32
      displayPalettes[x][y].b = round(rawPalettes[x][y].b.float64 * 4.0476).int32
    of RGB24:
      displayPalettes[x][y].r = rawPalettes[x][y].r
      displayPalettes[x][y].g = rawPalettes[x][y].g
      displayPalettes[x][y].b = rawPalettes[x][y].b
    of NES:
      var nesX = rawPalettes[x][y].nes and 0xF
      var nesY = rawPalettes[x][y].nes shr 4
      displayPalettes[x][y].r = nesPalette[nesX][nesY].r
      displayPalettes[x][y].g = nesPalette[nesX][nesY].g
      displayPalettes[x][y].b = nesPalette[nesX][nesY].b
    else:
      displayPalettes[x][y].r = rawPalettes[x][y].r
      displayPalettes[x][y].g = rawPalettes[x][y].g
      displayPalettes[x][y].b = rawPalettes[x][y].b

var paletteList : array[13, cstring] = ["3-3-2 RGB".cstring, "3-2-3 RGB", "2-3-3 RGB", "CPC", "SMS", "5 Levels", "WEB", "MegaDrive", "Amiga", "SNES", "DS", "RGB24", "NES"]
var rLen : int32 = 7
var gLen : int32 = 7
var bLen : int32 = 3

var numPals : int32 = 16
var numColors : int32 = 16

var nesEmbedded = false

proc pushPaletteToTilengine(index: int32) = 
  for i in 0..15:
    if(i < numColors):
      tlnPalette.setColor(i, displayPalettes[i][index].r.uint8, displayPalettes[i][index].g.uint8, displayPalettes[i][index].b.uint8)
    elif(i >= numColors):
      tlnPalette.setColor(i, 0, 0, 0)
  setBgColor(displayPalettes[0][index].r.uint8, displayPalettes[0][index].g.uint8, displayPalettes[0][index].b.uint8)
  # echo Tlngeterrorstring(Tlngetlasterror())

proc initNESPalette() = 
  for i in 0..255:
    var x = i and 0xF
    var y = i shr 4
    nesPalette[x][y].r = (nesArrROM[i] shr 16).int32
    nesPalette[x][y].g = ((nesArrROM[i] shr 8) and 0xFF).int32
    nesPalette[x][y].b = (nesArrROM[i] and 0xFF).int32

# proc loadNESPal*(path: string): void =
#     let
#         file = open(path)
#         fSize = file.getFileSize()
#         fs = newFileStream(file)
#     defer: fs.close()
#     var data = newSeq[uint8](fSize)
#     discard fs.readData(data[0].addr, sizeof(uint8) * data.len)

#     for i in 0..255:
#         if(i >= data.len div 3):
#             var j = i * 3
#             var msb = data[j]
#             var mid = data[j + 1]
#             var lsb = data[j + 2]
#             nesPalette[i].r = msb.int32
#             nesPalette[i].g = mid.int32
#             nesPalette[i].b = lsb.int32
#             # var colVal = (msb.uint32 shl 16) or (mid.uint32 shl 8) or lsb.uint32
#             # nesLUT[i] = colVal
#         else:
#             nesPalette[i].r = 0
#             nesPalette[i].g = 0
#             nesPalette[i].b = 0

proc loadHexPal(path: string) =
  var str = readFile(path)
  var tmpArr = splitLines(str)
  var len  = tmpArr.len()
  for i in 0..255:
    var x = i and 0xF
    var y = i shr 4
    if(i < len):
      var num: int32 = 0
      discard parseHex(tmpArr[i], num)
      var r = num shr 16
      var g = (num shr 8) and 0xFF
      var b = num and 0xFF
      nesPalette[x][y].r = r
      nesPalette[x][y].g = g
      nesPalette[x][y].b = b
    else:
      nesPalette[x][y].r = 0
      nesPalette[x][y].g = 0
      nesPalette[x][y].b = 0

proc numberToColor(x: int, y: int, value: int32) =
  
  case paletteMode.PalMode:
    of RGB_332:
      rawPalettes[x][y].r = value shr 5
      rawPalettes[x][y].g = (value shr 2) and 0b111
      rawPalettes[x][y].b = value and 0b11
    of RGB_323:
      rawPalettes[x][y].r = value shr 5
      rawPalettes[x][y].g = (value shr 3) and 0b11
      rawPalettes[x][y].b = value and 0b111
    of RGB_233:
      rawPalettes[x][y].r = value shr 6
      rawPalettes[x][y].g = (value shr 3) and 0b111
      rawPalettes[x][y].b = value and 0b111
    of CPC:
      rawPalettes[x][y].r = value shr 4
      rawPalettes[x][y].g = (value shr 2) and 0b11
      rawPalettes[x][y].b = value and 0b11
    of SMS:
      rawPalettes[x][y].r = value shr 4
      rawPalettes[x][y].g = (value shr 2) and 0b11
      rawPalettes[x][y].b = value and 0b11
    of LEVELS_5:
      rawPalettes[x][y].r = value shr 6
      rawPalettes[x][y].g = (value shr 3) and 0b111
      rawPalettes[x][y].b = value and 0b111
    of WEBSAFE:
      rawPalettes[x][y].r = value shr 6
      rawPalettes[x][y].g = (value shr 3) and 0b111
      rawPalettes[x][y].b = value and 0b111
    of MEGADRIVE:
      rawPalettes[x][y].r = value shr 6
      rawPalettes[x][y].g = (value shr 3) and 0b111
      rawPalettes[x][y].b = value and 0b111
    of AMIGA:
      rawPalettes[x][y].r = value shr 8
      rawPalettes[x][y].g = (value shr 4) and 0xF
      rawPalettes[x][y].b = value and 0xF
    of SNES:
      rawPalettes[x][y].r = value shr 10
      rawPalettes[x][y].g = (value shr 5) and 0b11111
      rawPalettes[x][y].b = value and 0b11111
    of DS:
      rawPalettes[x][y].r = value shr 12
      rawPalettes[x][y].g = (value shr 6) and 0b111111
      rawPalettes[x][y].b = value and 0b111111
    of RGB_24:
      rawPalettes[x][y].r = value shr 16
      rawPalettes[x][y].g = (value shr 8) and 0xFF
      rawPalettes[x][y].b = value and 0xFF
    of NES:
      rawPalettes[x][y].nes = value
    else:
      rawPalettes[x][y].r = value shr 16
      rawPalettes[x][y].g = (value shr 8) and 0xFF
      rawPalettes[x][y].b = value and 0xFF
  

proc rawToNumber(x: int, y: int): int32 =
  var r = rawPalettes[x][y].r
  var g = rawPalettes[x][y].g
  var b = rawPalettes[x][y].b
  var outNum: int32 = 0

  case paletteMode.PalMode:
    of RGB_332:
      outNum = (r shl 5) or (g shl 2) or (b)
    of RGB_323:
      outNum = (r shl 5) or (g shl 3) or (b)
    of RGB_233:
      outNum = (r shl 6) or (g shl 3) or (b)
    of CPC:
      outNum = (r shl 4) or (g shl 2) or (b)
    of SMS:
      outNum = (r shl 4) or (g shl 2) or (b)
    of LEVELS_5:
      outNum = (r shl 6) or (g shl 3) or (b)
    of WEBSAFE:
      outNum = (r shl 6) or (g shl 3) or (b)
    of MEGADRIVE:
      outNum = (r shl 6) or (g shl 3) or (b)
    of AMIGA:
      outNum = (r shl 8) or (g shl 4) or (b)
    of SNES:
      outNum = (r shl 10) or (g shl 5) or (b)
    of DS:
      outNum = (r shl 12) or (g shl 6) or (b)
    of RGB_24:
      outNum = (r shl 16) or (g shl 8) or (b)
    of NES:
      outNum = rawPalettes[x][y].nes
    else:
      outNum = (r shl 16) or (g shl 8) or (b)
  
  return outNum

proc setPaletteLengths() =
  case paletteMode.PalMode:
    of RGB_332: # 3-3-2
      rLen = 7
      gLen = 7
      bLen = 3
    of RGB_323: # 3-2-3
      rLen = 7
      gLen = 3
      bLen = 7
    of RGB_233: # 2-3-3
      rLen = 3
      gLen = 7
      bLen = 7
    of CPC: # Amstrad CPC
      rLen = 2
      gLen = 2
      bLen = 2
    of SMS: # SMS
      rLen = 3
      gLen = 3
      bLen = 3
    of LEVELS_5: # 5 levels
      rLen = 4
      gLen = 4
      bLen = 4
    of WEBSAFE: # WEB
      rLen = 5
      gLen = 5
      bLen = 5
    of MEGADRIVE: # MD
      rLen = 7
      gLen = 7
      bLen = 7
    of AMIGA: # Amiga
      rLen = 15
      gLen = 15
      bLen = 15
    of SNES: # SNES
      rLen = 31
      gLen = 31
      bLen = 31
    of DS: # DS
      rLen = 63
      gLen = 63
      bLen = 63
    of RGB_24: # RGB24
      rLen = 255
      gLen = 255
      bLen = 255
    of NES: # NES
      rLen = 0
      gLen = 0
      bLen = 0
    else:
      rLen = 7
      gLen = 7
      bLen = 3

proc loadPalette(path: string) =
  if(path == ""): return
  let
    file = open(path)
    fSize = file.getFileSize()
    fs = newFileStream(file)
  defer: fs.close()
  var data = newSeq[uint8](fSize)
  discard fs.readData(data[0].addr, sizeof(uint8) * data.len)
  echo data

  if(data[0].char & data[1].char & data[2].char & data[3].char & data[4].char != "PAL64"):
    discard messageBox("Error", "This is not a PAL64 Palette!", DialogType.Ok, IconType.Error, Button.Yes)
    return

  var pointer = 5
  if((data[pointer] and 0b0111_1111) > PAL64_VER):
    discard messageBox("Error", "PAL64 version too new!!!", DialogType.Ok, IconType.Error, Button.Yes)
    return
  
  nesEmbedded = (data[pointer] shr 7).bool
  pointer.inc
  initPalettes()

  numColors = data[pointer].int32
  pointer.inc
  numPals = data[pointer].int32
  pointer.inc

  paletteMode = data[pointer].int32
  if(PAL64_VER < 2):
    if(paletteMode > 0): paletteMode += 3
  let loadedMode = paletteMode.PalMode
  pointer.inc

  # if(loadedMode == 0 or loadedMode == 1 or loadedMode == 9):
  #   for y in 0..numPals - 1:
  #     for x in 0..numColors - 1:
  #       var value = data[pointer].int32
  #       numberToColor(x, y, value)
  #       translateColorToRGB24(x.uint8, y.uint8)
  #       pointer.inc
  if(loadedMode < LEVELS_5 or loadedMode == NES):
    for y in 0..numPals - 1:
      for x in 0..numColors - 1:
        var value = data[pointer].int32
        numberToColor(x, y, value)
        translateColorToRGB24(x.uint8, y.uint8)
        pointer.inc
  elif(loadedMode >= LEVELS_5 and loadedMode < DS):
    for y in 0..numPals - 1:
      for x in 0..numColors - 1:
        var msb = data[pointer].int32
        var lsb = data[pointer + 1].int32
        var value = (msb shl 8) or lsb
        numberToColor(x, y, value)
        translateColorToRGB24(x.uint8, y.uint8)
        pointer += 2
  elif(loadedMode >= DS):
    for y in 0..numPals - 1:
      for x in 0..numColors - 1:
        var msb = data[pointer].int32
        var mid = data[pointer + 1].int32
        var lsb = data[pointer + 2].int32
        var value = (msb shl 16) or (mid shl 8) or lsb
        numberToColor(x, y, value)
        translateColorToRGB24(x.uint8, y.uint8)
        pointer += 3
  
  if(nesEmbedded and loadedMode == NES):
    for y in 0..15:
      for x in 0..15:
        if(pointer < data.len):
          nesPalette[x][y].r = data[pointer].int32
          pointer.inc
          nesPalette[x][y].g = data[pointer].int32
          pointer.inc
          nesPalette[x][y].b = data[pointer].int32
          pointer.inc
        else:
          nesPalette[x][y].r = 0
          nesPalette[x][y].g = 0
          nesPalette[x][y].b = 0
        translateColorToRGB24(x.uint8, y.uint8) 
    # Hacky bug fix = 
    pointer = 9
    for y in 0..numPals - 1:
      for x in 0..numColors - 1:
        var value = data[pointer].int32
        numberToColor(x, y, value)
        translateColorToRGB24(x.uint8, y.uint8)
        pointer.inc
  
  selectedPal = clamp(selectedPal, 0, numPals - 1)
  selectedColor = 0
  pushPaletteToTilengine(selectedPal)
  setPaletteLengths()
      
      



proc savePalette(path: string) =  
  var data: seq[byte]
  # Header
  data.add('P'.byte)
  data.add('A'.byte)
  data.add('L'.byte)
  data.add('6'.byte)
  data.add('4'.byte)
  
  # Is NES Palette embedded? And version
  data.add(PAL64_VER.byte or (nesEmbedded.byte shl 7))
  
  # Lenght and number of palettes
  data.add(numColors.byte)
  data.add(numPals.byte)

  # Palette type
  data.add(paletteMode.byte)
  let selPalMode = paletteMode.PalMode

  # Write palette data! Let's gooooo!
  if(selPalMode < LEVELS_5 or selPalMode == NES):
    for y in 0..numPals - 1:
      for x in 0..numColors - 1:
        var tmpColor = rawToNumber(x, y)
        data.add(tmpColor.byte)
  elif(selPalMode >= LEVELS_5 and selPalMode < DS):
    for y in 0..numPals - 1:
      for x in 0..numColors - 1:
        var tmpColor = rawToNumber(x, y)
        var msb = tmpColor shr 8
        var lsb = tmpColor and 0xFF
        data.add(msb.byte)
        data.add(lsb.byte)
  elif(selPalMode >= DS):
    for y in 0..numPals - 1:
      for x in 0..numColors - 1:
        var tmpColor = rawToNumber(x, y)
        var msb = tmpColor shr 16
        var mid = (tmpColor shr 8) and 0xFF
        var lsb = tmpColor and 0xFF
        data.add(msb.byte)
        data.add(mid.byte)
        data.add(lsb.byte)

  # If we ask to embed the NES palette into the PAL64, we do so...
  if(nesEmbedded and selPalMode == NES):
    for y in 0..15:
      for x in 0..15:
        data.add(nesPalette[x][y].r.byte)
        data.add(nesPalette[x][y].g.byte)
        data.add(nesPalette[x][y].b.byte)
  
  # Writing data to file
  var s = newFileStream(path, fmWrite)
  for x in data:
    s.write(x)
  s.close()
  
var e = init(384, 216, 1, 0, 0)

disableCrtEffect()
var tilemap: Tilemap = nil
var bitmap: Bitmap = nil

proc loadTmx(path : string) =
    if(tilemap != nil):
      tilemap.delete
    tilemap = loadTilemap(path, nil)
    # echo path
    # bg = loadTilemap(path, "layer")
    try:
      Layer(0).setTilemap(tilemap)
    except:
      discard messageBox("Error", "Error while loading Tilemap!!", DialogType.Ok, IconType.Error, Button.Yes)

    Layer(0).setPalette(tlnPalette)
    pushPaletteToTilengine(selectedPal)
    # echo tilemap.getTilemapTileset.setTilesetPalette(palettes[selectedPal])

proc loadImg(path : string) = 
    if(bitmap != nil):
      bitmap.delete()
    bitmap = loadBitmap(path)
    # discard image.deleteBitmap
    # image : Tlntilemap
    # image = img
    # discard getLayerBitmap(0).deleteBitmap
    try:
      Layer(0).setBitmap(bitmap)
    except:
      discard messageBox("Error", "Error while loading Image!!", DialogType.Ok, IconType.Error, Button.Yes)
    Layer(0).setPalette(tlnPalette)
    pushPaletteToTilengine(selectedPal)
    
    # echo image.setBitmapPalette(palettes[selectedPal])
    # discard getLayerBitmap(0).setBitmapPalette(palettes[selectedPal])
    # discard bg.getTilemapTileset.setTilesetPalette(palette[selectedPal])
  
proc loadAsset(path: string) =
  var f = splitFile(path)
  var p = splitPath(path)
  setLoadPath(p.head)
  if(f.ext == ".tmx"):
    loadTmx(p.tail)
  if(f.ext == ".png" or f.ext == ".bmp"):
    loadImg(p.tail)



proc main() =

  # var nodeContext = imnodesCreateContext()

  initNESPalette()
  initPalettes()
  pushPaletteToTilengine(selectedPal)
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
  var w: GLFWWindow = glfwCreateWindow(1280, 720)
  if w == nil:
    quit(-1)

  

  var mult: cint = 1

  w.makeContextCurrent()

  doAssert glInit()

  let context = igCreateContext()
  #let io = igGetIO()

  doAssert igGlfwInitForOpenGL(w, true)
  doAssert igOpenGL3Init()

  # var e = initEngine()
  # configCrtEffect()
  # var tilemap = loadTilemap("assets/tilemaps/level1.tmx", "layer")
  try:
    Layer(0).setTilemap(tilemap)
    Layer(0).setPosition(0, 32)
  except:
    discard

  var tex: array[(384 * 216 * 4), byte]

  var show_demo: bool = true
  var somefloat: float32 = 0.0f
  var counter: int32 = 0
  setRenderTarget(cast[ptr UncheckedArray[uint8]](tex[0].addr), 4 * 384)
  
  updateFrame(0)
  var myTextureId: Gluint
  echo(myTextureId)
  glGenTextures(1, myTextureId.addr)
  glBindTexture(GL_TEXTURE_2D, myTextureId)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST.ord)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST.ord)
  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_BGRA.ord,
    GLsizei(384),
    GLsizei(216),
    0,
    GL_BGRA,
    GL_UNSIGNED_BYTE,
    tex.addr
  )

  while not w.windowShouldClose:

    
    var style = igGetStyle()

    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    if(igBeginMainMenuBar()):
        if(igBeginMenu("File")):
            if(igBeginMenu("Load")):
              if(igMenuItem("Load asset to Tilengine")):
                var path = openFileDialog("Open TMX / PNG / BMP", getCurrentDir() / "\0", ["*.tmx", "*.png", "*.bmp"], "Tilemap or Image file")
                loadAsset(path)
              if(igMenuItem("Load Pal64 palette")):
                var path = openFileDialog("Open PAL64", getCurrentDir() / "\0", ["*.pal64"], "PAL64 palette file")
                loadPalette(path)
              if(igBeginMenu("NES palette")):
                if(igMenuItem("As binary")):
                  var path = openFileDialog("Open the file", getCurrentDir() / "\0", ["*.tmx", "*.png", "*.bmp"], "Tilemap or Image file")
                if(igMenuItem("As Hex list")):
                  var path = openFileDialog("Open the file", getCurrentDir() / "\0", ["*.hex"], "HEX text file")
                  loadHexPal(path)
                igEndMenu()
              igEndMenu()
            
            if(igMenuItem("Save PAL64 palette")):
                var path = saveFileDialog("Save PAL64", getCurrentDir() / "\0", ["*.pal64"], "PAL64 palette file")
                savePalette(path)
            igEndMenu()
        if(igBeginMenu("Zoom")):
            igSliderInt("Zoom", mult.addr, 1, 4)
            igEndMenu()
        if(igCombo("", paletteMode.addr, paletteList[0].addr, 13)):
            initPalettes()
            setPaletteLengths()
            pushPaletteToTilengine(selectedPal)
        igCheckbox("Embed NES Palette", nesEmbedded.addr)
    igEndMainMenuBar()

    # Simple window
    
    var pad = style.windowPadding
    style.windowPadding.x = 0
    style.windowPadding.y = 0
    if(igBegin(name = "Tilengine window", flags = (ImGuiWindowFlags.AlwaysAutoResize.int or 
                                                    ImGuiWindowFlags.NoResize.int or 
                                                    ImGuiWindowFlags.NoCollapse.int).ImGuiWindowFlags)):
        var posVec: ImVec2
        igGetCursorScreenPosNonUDT(posVec.addr)

        if(igIsWindowFocused() and igIsKeyDown(igGetKeyIndex(ImGUiKey.RightArrow))):
            # echo "Right"
            Layer(0).setPosition(Layer(0).getX() + 4, Layer(0).getY)
        if(igIsWindowFocused() and igIsKeyDown(igGetKeyIndex(ImGUiKey.LeftArrow))):
            # echo "Left"
            Layer(0).setPosition(Layer(0).getX() - 4, Layer(0).getY)
        if(igIsWindowFocused() and igIsKeyDown(igGetKeyIndex(ImGUiKey.UpArrow))):
            # echo "Up"
            Layer(0).setPosition(Layer(0).getX(), Layer(0).getY - 4)
        if(igIsWindowFocused() and igIsKeyDown(igGetKeyIndex(ImGUiKey.DownArrow))):
            # echo "Down"
            Layer(0).setPosition(Layer(0).getX(), Layer(0).getY + 4)

        # discard Layer(0).setPosition(round(posVec.x / mult.float32).int, round(posVec.y / mult.float32).int)
        # imnodesEditorContextSet(nodeContext)
        # imnodesSetCurrentContext(nodeContext)
        # imnodesBeginNodeEditor()
        # imnodesBeginNode(1)
        # imnodesBeginNodeTitleBar()
        # igText("Test")
        # imnodesEndNodeTitleBar() 
        # igSliderInt("", selectedPal.addr, 0, 16)
        # imnodesEndNode()
        # imnodesEndNodeEditor()

        updateFrame(0)

        glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_BGRA.ord,
        GLsizei(384),
        GLsizei(216),
        0,
        GL_BGRA,
        GL_UNSIGNED_BYTE,
        tex.addr
        )

        var myVec: ImVec2
        
        igGetItemRectMinNonUDT(myVec.addr)

        var sizX = igGetWindowWidth()
        var sizY = igGetWindowHeight()
        
        igImage(
            cast[ImTextureID](myTextureId),
            # ImVec2(x: 384 * (sizX / 384), y: 216 * (sizY / 216)),
            ImVec2(x: 384 * mult.float32, y: 216 * mult.float32),
            Imvec2(x: 0, y: 0), # uv0
            Imvec2(x: 1, y: 1), # uv1
            ImVec4(x: 1, y: 1, z: 1, w: 1), # tint color
            # ImVec4(x: 1, y: 1, z: 1, w: 0.5f) # border color
        )
        igEnd()
        style.windowPadding = pad
# proc igColorButton*(desc_id: cstring, col: ImVec4, flags: ImGuiColorEditFlags = 0.ImGuiColorEditFlags, size: ImVec2 = ImVec2(x: 0, y: 0).ImVec2): bool {.importc: "igColorButton".}

        if(igBegin(name = "Palette Editor", flags = (ImGuiWindowFlags.NoCollapse.int or ImGuiWindowFlags.AlwaysAutoResize.int).ImGuiWindowFlags)):
            var style = igGetStyle()
            var defColor = style.colors[ImGuiCol.FrameBg.int32]
            var x = selectedColor shr 4
            var y = selectedColor and 0xF
            for i in 0..numPals - 1:
              for j in 0..numColors - 1: 
                igSameLine()
                
                if(x.int == j and y.int == i):
                  style.colors[ImGuiCol.FrameBg.int32].x = 1
                  style.colors[ImGuiCol.FrameBg.int32].y = 1
                  style.colors[ImGuiCol.FrameBg.int32].z = 1
                  style.colors[ImGuiCol.FrameBg.int32].w = 1
                if (igColorButton(desc_id = ("colBut" & $i & "_" & $j).cstring, col = ImVec4(x: displayPalettes[j][i].r.float32 / 255, y: displayPalettes[j][i].g.float32 / 255, z: displayPalettes[j][i].b.float32 / 255, w: 1), size = ImVec2(x: 24, y: 24).ImVec2)):
                  # if(igBeginPopupContextWindow()):
                  #   igMenuItem($j & " " & $i)
                  # igEndPopup()
                  selectedColor = (j.uint8 shl 4) or i.uint8 
                  echo selectedColor.toHex()
                style.colors[ImGuiCol.FrameBg.int32] = defColor
              igNewLine()
            igEnd()
            

        if(igBegin(name = "Color picker", flags = (ImGuiWindowFlags.NoCollapse.int or ImGuiWindowFlags.NoResize.int).ImGuiWindowFlags)):
            igSetWindowSize("Color picker", ImVec2(x: 400, y: 400))
            var x = selectedColor shr 4
            var y = selectedColor and 0xF
            if(paletteMode.PalMode != NES):
              if(igSliderInt("Red##Slider", rawPalettes[x][y].r.addr, 0, rLen)):
                rawPalettes[x][y].r = clamp(rawPalettes[x][y].r, 0, rLen)
                translateColorToRGB24(x.uint8, y.uint8)
                pushPaletteToTilengine(selectedPal)
              if(igSliderInt("Green##Slider", rawPalettes[x][y].g.addr, 0, gLen)):
                rawPalettes[x][y].g = clamp(rawPalettes[x][y].g, 0, gLen)
                translateColorToRGB24(x.uint8, y.uint8)
                pushPaletteToTilengine(selectedPal)
              if(igSliderInt("Blue##Slider", rawPalettes[x][y].b.addr, 0, bLen)):
                rawPalettes[x][y].b = clamp(rawPalettes[x][y].b, 0, bLen)
                translateColorToRGB24(x.uint8, y.uint8)
                pushPaletteToTilengine(selectedPal)
            else:
              for i in 0..15:
                for j in 0..15:
                  igSameLine()
                  if (igColorButton(desc_id = ("NESBut" & $i & "_" & $j).cstring, col = ImVec4(x: nesPalette[j][i].r.float32 / 255, y: nesPalette[j][i].g.float32 / 255, z: nesPalette[j][i].b.float32 / 255, w: 1), size = ImVec2(x: 16, y: 16).ImVec2)):
                    rawPalettes[x][y].nes = (j or (i shl 4)).int32
                    translateColorToRGB24(x.uint8, y.uint8)
                    pushPaletteToTilengine(selectedPal)
                igNewLine()
            igEnd()


    if(igBegin(name = "General settings", flags = ImGuiWindowFlags.NoCollapse)):

        if(igSliderInt("Selected Palette", selectedPal.addr, 0, numPals - 1)):
          selectedPal = clamp(selectedPal, 0, numPals - 1)
          pushPaletteToTilengine(selectedPal)
        if(igSliderInt("Num. Palettes", numPals.addr, 1, 16)):
          numPals = clamp(numPals, 1, 16)
          selectedPal = clamp(selectedPal, 0, numPals - 1)
          
          selectedColor = 0
          pushPaletteToTilengine(selectedPal)

        if(igSliderInt("Num. Colors", numColors.addr, 1, 16)):
          numColors = clamp(numColors, 1, 16)

          selectedColor = 0
          pushPaletteToTilengine(selectedPal)

        igEnd()
    # End simple window

    igRender()
    # sleep(5)

    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    w.swapBuffers()
    glfwSwapInterval(1)

  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  w.destroyWindow()
  glfwTerminate()

main()