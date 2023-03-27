
from macros import hint

const
  Cwffullscreen*: cint = 1
const
  Cwfvsync*: cint = 2
const
  Cwfs1*: cint = 4
const
  Cwfs2*: cint = 8
const
  Cwfs3*: cint = 12
const
  Cwfs4*: cint = 16
const
  Cwfs5*: cint = 20
const
  Cwfnearest*: cint = 64
when not declared(Tlnblend):
  type
    Tlnblend* {.size: sizeof(cint).} = enum
      Blendnone = 0, Blendmix25 = 1, Blendmix50 = 2, Blendmix75 = 3,
      Blendadd = 4, Blendsub = 5, Blendmod = 6, Blendor = 7, Blendxor = 8,
      Blendnor = 9, Blendand = 10, Blendnand = 11, Blendcustom = 12,
      Maxblend = 13
else:
  static :
    hint("Declaration of " & "TLN_Blend" & " already exists, not redeclaring")
const
  Blendmix* = Blendmix50
when not declared(Tlncrt):
  type
    Tlncrt* {.size: sizeof(cint).} = enum
      Tlncrtslot = 0, Tlncrtaperture = 1, Tlncrtshadow = 2
else:
  static :
    hint("Declaration of " & "TLN_CRT" & " already exists, not redeclaring")
when not declared(Tlninput):
  type
    Tlninput* {.size: sizeof(cint).} = enum
      Inputnone = 0, Inputup = 1, Inputdown = 2, Inputleft = 3, Inputright = 4,
      Inputbutton1 = 5, Inputbutton2 = 6, Inputbutton3 = 7, Inputbutton4 = 8,
      Inputbutton5 = 9, Inputbutton6 = 10, Inputstart = 11, Inputquit = 12,
      Inputcrt = 13, Inputp2 = 32, Inputp3 = 64, Inputp4 = 96
else:
  static :
    hint("Declaration of " & "TLN_Input" & " already exists, not redeclaring")
const
  Inputp1* = Inputnone
const
  Inputa* = Inputbutton1
const
  Inputb* = Inputbutton2
const
  Inputc* = Inputbutton3
const
  Inputd* = Inputbutton4
const
  Inpute* = Inputbutton5
const
  Inputf* = Inputbutton6
when not declared(Tlnerror):
  type
    Tlnerror* {.size: sizeof(cint).} = enum
      Tlnerrok = 0, Tlnerroutofmemory = 1, Tlnerridxlayer = 2,
      Tlnerridxsprite = 3, Tlnerridxanimation = 4, Tlnerridxpicture = 5,
      Tlnerrreftileset = 6, Tlnerrreftilemap = 7, Tlnerrrefspriteset = 8,
      Tlnerrrefpalette = 9, Tlnerrrefsequence = 10, Tlnerrrefseqpack = 11,
      Tlnerrrefbitmap = 12, Tlnerrnullpointer = 13, Tlnerrfilenotfound = 14,
      Tlnerrwrongformat = 15, Tlnerrwrongsize = 16, Tlnerrunsupported = 17,
      Tlnerrreflist = 18, Tlnmaxerr = 19
else:
  static :
    hint("Declaration of " & "TLN_Error" & " already exists, not redeclaring")
when not declared(Tlnlayertype):
  type
    Tlnlayertype* {.size: sizeof(cint).} = enum
      Layernone = 0, Layertile = 1, Layerobject = 2, Layerbitmap = 3
else:
  static :
    hint("Declaration of " & "TLN_LayerType" &
        " already exists, not redeclaring")
when not declared(Tlnloglevel):
  type
    Tlnloglevel* {.size: sizeof(cint).} = enum
      Tlnlognone = 0, Tlnlogerrors = 1, Tlnlogverbose = 2
else:
  static :
    hint("Declaration of " & "TLN_LogLevel" & " already exists, not redeclaring")
when not declared(Tlntileflags):
  type
    Tlntileflags* {.size: sizeof(cint).} = enum
      Flagnone = 0, Flagtileset = 1792, Flagmasked = 2048, Flagpriority = 4096,
      Flagrotate = 8192, Flagflipy = 16384, Flagflipx = 32768
else:
  static :
    hint("Declaration of " & "TLN_TileFlags" &
        " already exists, not redeclaring")
when not declared(Tlnplayer):
  type
    Tlnplayer* {.size: sizeof(cint).} = enum
      Player1 = 0, Player2 = 1, Player3 = 2, Player4 = 3
else:
  static :
    hint("Declaration of " & "TLN_Player" & " already exists, not redeclaring")
when not declared(structtileset):
  type
    structtileset* = distinct object
else:
  static :
    hint("Declaration of " & "struct_Tileset" &
        " already exists, not redeclaring")
when not declared(structtilemap):
  type
    structtilemap* = distinct object
else:
  static :
    hint("Declaration of " & "struct_Tilemap" &
        " already exists, not redeclaring")
when not declared(structengine):
  type
    structengine* = distinct object
else:
  static :
    hint("Declaration of " & "struct_Engine" &
        " already exists, not redeclaring")
when not declared(structspriteset):
  type
    structspriteset* = distinct object
else:
  static :
    hint("Declaration of " & "struct_Spriteset" &
        " already exists, not redeclaring")
when not declared(structpalette):
  type
    structpalette* = distinct object
else:
  static :
    hint("Declaration of " & "struct_Palette" &
        " already exists, not redeclaring")
when not declared(unionsdlevent):
  type
    unionsdlevent* = distinct object
else:
  static :
    hint("Declaration of " & "union_SDL_Event" &
        " already exists, not redeclaring")
when not declared(structsequencepack):
  type
    structsequencepack* = distinct object
else:
  static :
    hint("Declaration of " & "struct_SequencePack" &
        " already exists, not redeclaring")
when not declared(structbitmap):
  type
    structbitmap* = distinct object
else:
  static :
    hint("Declaration of " & "struct_Bitmap" &
        " already exists, not redeclaring")
when not declared(structsequence):
  type
    structsequence* = distinct object
else:
  static :
    hint("Declaration of " & "struct_Sequence" &
        " already exists, not redeclaring")
when not declared(structobjectlist):
  type
    structobjectlist* = distinct object
else:
  static :
    hint("Declaration of " & "struct_ObjectList" &
        " already exists, not redeclaring")
type
  Tlnsequencepack_27263297* = ptr structsequencepack ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:267:30
  Tlntilemap_27263300* = ptr structtilemap ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:263:27
  Tlntileset_27263308* = ptr structtileset ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:262:27
  Tlnspriteinfo_27263310* = object
    w*: cint                 ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:190:9
    h*: cint

  Tlnbitmap_27263312* = ptr structbitmap ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:268:26
  Tlnpalette_27263314* = ptr structpalette ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:264:27
  Tlnvideocallback_27263316* = proc (a0: cint): void {.cdecl.} ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:298:15
  Tlnspriteset_27263318* = ptr structspriteset ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:265:28
  uniontile_27263320* {.union.} = object
    value*: uint32           ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:128:15
  
  Tlncolorstrip_27263322* = object
    delay*: cint             ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:161:9
    first*: uint8
    count*: uint8
    dir*: uint8

  Tlntile_27263324* = ptr uniontile_27263321 ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:261:24
  Tlnsequenceframe_27263326* = object
    index*: cint             ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:153:9
    delay*: cint

  Tlnobjectinfo_27263332* = object
    id*: uint16              ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:213:9
    gid*: uint16
    flags*: uint16
    x*: cint
    y*: cint
    width*: cint
    height*: cint
    typefield*: uint8
    visible*: bool
    name*: array[64'i64, cschar]

  Tlnaffine_27263334* = object
    angle*: cfloat           ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:117:9
    dx*: cfloat
    dy*: cfloat
    sx*: cfloat
    sy*: cfloat

  Tlntileimage_27263336* = object
    bitmap*: Tlnbitmap_27263313 ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:272:9
    id*: uint16
    typefield*: uint8

  Tile_27263338* = uniontile_27263321 ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:150:1
  Tlnengine_27263340* = ptr structengine ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:260:26
  Tlnobjectlist_27263342* = ptr structobjectlist ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:269:29
  Tlntileinfo_27263344* = object
    index*: uint16           ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:198:9
    flags*: uint16
    row*: cint
    col*: cint
    xoffset*: cint
    yoffset*: cint
    color*: uint8
    typefield*: uint8
    empty*: bool

  Tlnblendfunction_27263346* = proc (a0: uint8; a1: uint8): uint8 {.cdecl.} ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:299:18
  Tlnsequence_27263348* = ptr structsequence ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:266:27
  Tlntileattributes_27263350* = object
    typefield*: uint8        ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:229:9
    priority*: bool

  Tlnpixelmap_27263352* = object
    dx*: int16               ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:253:9
    dy*: int16

  Tlnsdlcallback_27263354* = proc (a0: ptr Sdlevent_27263359): void {.cdecl.} ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:300:15
  Tlnspritedata_27263356* = object
    name*: array[64'i64, cschar] ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:179:9
    x*: cint
    y*: cint
    w*: cint
    h*: cint

  Sdlevent_27263358* = unionsdlevent ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:297:25
  Tlnspritestate_27263362* = object
    x*: cint                 ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:281:9
    y*: cint
    w*: cint
    h*: cint
    flags*: uint32
    palette*: Tlnpalette_27263315
    spriteset*: Tlnspriteset_27263319
    index*: cint
    enabled*: bool
    collision*: bool

  Tlnsequenceinfo_27263373* = object
    name*: array[32'i64, cschar] ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:171:9
    numframes*: cint

  Tlnerror_27263329* = (when declared(Tlnerror):
    Tlnerror
   else:
    Tlnerror_27263328)
  Tlnsequencepack_27263299* = (when declared(Tlnsequencepack):
    Tlnsequencepack
   else:
    Tlnsequencepack_27263297)
  Tlntileinfo_27263345* = (when declared(Tlntileinfo):
    Tlntileinfo
   else:
    Tlntileinfo_27263344)
  Tlnsdlcallback_27263355* = (when declared(Tlnsdlcallback):
    Tlnsdlcallback
   else:
    Tlnsdlcallback_27263354)
  Tile_27263339* = (when declared(Tile):
    Tile
   else:
    Tile_27263338)
  Tlnspritedata_27263357* = (when declared(Tlnspritedata):
    Tlnspritedata
   else:
    Tlnspritedata_27263356)
  Tlninput_27263307* = (when declared(Tlninput):
    Tlninput
   else:
    Tlninput_27263306)
  Tlnspriteset_27263319* = (when declared(Tlnspriteset):
    Tlnspriteset
   else:
    Tlnspriteset_27263318)
  Tlntilemap_27263301* = (when declared(Tlntilemap):
    Tlntilemap
   else:
    Tlntilemap_27263300)
  uniontile_27263321* = (when declared(uniontile):
    uniontile
   else:
    uniontile_27263320)
  Tlntileset_27263309* = (when declared(Tlntileset):
    Tlntileset
   else:
    Tlntileset_27263308)
  Tlnblend_27263303* = (when declared(Tlnblend):
    Tlnblend
   else:
    Tlnblend_27263302)
  Sdlevent_27263359* = (when declared(Sdlevent):
    Sdlevent
   else:
    Sdlevent_27263358)
  Tlnspriteinfo_27263311* = (when declared(Tlnspriteinfo):
    Tlnspriteinfo
   else:
    Tlnspriteinfo_27263310)
  Tlncolorstrip_27263323* = (when declared(Tlncolorstrip):
    Tlncolorstrip
   else:
    Tlncolorstrip_27263322)
  Tlntile_27263325* = (when declared(Tlntile):
    Tlntile
   else:
    Tlntile_27263324)
  Tlncrt_27263305* = (when declared(Tlncrt):
    Tlncrt
   else:
    Tlncrt_27263304)
  Tlnengine_27263341* = (when declared(Tlnengine):
    Tlnengine
   else:
    Tlnengine_27263340)
  Tlnblendfunction_27263347* = (when declared(Tlnblendfunction):
    Tlnblendfunction
   else:
    Tlnblendfunction_27263346)
  Tlnloglevel_27263361* = (when declared(Tlnloglevel):
    Tlnloglevel
   else:
    Tlnloglevel_27263360)
  Tlnbitmap_27263313* = (when declared(Tlnbitmap):
    Tlnbitmap
   else:
    Tlnbitmap_27263312)
  Tlnlayertype_27263331* = (when declared(Tlnlayertype):
    Tlnlayertype
   else:
    Tlnlayertype_27263330)
  Tlnspritestate_27263363* = (when declared(Tlnspritestate):
    Tlnspritestate
   else:
    Tlnspritestate_27263362)
  Tlnobjectinfo_27263333* = (when declared(Tlnobjectinfo):
    Tlnobjectinfo
   else:
    Tlnobjectinfo_27263332)
  Tlntileflags_27263365* = (when declared(Tlntileflags):
    Tlntileflags
   else:
    Tlntileflags_27263364)
  Tlnsequence_27263349* = (when declared(Tlnsequence):
    Tlnsequence
   else:
    Tlnsequence_27263348)
  Tlntileattributes_27263351* = (when declared(Tlntileattributes):
    Tlntileattributes
   else:
    Tlntileattributes_27263350)
  Tlnsequenceinfo_27263374* = (when declared(Tlnsequenceinfo):
    Tlnsequenceinfo
   else:
    Tlnsequenceinfo_27263373)
  Tlnpalette_27263315* = (when declared(Tlnpalette):
    Tlnpalette
   else:
    Tlnpalette_27263314)
  Tlnaffine_27263335* = (when declared(Tlnaffine):
    Tlnaffine
   else:
    Tlnaffine_27263334)
  Tlnplayer_27263376* = (when declared(Tlnplayer):
    Tlnplayer
   else:
    Tlnplayer_27263375)
  Tlnpixelmap_27263353* = (when declared(Tlnpixelmap):
    Tlnpixelmap
   else:
    Tlnpixelmap_27263352)
  Tlnvideocallback_27263317* = (when declared(Tlnvideocallback):
    Tlnvideocallback
   else:
    Tlnvideocallback_27263316)
  Tlnobjectlist_27263343* = (when declared(Tlnobjectlist):
    Tlnobjectlist
   else:
    Tlnobjectlist_27263342)
  Tlntileimage_27263337* = (when declared(Tlntileimage):
    Tlntileimage
   else:
    Tlntileimage_27263336)
  Tlnsequenceframe_27263327* = (when declared(Tlnsequenceframe):
    Tlnsequenceframe
   else:
    Tlnsequenceframe_27263326)
when not declared(Tlnsequencepack):
  type
    Tlnsequencepack* = Tlnsequencepack_27263297
else:
  static :
    hint("Declaration of " & "TLN_SequencePack" &
        " already exists, not redeclaring")
when not declared(Tlntileinfo):
  type
    Tlntileinfo* = Tlntileinfo_27263344
else:
  static :
    hint("Declaration of " & "TLN_TileInfo" & " already exists, not redeclaring")
when not declared(Tlnsdlcallback):
  type
    Tlnsdlcallback* = Tlnsdlcallback_27263354
else:
  static :
    hint("Declaration of " & "TLN_SDLCallback" &
        " already exists, not redeclaring")
when not declared(Tile):
  type
    Tile* = Tile_27263338
else:
  static :
    hint("Declaration of " & "Tile" & " already exists, not redeclaring")
when not declared(Tlnspritedata):
  type
    Tlnspritedata* = Tlnspritedata_27263356
else:
  static :
    hint("Declaration of " & "TLN_SpriteData" &
        " already exists, not redeclaring")
when not declared(Tlnspriteset):
  type
    Tlnspriteset* = Tlnspriteset_27263318
else:
  static :
    hint("Declaration of " & "TLN_Spriteset" &
        " already exists, not redeclaring")
when not declared(Tlntilemap):
  type
    Tlntilemap* = Tlntilemap_27263300
else:
  static :
    hint("Declaration of " & "TLN_Tilemap" & " already exists, not redeclaring")
when not declared(uniontile):
  type
    uniontile* = uniontile_27263320
else:
  static :
    hint("Declaration of " & "union_Tile" & " already exists, not redeclaring")
when not declared(Tlntileset):
  type
    Tlntileset* = Tlntileset_27263308
else:
  static :
    hint("Declaration of " & "TLN_Tileset" & " already exists, not redeclaring")
when not declared(Sdlevent):
  type
    Sdlevent* = Sdlevent_27263358
else:
  static :
    hint("Declaration of " & "SDL_Event" & " already exists, not redeclaring")
when not declared(Tlnspriteinfo):
  type
    Tlnspriteinfo* = Tlnspriteinfo_27263310
else:
  static :
    hint("Declaration of " & "TLN_SpriteInfo" &
        " already exists, not redeclaring")
when not declared(Tlncolorstrip):
  type
    Tlncolorstrip* = Tlncolorstrip_27263322
else:
  static :
    hint("Declaration of " & "TLN_ColorStrip" &
        " already exists, not redeclaring")
when not declared(Tlntile):
  type
    Tlntile* = Tlntile_27263324
else:
  static :
    hint("Declaration of " & "TLN_Tile" & " already exists, not redeclaring")
when not declared(Tlnengine):
  type
    Tlnengine* = Tlnengine_27263340
else:
  static :
    hint("Declaration of " & "TLN_Engine" & " already exists, not redeclaring")
when not declared(Tlnblendfunction):
  type
    Tlnblendfunction* = Tlnblendfunction_27263346
else:
  static :
    hint("Declaration of " & "TLN_BlendFunction" &
        " already exists, not redeclaring")
when not declared(Tlnbitmap):
  type
    Tlnbitmap* = Tlnbitmap_27263312
else:
  static :
    hint("Declaration of " & "TLN_Bitmap" & " already exists, not redeclaring")
when not declared(Tlnspritestate):
  type
    Tlnspritestate* = Tlnspritestate_27263362
else:
  static :
    hint("Declaration of " & "TLN_SpriteState" &
        " already exists, not redeclaring")
when not declared(Tlnobjectinfo):
  type
    Tlnobjectinfo* = Tlnobjectinfo_27263332
else:
  static :
    hint("Declaration of " & "TLN_ObjectInfo" &
        " already exists, not redeclaring")
when not declared(Tlnsequence):
  type
    Tlnsequence* = Tlnsequence_27263348
else:
  static :
    hint("Declaration of " & "TLN_Sequence" & " already exists, not redeclaring")
when not declared(Tlntileattributes):
  type
    Tlntileattributes* = Tlntileattributes_27263350
else:
  static :
    hint("Declaration of " & "TLN_TileAttributes" &
        " already exists, not redeclaring")
when not declared(Tlnsequenceinfo):
  type
    Tlnsequenceinfo* = Tlnsequenceinfo_27263373
else:
  static :
    hint("Declaration of " & "TLN_SequenceInfo" &
        " already exists, not redeclaring")
when not declared(Tlnpalette):
  type
    Tlnpalette* = Tlnpalette_27263314
else:
  static :
    hint("Declaration of " & "TLN_Palette" & " already exists, not redeclaring")
when not declared(Tlnaffine):
  type
    Tlnaffine* = Tlnaffine_27263334
else:
  static :
    hint("Declaration of " & "TLN_Affine" & " already exists, not redeclaring")
when not declared(Tlnpixelmap):
  type
    Tlnpixelmap* = Tlnpixelmap_27263352
else:
  static :
    hint("Declaration of " & "TLN_PixelMap" & " already exists, not redeclaring")
when not declared(Tlnvideocallback):
  type
    Tlnvideocallback* = Tlnvideocallback_27263316
else:
  static :
    hint("Declaration of " & "TLN_VideoCallback" &
        " already exists, not redeclaring")
when not declared(Tlnobjectlist):
  type
    Tlnobjectlist* = Tlnobjectlist_27263342
else:
  static :
    hint("Declaration of " & "TLN_ObjectList" &
        " already exists, not redeclaring")
when not declared(Tlntileimage):
  type
    Tlntileimage* = Tlntileimage_27263336
else:
  static :
    hint("Declaration of " & "TLN_TileImage" &
        " already exists, not redeclaring")
when not declared(Tlnsequenceframe):
  type
    Tlnsequenceframe* = Tlnsequenceframe_27263326
else:
  static :
    hint("Declaration of " & "TLN_SequenceFrame" &
        " already exists, not redeclaring")
when not declared(Tlnprocesswindow):
  proc Tlnprocesswindow*(): bool {.cdecl, importc: "TLN_ProcessWindow".}
else:
  static :
    hint("Declaration of " & "TLN_ProcessWindow" &
        " already exists, not redeclaring")
when not declared(Tlnresetlayermode):
  proc Tlnresetlayermode*(nlayer: cint): bool {.cdecl,
      importc: "TLN_ResetLayerMode".}
else:
  static :
    hint("Declaration of " & "TLN_ResetLayerMode" &
        " already exists, not redeclaring")
when not declared(Tlnsetbgcolorfromtilemap):
  proc Tlnsetbgcolorfromtilemap*(tilemap: Tlntilemap_27263301): bool {.cdecl,
      importc: "TLN_SetBGColorFromTilemap".}
else:
  static :
    hint("Declaration of " & "TLN_SetBGColorFromTilemap" &
        " already exists, not redeclaring")
when not declared(Tlnclonespriteset):
  proc Tlnclonespriteset*(src: Tlnspriteset_27263319): Tlnspriteset_27263319 {.
      cdecl, importc: "TLN_CloneSpriteset".}
else:
  static :
    hint("Declaration of " & "TLN_CloneSpriteset" &
        " already exists, not redeclaring")
when not declared(Tlndeletecontext):
  proc Tlndeletecontext*(context: Tlnengine_27263341): bool {.cdecl,
      importc: "TLN_DeleteContext".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteContext" &
        " already exists, not redeclaring")
when not declared(Tlnsetrastercallback):
  proc Tlnsetrastercallback*(a0: Tlnvideocallback_27263317): void {.cdecl,
      importc: "TLN_SetRasterCallback".}
else:
  static :
    hint("Declaration of " & "TLN_SetRasterCallback" &
        " already exists, not redeclaring")
when not declared(Tlngetscanline):
  proc Tlngetscanline*(): cint {.cdecl, varargs, importc: "TLN_GetScanline".}
else:
  static :
    hint("Declaration of " & "TLN_GetScanline" &
        " already exists, not redeclaring")
when not declared(Tlnsettilesetpixels):
  proc Tlnsettilesetpixels*(tileset: Tlntileset_27263309; entry: cint;
                            srcdata: ptr uint8; srcpitch: cint): bool {.cdecl,
      importc: "TLN_SetTilesetPixels".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilesetPixels" &
        " already exists, not redeclaring")
when not declared(Tlngetsequencepackcount):
  proc Tlngetsequencepackcount*(sp: Tlnsequencepack_27263299): cint {.cdecl,
      importc: "TLN_GetSequencePackCount".}
else:
  static :
    hint("Declaration of " & "TLN_GetSequencePackCount" &
        " already exists, not redeclaring")
when not declared(Tlndisablelayermosaic):
  proc Tlndisablelayermosaic*(nlayer: cint): bool {.cdecl,
      importc: "TLN_DisableLayerMosaic".}
else:
  static :
    hint("Declaration of " & "TLN_DisableLayerMosaic" &
        " already exists, not redeclaring")
when not declared(Tlnsetsdlcallback):
  proc Tlnsetsdlcallback*(a0: Tlnsdlcallback_27263355): void {.cdecl,
      importc: "TLN_SetSDLCallback".}
else:
  static :
    hint("Declaration of " & "TLN_SetSDLCallback" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptileflipx):
  proc Tlnsettilemaptileflipx*(tilemap: Tlntilemap_27263301; row: cint;
                               col: cint; flip: bool): bool {.cdecl,
      importc: "TLN_SetTilemapTileFlipX".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTileFlipX" &
        " already exists, not redeclaring")
when not declared(Tlnenablecrteffect):
  proc Tlnenablecrteffect*(overlay: cint; overlayfactor: uint8;
                           threshold: uint8; v0: uint8; v1: uint8; v2: uint8;
                           v3: uint8; blur: bool; glowfactor: uint8): void {.
      cdecl, importc: "TLN_EnableCRTEffect".}
else:
  static :
    hint("Declaration of " & "TLN_EnableCRTEffect" &
        " already exists, not redeclaring")
when not declared(Tlngetspritestate):
  proc Tlngetspritestate*(nsprite: cint; state: ptr Tlnspritestate_27263363): bool {.
      cdecl, importc: "TLN_GetSpriteState".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpriteState" &
        " already exists, not redeclaring")
when not declared(Tlnpausespriteanimation):
  proc Tlnpausespriteanimation*(index: cint): bool {.cdecl,
      importc: "TLN_PauseSpriteAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_PauseSpriteAnimation" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerpriority):
  proc Tlnsetlayerpriority*(nlayer: cint; enable: bool): bool {.cdecl,
      importc: "TLN_SetLayerPriority".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerPriority" &
        " already exists, not redeclaring")
when not declared(Tlngetlayerwidth):
  proc Tlngetlayerwidth*(nlayer: cint): cint {.cdecl,
      importc: "TLN_GetLayerWidth".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerWidth" &
        " already exists, not redeclaring")
when not declared(Tlngetspritecollision):
  proc Tlngetspritecollision*(nsprite: cint): bool {.cdecl,
      importc: "TLN_GetSpriteCollision".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpriteCollision" &
        " already exists, not redeclaring")
when not declared(Tlngetnumobjects):
  proc Tlngetnumobjects*(): uint32 {.cdecl, importc: "TLN_GetNumObjects".}
else:
  static :
    hint("Declaration of " & "TLN_GetNumObjects" &
        " already exists, not redeclaring")
when not declared(Tlngeterrorstring):
  proc Tlngeterrorstring*(error: Tlnerror_27263329): cstring {.cdecl,
      importc: "TLN_GetErrorString".}
else:
  static :
    hint("Declaration of " & "TLN_GetErrorString" &
        " already exists, not redeclaring")
when not declared(Tlngetsequence):
  proc Tlngetsequence*(sp: Tlnsequencepack_27263299; index: cint): Tlnsequence_27263349 {.
      cdecl, importc: "TLN_GetSequence".}
else:
  static :
    hint("Declaration of " & "TLN_GetSequence" &
        " already exists, not redeclaring")
when not declared(Tlngetbitmapdepth):
  proc Tlngetbitmapdepth*(bitmap: Tlnbitmap_27263313): cint {.cdecl,
      importc: "TLN_GetBitmapDepth".}
else:
  static :
    hint("Declaration of " & "TLN_GetBitmapDepth" &
        " already exists, not redeclaring")
when not declared(Tlninit):
  proc Tlninit*(hres: cint; vres: cint; numlayers: cint; numsprites: cint;
                numanimations: cint): Tlnengine_27263341 {.cdecl,
      importc: "TLN_Init".}
else:
  static :
    hint("Declaration of " & "TLN_Init" & " already exists, not redeclaring")
when not declared(Tlndisablelayerparent):
  proc Tlndisablelayerparent*(nlayer: cint): bool {.cdecl,
      importc: "TLN_DisableLayerParent".}
else:
  static :
    hint("Declaration of " & "TLN_DisableLayerParent" &
        " already exists, not redeclaring")
when not declared(Tlngetavailableanimation):
  proc Tlngetavailableanimation*(): cint {.cdecl,
      importc: "TLN_GetAvailableAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_GetAvailableAnimation" &
        " already exists, not redeclaring")
when not declared(Tlnsetspritesetdata):
  proc Tlnsetspritesetdata*(spriteset: Tlnspriteset_27263319; entry: cint;
                            data: ptr Tlnspritedata_27263357; pixels: pointer;
                            pitch: cint): bool {.cdecl,
      importc: "TLN_SetSpritesetData".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpritesetData" &
        " already exists, not redeclaring")
when not declared(Tlngetpalettedata):
  proc Tlngetpalettedata*(palette: Tlnpalette_27263315; index: cint): ptr uint8 {.
      cdecl, importc: "TLN_GetPaletteData".}
else:
  static :
    hint("Declaration of " & "TLN_GetPaletteData" &
        " already exists, not redeclaring")
when not declared(Tlngetbitmappalette):
  proc Tlngetbitmappalette*(bitmap: Tlnbitmap_27263313): Tlnpalette_27263315 {.
      cdecl, importc: "TLN_GetBitmapPalette".}
else:
  static :
    hint("Declaration of " & "TLN_GetBitmapPalette" &
        " already exists, not redeclaring")
when not declared(Tlnmixpalettes):
  proc Tlnmixpalettes*(src1: Tlnpalette_27263315; src2: Tlnpalette_27263315;
                       dst: Tlnpalette_27263315; factor: uint8): bool {.cdecl,
      importc: "TLN_MixPalettes".}
else:
  static :
    hint("Declaration of " & "TLN_MixPalettes" &
        " already exists, not redeclaring")
when not declared(Tlngetlayertile):
  proc Tlngetlayertile*(nlayer: cint; x: cint; y: cint; info: ptr Tlntileinfo_27263345): bool {.
      cdecl, importc: "TLN_GetLayerTile".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerTile" &
        " already exists, not redeclaring")
when not declared(Tlnclonebitmap):
  proc Tlnclonebitmap*(src: Tlnbitmap_27263313): Tlnbitmap_27263313 {.cdecl,
      importc: "TLN_CloneBitmap".}
else:
  static :
    hint("Declaration of " & "TLN_CloneBitmap" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayertilemap):
  proc Tlnsetlayertilemap*(nlayer: cint; tilemap: Tlntilemap_27263301): bool {.
      cdecl, importc: "TLN_SetLayerTilemap".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerTilemap" &
        " already exists, not redeclaring")
when not declared(Tlnenablespriteflag):
  proc Tlnenablespriteflag*(nsprite: cint; flag: uint32; enable: bool): bool {.
      cdecl, importc: "TLN_EnableSpriteFlag".}
else:
  static :
    hint("Declaration of " & "TLN_EnableSpriteFlag" &
        " already exists, not redeclaring")
when not declared(Tlnenablespritemasking):
  proc Tlnenablespritemasking*(nsprite: cint; enable: bool): bool {.cdecl,
      importc: "TLN_EnableSpriteMasking".}
else:
  static :
    hint("Declaration of " & "TLN_EnableSpriteMasking" &
        " already exists, not redeclaring")
when not declared(Tlngettileheight):
  proc Tlngettileheight*(tileset: Tlntileset_27263309): cint {.cdecl,
      importc: "TLN_GetTileHeight".}
else:
  static :
    hint("Declaration of " & "TLN_GetTileHeight" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerpalette):
  proc Tlnsetlayerpalette*(nlayer: cint; palette: Tlnpalette_27263315): bool {.
      cdecl, importc: "TLN_SetLayerPalette".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerPalette" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptiletileset):
  proc Tlnsettilemaptiletileset*(tilemap: Tlntilemap_27263301; row: cint;
                                 col: cint; tileset: uint8): bool {.cdecl,
      importc: "TLN_SetTilemapTileTileset".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTileTileset" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptile):
  proc Tlnsettilemaptile*(tilemap: Tlntilemap_27263301; row: cint; col: cint;
                          tile: Tlntile_27263325): bool {.cdecl,
      importc: "TLN_SetTilemapTile".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTile" &
        " already exists, not redeclaring")
when not declared(Tlnsetspriteflags):
  proc Tlnsetspriteflags*(nsprite: cint; flags: uint32): bool {.cdecl,
      importc: "TLN_SetSpriteFlags".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpriteFlags" &
        " already exists, not redeclaring")
when not declared(Tlngetlayertype):
  proc Tlngetlayertype*(nlayer: cint): Tlnlayertype_27263331 {.cdecl,
      importc: "TLN_GetLayerType".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerType" &
        " already exists, not redeclaring")
when not declared(Tlngetlayerheight):
  proc Tlngetlayerheight*(nlayer: cint): cint {.cdecl,
      importc: "TLN_GetLayerHeight".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerHeight" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayeraffinetransform):
  proc Tlnsetlayeraffinetransform*(nlayer: cint; affine: ptr Tlnaffine_27263335): bool {.
      cdecl, importc: "TLN_SetLayerAffineTransform".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerAffineTransform" &
        " already exists, not redeclaring")
when not declared(Tlngetinput):
  proc Tlngetinput*(id: Tlninput_27263307): bool {.cdecl,
      importc: "TLN_GetInput".}
else:
  static :
    hint("Declaration of " & "TLN_GetInput" & " already exists, not redeclaring")
when not declared(Tlngetlayerbitmap):
  proc Tlngetlayerbitmap*(nlayer: cint): Tlnbitmap_27263313 {.cdecl,
      importc: "TLN_GetLayerBitmap".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerBitmap" &
        " already exists, not redeclaring")
when not declared(Tilenginevermin):
  const
    Tilenginevermin* = 11    ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:62:9
else:
  static :
    hint("Declaration of " & "TILENGINE_VER_MIN" &
        " already exists, not redeclaring")
when not declared(Tlngettilemaptile):
  proc Tlngettilemaptile*(tilemap: Tlntilemap_27263301; row: cint; col: cint;
                          tile: Tlntile_27263325): bool {.cdecl,
      importc: "TLN_GetTilemapTile".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapTile" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerposition):
  proc Tlnsetlayerposition*(nlayer: cint; hstart: cint; vstart: cint): bool {.
      cdecl, importc: "TLN_SetLayerPosition".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerPosition" &
        " already exists, not redeclaring")
when not declared(Tlngetcontext):
  proc Tlngetcontext*(): Tlnengine_27263341 {.cdecl, importc: "TLN_GetContext".}
else:
  static :
    hint("Declaration of " & "TLN_GetContext" &
        " already exists, not redeclaring")
when not declared(Tlnsetbgpalette):
  proc Tlnsetbgpalette*(palette: Tlnpalette_27263315): bool {.cdecl,
      importc: "TLN_SetBGPalette".}
else:
  static :
    hint("Declaration of " & "TLN_SetBGPalette" &
        " already exists, not redeclaring")
when not declared(Tlnsetloglevel):
  proc Tlnsetloglevel*(loglevel: Tlnloglevel_27263361): void {.cdecl,
      importc: "TLN_SetLogLevel".}
else:
  static :
    hint("Declaration of " & "TLN_SetLogLevel" &
        " already exists, not redeclaring")
when not declared(Tlncopytiles):
  proc Tlncopytiles*(src: Tlntilemap_27263301; srcrow: cint; srccol: cint;
                     rows: cint; cols: cint; dst: Tlntilemap_27263301;
                     dstrow: cint; dstcol: cint): bool {.cdecl,
      importc: "TLN_CopyTiles".}
else:
  static :
    hint("Declaration of " & "TLN_CopyTiles" &
        " already exists, not redeclaring")
when not declared(Tlnsetbgbitmap):
  proc Tlnsetbgbitmap*(bitmap: Tlnbitmap_27263313): bool {.cdecl,
      importc: "TLN_SetBGBitmap".}
else:
  static :
    hint("Declaration of " & "TLN_SetBGBitmap" &
        " already exists, not redeclaring")
when not declared(Tlncloseresourcepack):
  proc Tlncloseresourcepack*(): void {.cdecl, importc: "TLN_CloseResourcePack".}
else:
  static :
    hint("Declaration of " & "TLN_CloseResourcePack" &
        " already exists, not redeclaring")
when not declared(Tlndisablecrteffect):
  proc Tlndisablecrteffect*(): void {.cdecl, importc: "TLN_DisableCRTEffect".}
else:
  static :
    hint("Declaration of " & "TLN_DisableCRTEffect" &
        " already exists, not redeclaring")
when not declared(Tlnloadobjectlist):
  proc Tlnloadobjectlist*(filename: cstring; layername: cstring): Tlnobjectlist_27263343 {.
      cdecl, importc: "TLN_LoadObjectList".}
else:
  static :
    hint("Declaration of " & "TLN_LoadObjectList" &
        " already exists, not redeclaring")
when not declared(Tlndeletesequence):
  proc Tlndeletesequence*(sequence: Tlnsequence_27263349): bool {.cdecl,
      importc: "TLN_DeleteSequence".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteSequence" &
        " already exists, not redeclaring")
when not declared(Tlngettilewidth):
  proc Tlngettilewidth*(tileset: Tlntileset_27263309): cint {.cdecl,
      importc: "TLN_GetTileWidth".}
else:
  static :
    hint("Declaration of " & "TLN_GetTileWidth" &
        " already exists, not redeclaring")
when not declared(Tlnsetspriteanimation):
  proc Tlnsetspriteanimation*(nsprite: cint; sequence: Tlnsequence_27263349;
                              loop: cint): bool {.cdecl,
      importc: "TLN_SetSpriteAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpriteAnimation" &
        " already exists, not redeclaring")
when not declared(Tlnloadworld):
  proc Tlnloadworld*(tmxfile: cstring; firstlayer: cint): bool {.cdecl,
      importc: "TLN_LoadWorld".}
else:
  static :
    hint("Declaration of " & "TLN_LoadWorld" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerblendmode):
  proc Tlnsetlayerblendmode*(nlayer: cint; mode: Tlnblend_27263303;
                             factor: uint8): bool {.cdecl,
      importc: "TLN_SetLayerBlendMode".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerBlendMode" &
        " already exists, not redeclaring")
when not declared(Tlnsetpaletteanimationsource):
  proc Tlnsetpaletteanimationsource*(index: cint; a1: Tlnpalette_27263315): bool {.
      cdecl, importc: "TLN_SetPaletteAnimationSource".}
else:
  static :
    hint("Declaration of " & "TLN_SetPaletteAnimationSource" &
        " already exists, not redeclaring")
when not declared(Tilengineverrev):
  const
    Tilengineverrev* = 3     ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:63:9
else:
  static :
    hint("Declaration of " & "TILENGINE_VER_REV" &
        " already exists, not redeclaring")
when not declared(Tlndeletesequencepack):
  proc Tlndeletesequencepack*(sp: Tlnsequencepack_27263299): bool {.cdecl,
      importc: "TLN_DeleteSequencePack".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteSequencePack" &
        " already exists, not redeclaring")
when not declared(Tlndeletewindow):
  proc Tlndeletewindow*(): void {.cdecl, importc: "TLN_DeleteWindow".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteWindow" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerclip):
  proc Tlnsetlayerclip*(nlayer: cint; x1: cint; y1: cint; x2: cint; y2: cint): bool {.
      cdecl, importc: "TLN_SetLayerClip".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerClip" &
        " already exists, not redeclaring")
when not declared(Tlngetlayerpalette):
  proc Tlngetlayerpalette*(nlayer: cint): Tlnpalette_27263315 {.cdecl,
      importc: "TLN_GetLayerPalette".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerPalette" &
        " already exists, not redeclaring")
when not declared(Tlngetheight):
  proc Tlngetheight*(): cint {.cdecl, importc: "TLN_GetHeight".}
else:
  static :
    hint("Declaration of " & "TLN_GetHeight" &
        " already exists, not redeclaring")
when not declared(Tlngetlayertilemap):
  proc Tlngetlayertilemap*(nlayer: cint): Tlntilemap_27263301 {.cdecl,
      importc: "TLN_GetLayerTilemap".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerTilemap" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerparent):
  proc Tlnsetlayerparent*(nlayer: cint; parent: cint): bool {.cdecl,
      importc: "TLN_SetLayerParent".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerParent" &
        " already exists, not redeclaring")
when not declared(Tlndisablesprite):
  proc Tlndisablesprite*(nsprite: cint): bool {.cdecl,
      importc: "TLN_DisableSprite".}
else:
  static :
    hint("Declaration of " & "TLN_DisableSprite" &
        " already exists, not redeclaring")
when not declared(Tlngetspritepalette):
  proc Tlngetspritepalette*(nsprite: cint): Tlnpalette_27263315 {.cdecl,
      importc: "TLN_GetSpritePalette".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpritePalette" &
        " already exists, not redeclaring")
when not declared(Tlngettilemaptiledata):
  proc Tlngettilemaptiledata*(tilemap: Tlntilemap_27263301; row: cint; col: cint): uint32 {.
      cdecl, importc: "TLN_GetTilemapTileData".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapTileData" &
        " already exists, not redeclaring")
when not declared(Tlnloadpalette):
  proc Tlnloadpalette*(filename: cstring): Tlnpalette_27263315 {.cdecl,
      importc: "TLN_LoadPalette".}
else:
  static :
    hint("Declaration of " & "TLN_LoadPalette" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptileid):
  proc Tlnsettilemaptileid*(tilemap: Tlntilemap_27263301; row: cint; col: cint;
                            index: uint16): bool {.cdecl,
      importc: "TLN_SetTilemapTileID".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTileID" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptilemasked):
  proc Tlnsettilemaptilemasked*(tilemap: Tlntilemap_27263301; row: cint;
                                col: cint; masked: bool): bool {.cdecl,
      importc: "TLN_SetTilemapTileMasked".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTileMasked" &
        " already exists, not redeclaring")
when not declared(Tlnconfigcrteffect):
  proc Tlnconfigcrteffect*(typearg: Tlncrt_27263305; blur: bool): void {.cdecl,
      importc: "TLN_ConfigCRTEffect".}
else:
  static :
    hint("Declaration of " & "TLN_ConfigCRTEffect" &
        " already exists, not redeclaring")
when not declared(Tlnsetbitmappalette):
  proc Tlnsetbitmappalette*(bitmap: Tlnbitmap_27263313; palette: Tlnpalette_27263315): bool {.
      cdecl, importc: "TLN_SetBitmapPalette".}
else:
  static :
    hint("Declaration of " & "TLN_SetBitmapPalette" &
        " already exists, not redeclaring")
when not declared(Tlncreatepalette):
  proc Tlncreatepalette*(entries: cint): Tlnpalette_27263315 {.cdecl,
      importc: "TLN_CreatePalette".}
else:
  static :
    hint("Declaration of " & "TLN_CreatePalette" &
        " already exists, not redeclaring")
when not declared(Tlnenablelayer):
  proc Tlnenablelayer*(nlayer: cint): bool {.cdecl, importc: "TLN_EnableLayer".}
else:
  static :
    hint("Declaration of " & "TLN_EnableLayer" &
        " already exists, not redeclaring")
when not declared(Tlngetlayertileset):
  proc Tlngetlayertileset*(nlayer: cint): Tlntileset_27263309 {.cdecl,
      importc: "TLN_GetLayerTileset".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerTileset" &
        " already exists, not redeclaring")
when not declared(Tlnsetpaletteanimation):
  proc Tlnsetpaletteanimation*(index: cint; palette: Tlnpalette_27263315;
                               sequence: Tlnsequence_27263349; blend: bool): bool {.
      cdecl, importc: "TLN_SetPaletteAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_SetPaletteAnimation" &
        " already exists, not redeclaring")
when not declared(Tlncreateobjectlist):
  proc Tlncreateobjectlist*(): Tlnobjectlist_27263343 {.cdecl,
      importc: "TLN_CreateObjectList".}
else:
  static :
    hint("Declaration of " & "TLN_CreateObjectList" &
        " already exists, not redeclaring")
when not declared(Tlngetsequenceinfo):
  proc Tlngetsequenceinfo*(sequence: Tlnsequence_27263349;
                           info: ptr Tlnsequenceinfo_27263374): bool {.cdecl,
      importc: "TLN_GetSequenceInfo".}
else:
  static :
    hint("Declaration of " & "TLN_GetSequenceInfo" &
        " already exists, not redeclaring")
when not declared(Tlnoverlayshadowmask):
  const
    Tlnoverlayshadowmask* = 0 ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:238:9
else:
  static :
    hint("Declaration of " & "TLN_OVERLAY_SHADOWMASK" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerbitmap):
  proc Tlnsetlayerbitmap*(nlayer: cint; bitmap: Tlnbitmap_27263313): bool {.
      cdecl, importc: "TLN_SetLayerBitmap".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerBitmap" &
        " already exists, not redeclaring")
when not declared(Tlndelay):
  proc Tlndelay*(msecs: uint32): void {.cdecl, importc: "TLN_Delay".}
else:
  static :
    hint("Declaration of " & "TLN_Delay" & " already exists, not redeclaring")
when not declared(Tlngettilesetsequencepack):
  proc Tlngettilesetsequencepack*(tileset: Tlntileset_27263309): Tlnsequencepack_27263299 {.
      cdecl, importc: "TLN_GetTilesetSequencePack".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilesetSequencePack" &
        " already exists, not redeclaring")
when not declared(Tlngetlistobject):
  proc Tlngetlistobject*(list: Tlnobjectlist_27263343; info: ptr Tlnobjectinfo_27263333): bool {.
      cdecl, importc: "TLN_GetListObject".}
else:
  static :
    hint("Declaration of " & "TLN_GetListObject" &
        " already exists, not redeclaring")
when not declared(Tlngettilesetpalette):
  proc Tlngettilesetpalette*(tileset: Tlntileset_27263309): Tlnpalette_27263315 {.
      cdecl, importc: "TLN_GetTilesetPalette".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilesetPalette" &
        " already exists, not redeclaring")
when not declared(Tlngetlasterror):
  proc Tlngetlasterror*(): Tlnerror_27263329 {.cdecl,
      importc: "TLN_GetLastError".}
else:
  static :
    hint("Declaration of " & "TLN_GetLastError" &
        " already exists, not redeclaring")
when not declared(Tlnaddsequencetopack):
  proc Tlnaddsequencetopack*(sp: Tlnsequencepack_27263299; sequence: Tlnsequence_27263349): bool {.
      cdecl, importc: "TLN_AddSequenceToPack".}
else:
  static :
    hint("Declaration of " & "TLN_AddSequenceToPack" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptileset):
  proc Tlnsettilemaptileset*(tilemap: Tlntilemap_27263301; tileset: Tlntileset_27263309): bool {.
      cdecl, importc: "TLN_SetTilemapTileset".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTileset" &
        " already exists, not redeclaring")
when not declared(Tlnsetnextsprite):
  proc Tlnsetnextsprite*(nsprite: cint; next: cint): bool {.cdecl,
      importc: "TLN_SetNextSprite".}
else:
  static :
    hint("Declaration of " & "TLN_SetNextSprite" &
        " already exists, not redeclaring")
when not declared(Tlnsetbgcolor):
  proc Tlnsetbgcolor*(r: uint8; g: uint8; b: uint8): void {.cdecl,
      importc: "TLN_SetBGColor".}
else:
  static :
    hint("Declaration of " & "TLN_SetBGColor" &
        " already exists, not redeclaring")
when not declared(Tlnresumespriteanimation):
  proc Tlnresumespriteanimation*(index: cint): bool {.cdecl,
      importc: "TLN_ResumeSpriteAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_ResumeSpriteAnimation" &
        " already exists, not redeclaring")
when not declared(Tlnsetrendertarget):
  proc Tlnsetrendertarget*(data: ptr uint8; pitch: cint): void {.cdecl,
      importc: "TLN_SetRenderTarget".}
else:
  static :
    hint("Declaration of " & "TLN_SetRenderTarget" &
        " already exists, not redeclaring")
when not declared(Tlnloadspriteset):
  proc Tlnloadspriteset*(name: cstring): Tlnspriteset_27263319 {.cdecl,
      importc: "TLN_LoadSpriteset".}
else:
  static :
    hint("Declaration of " & "TLN_LoadSpriteset" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptileflipy):
  proc Tlnsettilemaptileflipy*(tilemap: Tlntilemap_27263301; row: cint;
                               col: cint; flip: bool): bool {.cdecl,
      importc: "TLN_SetTilemapTileFlipY".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTileFlipY" &
        " already exists, not redeclaring")
when not declared(Tlngetnumsprites):
  proc Tlngetnumsprites*(): cint {.cdecl, importc: "TLN_GetNumSprites".}
else:
  static :
    hint("Declaration of " & "TLN_GetNumSprites" &
        " already exists, not redeclaring")
when not declared(Tlnmodpalettecolor):
  proc Tlnmodpalettecolor*(palette: Tlnpalette_27263315; r: uint8; g: uint8;
                           b: uint8; start: uint8; num: uint8): bool {.cdecl,
      importc: "TLN_ModPaletteColor".}
else:
  static :
    hint("Declaration of " & "TLN_ModPaletteColor" &
        " already exists, not redeclaring")
when not declared(Tlngetbitmappitch):
  proc Tlngetbitmappitch*(bitmap: Tlnbitmap_27263313): cint {.cdecl,
      importc: "TLN_GetBitmapPitch".}
else:
  static :
    hint("Declaration of " & "TLN_GetBitmapPitch" &
        " already exists, not redeclaring")
when not declared(Tlngettilemaptileid):
  proc Tlngettilemaptileid*(tilemap: Tlntilemap_27263301; row: cint; col: cint): cint {.
      cdecl, importc: "TLN_GetTilemapTileID".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapTileID" &
        " already exists, not redeclaring")
when not declared(Tlnwaitredraw):
  proc Tlnwaitredraw*(): void {.cdecl, importc: "TLN_WaitRedraw".}
else:
  static :
    hint("Declaration of " & "TLN_WaitRedraw" &
        " already exists, not redeclaring")
when not declared(Tlngetlayerobjects):
  proc Tlngetlayerobjects*(nlayer: cint): Tlnobjectlist_27263343 {.cdecl,
      importc: "TLN_GetLayerObjects".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerObjects" &
        " already exists, not redeclaring")
when not declared(Tlndisablepaletteanimation):
  proc Tlndisablepaletteanimation*(index: cint): bool {.cdecl,
      importc: "TLN_DisablePaletteAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_DisablePaletteAnimation" &
        " already exists, not redeclaring")
when not declared(Tlnsetspritepicture):
  proc Tlnsetspritepicture*(nsprite: cint; entry: cint): bool {.cdecl,
      importc: "TLN_SetSpritePicture".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpritePicture" &
        " already exists, not redeclaring")
when not declared(Tlndisablebgcolor):
  proc Tlndisablebgcolor*(): void {.cdecl, importc: "TLN_DisableBGColor".}
else:
  static :
    hint("Declaration of " & "TLN_DisableBGColor" &
        " already exists, not redeclaring")
when not declared(Tlnsetspriteposition):
  proc Tlnsetspriteposition*(nsprite: cint; x: cint; y: cint): bool {.cdecl,
      importc: "TLN_SetSpritePosition".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpritePosition" &
        " already exists, not redeclaring")
when not declared(Tlncreatesequence):
  proc Tlncreatesequence*(name: cstring; target: cint; numframes: cint;
                          frames: ptr Tlnsequenceframe_27263327): Tlnsequence_27263349 {.
      cdecl, importc: "TLN_CreateSequence".}
else:
  static :
    hint("Declaration of " & "TLN_CreateSequence" &
        " already exists, not redeclaring")
when not declared(Tlndisableanimation):
  proc Tlndisableanimation*(index: cint): bool {.cdecl,
      importc: "TLN_DisableAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_DisableAnimation" &
        " already exists, not redeclaring")
when not declared(Tlniswindowactive):
  proc Tlniswindowactive*(): bool {.cdecl, importc: "TLN_IsWindowActive".}
else:
  static :
    hint("Declaration of " & "TLN_IsWindowActive" &
        " already exists, not redeclaring")
when not declared(Tlnsetanimationdelay):
  proc Tlnsetanimationdelay*(index: cint; frame: cint; delay: cint): bool {.
      cdecl, importc: "TLN_SetAnimationDelay".}
else:
  static :
    hint("Declaration of " & "TLN_SetAnimationDelay" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerpixelmapping):
  proc Tlnsetlayerpixelmapping*(nlayer: cint; table: ptr Tlnpixelmap_27263353): bool {.
      cdecl, importc: "TLN_SetLayerPixelMapping".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerPixelMapping" &
        " already exists, not redeclaring")
when not declared(Tlnreleaseworld):
  proc Tlnreleaseworld*(): void {.cdecl, importc: "TLN_ReleaseWorld".}
else:
  static :
    hint("Declaration of " & "TLN_ReleaseWorld" &
        " already exists, not redeclaring")
when not declared(Tlnsetspritepivot):
  proc Tlnsetspritepivot*(nsprite: cint; px: cfloat; py: cfloat): bool {.cdecl,
      importc: "TLN_SetSpritePivot".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpritePivot" &
        " already exists, not redeclaring")
when not declared(Tlndeleteobjectlist):
  proc Tlndeleteobjectlist*(list: Tlnobjectlist_27263343): bool {.cdecl,
      importc: "TLN_DeleteObjectList".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteObjectList" &
        " already exists, not redeclaring")
when not declared(Tlnopenresourcepack):
  proc Tlnopenresourcepack*(filename: cstring; key: cstring): bool {.cdecl,
      importc: "TLN_OpenResourcePack".}
else:
  static :
    hint("Declaration of " & "TLN_OpenResourcePack" &
        " already exists, not redeclaring")
when not declared(Tlnsetlasterror):
  proc Tlnsetlasterror*(error: Tlnerror_27263329): void {.cdecl,
      importc: "TLN_SetLastError".}
else:
  static :
    hint("Declaration of " & "TLN_SetLastError" &
        " already exists, not redeclaring")
when not declared(Tlnsetspriteworldposition):
  proc Tlnsetspriteworldposition*(nsprite: cint; x: cint; y: cint): bool {.
      cdecl, importc: "TLN_SetSpriteWorldPosition".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpriteWorldPosition" &
        " already exists, not redeclaring")
when not declared(Tlnfindsequence):
  proc Tlnfindsequence*(sp: Tlnsequencepack_27263299; name: cstring): Tlnsequence_27263349 {.
      cdecl, importc: "TLN_FindSequence".}
else:
  static :
    hint("Declaration of " & "TLN_FindSequence" &
        " already exists, not redeclaring")
when not declared(Tlngettilesetnumtiles):
  proc Tlngettilesetnumtiles*(tileset: Tlntileset_27263309): cint {.cdecl,
      importc: "TLN_GetTilesetNumTiles".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilesetNumTiles" &
        " already exists, not redeclaring")
when not declared(Tlngetspriteinfo):
  proc Tlngetspriteinfo*(spriteset: Tlnspriteset_27263319; entry: cint;
                         info: ptr Tlnspriteinfo_27263311): bool {.cdecl,
      importc: "TLN_GetSpriteInfo".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpriteInfo" &
        " already exists, not redeclaring")
when not declared(Tlngetspritesetpalette):
  proc Tlngetspritesetpalette*(spriteset: Tlnspriteset_27263319): Tlnpalette_27263315 {.
      cdecl, importc: "TLN_GetSpritesetPalette".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpritesetPalette" &
        " already exists, not redeclaring")
when not declared(Tlngetspritepicture):
  proc Tlngetspritepicture*(nsprite: cint): cint {.cdecl,
      importc: "TLN_GetSpritePicture".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpritePicture" &
        " already exists, not redeclaring")
when not declared(Tlncloneobjectlist):
  proc Tlncloneobjectlist*(src: Tlnobjectlist_27263343): Tlnobjectlist_27263343 {.
      cdecl, importc: "TLN_CloneObjectList".}
else:
  static :
    hint("Declaration of " & "TLN_CloneObjectList" &
        " already exists, not redeclaring")
when not declared(Tlnclonesequence):
  proc Tlnclonesequence*(src: Tlnsequence_27263349): Tlnsequence_27263349 {.
      cdecl, importc: "TLN_CloneSequence".}
else:
  static :
    hint("Declaration of " & "TLN_CloneSequence" &
        " already exists, not redeclaring")
when not declared(Tlngetnumlayers):
  proc Tlngetnumlayers*(): cint {.cdecl, importc: "TLN_GetNumLayers".}
else:
  static :
    hint("Declaration of " & "TLN_GetNumLayers" &
        " already exists, not redeclaring")
when not declared(Tlnloadbitmap):
  proc Tlnloadbitmap*(filename: cstring): Tlnbitmap_27263313 {.cdecl,
      importc: "TLN_LoadBitmap".}
else:
  static :
    hint("Declaration of " & "TLN_LoadBitmap" &
        " already exists, not redeclaring")
when not declared(Tlndeletepalette):
  proc Tlndeletepalette*(palette: Tlnpalette_27263315): bool {.cdecl,
      importc: "TLN_DeletePalette".}
else:
  static :
    hint("Declaration of " & "TLN_DeletePalette" &
        " already exists, not redeclaring")
when not declared(Tlngetlistnumobjects):
  proc Tlngetlistnumobjects*(list: Tlnobjectlist_27263343): cint {.cdecl,
      importc: "TLN_GetListNumObjects".}
else:
  static :
    hint("Declaration of " & "TLN_GetListNumObjects" &
        " already exists, not redeclaring")
when not declared(Tlnfindspritesetsprite):
  proc Tlnfindspritesetsprite*(spriteset: Tlnspriteset_27263319; name: cstring): cint {.
      cdecl, importc: "TLN_FindSpritesetSprite".}
else:
  static :
    hint("Declaration of " & "TLN_FindSpritesetSprite" &
        " already exists, not redeclaring")
when not declared(Tilenginevermaj):
  const
    Tilenginevermaj* = 2     ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:61:9
else:
  static :
    hint("Declaration of " & "TILENGINE_VER_MAJ" &
        " already exists, not redeclaring")
when not declared(Tlnclonepalette):
  proc Tlnclonepalette*(src: Tlnpalette_27263315): Tlnpalette_27263315 {.cdecl,
      importc: "TLN_ClonePalette".}
else:
  static :
    hint("Declaration of " & "TLN_ClonePalette" &
        " already exists, not redeclaring")
when not declared(Tlngetbitmapptr):
  proc Tlngetbitmapptr*(bitmap: Tlnbitmap_27263313; x: cint; y: cint): ptr uint8 {.
      cdecl, importc: "TLN_GetBitmapPtr".}
else:
  static :
    hint("Declaration of " & "TLN_GetBitmapPtr" &
        " already exists, not redeclaring")
when not declared(Tlncreatetilemap):
  proc Tlncreatetilemap*(rows: cint; cols: cint; tiles: Tlntile_27263325;
                         bgcolor: uint32; tileset: Tlntileset_27263309): Tlntilemap_27263301 {.
      cdecl, importc: "TLN_CreateTilemap".}
else:
  static :
    hint("Declaration of " & "TLN_CreateTilemap" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerscaling):
  proc Tlnsetlayerscaling*(nlayer: cint; xfactor: cfloat; yfactor: cfloat): bool {.
      cdecl, importc: "TLN_SetLayerScaling".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerScaling" &
        " already exists, not redeclaring")
when not declared(Tlnclonetileset):
  proc Tlnclonetileset*(src: Tlntileset_27263309): Tlntileset_27263309 {.cdecl,
      importc: "TLN_CloneTileset".}
else:
  static :
    hint("Declaration of " & "TLN_CloneTileset" &
        " already exists, not redeclaring")
when not declared(Tlnoverlaycustom):
  const
    Tlnoverlaycustom* = 0    ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:241:9
else:
  static :
    hint("Declaration of " & "TLN_OVERLAY_CUSTOM" &
        " already exists, not redeclaring")
when not declared(Tlngetwidth):
  proc Tlngetwidth*(): cint {.cdecl, importc: "TLN_GetWidth".}
else:
  static :
    hint("Declaration of " & "TLN_GetWidth" & " already exists, not redeclaring")
when not declared(Tlnsetlayerobjects):
  proc Tlnsetlayerobjects*(nlayer: cint; objects: Tlnobjectlist_27263343;
                           tileset: Tlntileset_27263309): bool {.cdecl,
      importc: "TLN_SetLayerObjects".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerObjects" &
        " already exists, not redeclaring")
when not declared(Tlncreatebitmap):
  proc Tlncreatebitmap*(width: cint; height: cint; bpp: cint): Tlnbitmap_27263313 {.
      cdecl, importc: "TLN_CreateBitmap".}
else:
  static :
    hint("Declaration of " & "TLN_CreateBitmap" &
        " already exists, not redeclaring")
when not declared(Tlnupdateframe):
  proc Tlnupdateframe*(frame: cint): void {.cdecl, importc: "TLN_UpdateFrame".}
else:
  static :
    hint("Declaration of " & "TLN_UpdateFrame" &
        " already exists, not redeclaring")
when not declared(Tlnassigninputjoystick):
  proc Tlnassigninputjoystick*(player: Tlnplayer_27263376; index: cint): void {.
      cdecl, importc: "TLN_AssignInputJoystick".}
else:
  static :
    hint("Declaration of " & "TLN_AssignInputJoystick" &
        " already exists, not redeclaring")
when not declared(Tlnloadtilemap):
  proc Tlnloadtilemap*(filename: cstring; layername: cstring): Tlntilemap_27263301 {.
      cdecl, importc: "TLN_LoadTilemap".}
else:
  static :
    hint("Declaration of " & "TLN_LoadTilemap" &
        " already exists, not redeclaring")
when not declared(Tlngetlayerposy):
  proc Tlngetlayerposy*(nlayer: cint): cint {.cdecl, importc: "TLN_GetLayerPosY".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerPosY" &
        " already exists, not redeclaring")
when not declared(Tlngetbitmapwidth):
  proc Tlngetbitmapwidth*(bitmap: Tlnbitmap_27263313): cint {.cdecl,
      importc: "TLN_GetBitmapWidth".}
else:
  static :
    hint("Declaration of " & "TLN_GetBitmapWidth" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayertransform):
  proc Tlnsetlayertransform*(layer: cint; angle: cfloat; dx: cfloat; dy: cfloat;
                             sx: cfloat; sy: cfloat): bool {.cdecl,
      importc: "TLN_SetLayerTransform".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerTransform" &
        " already exists, not redeclaring")
when not declared(Tlngetavailablesprite):
  proc Tlngetavailablesprite*(): cint {.cdecl, importc: "TLN_GetAvailableSprite".}
else:
  static :
    hint("Declaration of " & "TLN_GetAvailableSprite" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayerparallaxfactor):
  proc Tlnsetlayerparallaxfactor*(nlayer: cint; x: cfloat; y: cfloat): bool {.
      cdecl, importc: "TLN_SetLayerParallaxFactor".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerParallaxFactor" &
        " already exists, not redeclaring")
when not declared(Tlncreatewindow):
  proc Tlncreatewindow*(overlay: cstring; flags: cint): bool {.cdecl,
      importc: "TLN_CreateWindow".}
else:
  static :
    hint("Declaration of " & "TLN_CreateWindow" &
        " already exists, not redeclaring")
when not declared(Tlngetanimationstate):
  proc Tlngetanimationstate*(index: cint): bool {.cdecl,
      importc: "TLN_GetAnimationState".}
else:
  static :
    hint("Declaration of " & "TLN_GetAnimationState" &
        " already exists, not redeclaring")
when not declared(Tlncreatetileset):
  proc Tlncreatetileset*(numtiles: cint; width: cint; height: cint;
                         palette: Tlnpalette_27263315; sp: Tlnsequencepack_27263299;
                         attributes: ptr Tlntileattributes_27263351): Tlntileset_27263309 {.
      cdecl, importc: "TLN_CreateTileset".}
else:
  static :
    hint("Declaration of " & "TLN_CreateTileset" &
        " already exists, not redeclaring")
when not declared(Tlnresetspritescaling):
  proc Tlnresetspritescaling*(nsprite: cint): bool {.cdecl,
      importc: "TLN_ResetSpriteScaling".}
else:
  static :
    hint("Declaration of " & "TLN_ResetSpriteScaling" &
        " already exists, not redeclaring")
when not declared(Tlndisablelayerclip):
  proc Tlndisablelayerclip*(nlayer: cint): bool {.cdecl,
      importc: "TLN_DisableLayerClip".}
else:
  static :
    hint("Declaration of " & "TLN_DisableLayerClip" &
        " already exists, not redeclaring")
when not declared(Tlnsetframecallback):
  proc Tlnsetframecallback*(a0: Tlnvideocallback_27263317): void {.cdecl,
      importc: "TLN_SetFrameCallback".}
else:
  static :
    hint("Declaration of " & "TLN_SetFrameCallback" &
        " already exists, not redeclaring")
when not declared(Tlncreateimagetileset):
  proc Tlncreateimagetileset*(numtiles: cint; images: ptr Tlntileimage_27263337): Tlntileset_27263309 {.
      cdecl, importc: "TLN_CreateImageTileset".}
else:
  static :
    hint("Declaration of " & "TLN_CreateImageTileset" &
        " already exists, not redeclaring")
when not declared(Tlngettilemaptileset2):
  proc Tlngettilemaptileset2*(tilemap: Tlntilemap_27263301; index: cint): Tlntileset_27263309 {.
      cdecl, importc: "TLN_GetTilemapTileset2".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapTileset2" &
        " already exists, not redeclaring")
when not declared(Tlnsettilemaptileset2):
  proc Tlnsettilemaptileset2*(tilemap: Tlntilemap_27263301; tileset: Tlntileset_27263309;
                              index: cint): bool {.cdecl,
      importc: "TLN_SetTilemapTileset2".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilemapTileset2" &
        " already exists, not redeclaring")
when not declared(Tlngetbitmapheight):
  proc Tlngetbitmapheight*(bitmap: Tlnbitmap_27263313): cint {.cdecl,
      importc: "TLN_GetBitmapHeight".}
else:
  static :
    hint("Declaration of " & "TLN_GetBitmapHeight" &
        " already exists, not redeclaring")
when not declared(Tlndeletetileset):
  proc Tlndeletetileset*(tileset: Tlntileset_27263309): bool {.cdecl,
      importc: "TLN_DeleteTileset".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteTileset" &
        " already exists, not redeclaring")
when not declared(Tlnclonetilemap):
  proc Tlnclonetilemap*(src: Tlntilemap_27263301): Tlntilemap_27263301 {.cdecl,
      importc: "TLN_CloneTilemap".}
else:
  static :
    hint("Declaration of " & "TLN_CloneTilemap" &
        " already exists, not redeclaring")
when not declared(Tlncreatesequencepack):
  proc Tlncreatesequencepack*(): Tlnsequencepack_27263299 {.cdecl,
      importc: "TLN_CreateSequencePack".}
else:
  static :
    hint("Declaration of " & "TLN_CreateSequencePack" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayercolumnoffset):
  proc Tlnsetlayercolumnoffset*(nlayer: cint; offset: ptr cint): bool {.cdecl,
      importc: "TLN_SetLayerColumnOffset".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerColumnOffset" &
        " already exists, not redeclaring")
when not declared(Tlnoverlaynone):
  const
    Tlnoverlaynone* = 0      ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:237:9
else:
  static :
    hint("Declaration of " & "TLN_OVERLAY_NONE" &
        " already exists, not redeclaring")
when not declared(Tlncreatespritesequence):
  proc Tlncreatespritesequence*(name: cstring; spriteset: Tlnspriteset_27263319;
                                basename: cstring; delay: cint): Tlnsequence_27263349 {.
      cdecl, importc: "TLN_CreateSpriteSequence".}
else:
  static :
    hint("Declaration of " & "TLN_CreateSpriteSequence" &
        " already exists, not redeclaring")
when not declared(Tlnloadsequencepack):
  proc Tlnloadsequencepack*(filename: cstring): Tlnsequencepack_27263299 {.
      cdecl, importc: "TLN_LoadSequencePack".}
else:
  static :
    hint("Declaration of " & "TLN_LoadSequencePack" &
        " already exists, not redeclaring")
when not declared(Tlndeletespriteset):
  proc Tlndeletespriteset*(Spriteset: Tlnspriteset_27263319): bool {.cdecl,
      importc: "TLN_DeleteSpriteset".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteSpriteset" &
        " already exists, not redeclaring")
when not declared(Tlnenablespritecollision):
  proc Tlnenablespritecollision*(nsprite: cint; enable: bool): bool {.cdecl,
      importc: "TLN_EnableSpriteCollision".}
else:
  static :
    hint("Declaration of " & "TLN_EnableSpriteCollision" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayermosaic):
  proc Tlnsetlayermosaic*(nlayer: cint; width: cint; height: cint): bool {.
      cdecl, importc: "TLN_SetLayerMosaic".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayerMosaic" &
        " already exists, not redeclaring")
when not declared(Tlndeletetilemap):
  proc Tlndeletetilemap*(tilemap: Tlntilemap_27263301): bool {.cdecl,
      importc: "TLN_DeleteTilemap".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteTilemap" &
        " already exists, not redeclaring")
when not declared(Tlngetversion):
  proc Tlngetversion*(): uint32 {.cdecl, importc: "TLN_GetVersion".}
else:
  static :
    hint("Declaration of " & "TLN_GetVersion" &
        " already exists, not redeclaring")
when not declared(Tlndisablespriteanimation):
  proc Tlndisablespriteanimation*(nsprite: cint): bool {.cdecl,
      importc: "TLN_DisableSpriteAnimation".}
else:
  static :
    hint("Declaration of " & "TLN_DisableSpriteAnimation" &
        " already exists, not redeclaring")
when not declared(Tlncreatespriteset):
  proc Tlncreatespriteset*(bitmap: Tlnbitmap_27263313; data: ptr Tlnspritedata_27263357;
                           numentries: cint): Tlnspriteset_27263319 {.cdecl,
      importc: "TLN_CreateSpriteset".}
else:
  static :
    hint("Declaration of " & "TLN_CreateSpriteset" &
        " already exists, not redeclaring")
when not declared(Tlnsetspriteblendmode):
  proc Tlnsetspriteblendmode*(nsprite: cint; mode: Tlnblend_27263303;
                              factor: uint8): bool {.cdecl,
      importc: "TLN_SetSpriteBlendMode".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpriteBlendMode" &
        " already exists, not redeclaring")
when not declared(Tlngetusedmemory):
  proc Tlngetusedmemory*(): uint32 {.cdecl, importc: "TLN_GetUsedMemory".}
else:
  static :
    hint("Declaration of " & "TLN_GetUsedMemory" &
        " already exists, not redeclaring")
when not declared(Tlndefineinputbutton):
  proc Tlndefineinputbutton*(player: Tlnplayer_27263376; input: Tlninput_27263307;
                             joybutton: uint8): void {.cdecl,
      importc: "TLN_DefineInputButton".}
else:
  static :
    hint("Declaration of " & "TLN_DefineInputButton" &
        " already exists, not redeclaring")
when not declared(Tlndisablelayer):
  proc Tlndisablelayer*(nlayer: cint): bool {.cdecl, importc: "TLN_DisableLayer".}
else:
  static :
    hint("Declaration of " & "TLN_DisableLayer" &
        " already exists, not redeclaring")
when not declared(Tlnsetspritepalette):
  proc Tlnsetspritepalette*(nsprite: cint; palette: Tlnpalette_27263315): bool {.
      cdecl, importc: "TLN_SetSpritePalette".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpritePalette" &
        " already exists, not redeclaring")
when not declared(Tlnsetspritescaling):
  proc Tlnsetspritescaling*(nsprite: cint; sx: cfloat; sy: cfloat): bool {.
      cdecl, importc: "TLN_SetSpriteScaling".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpriteScaling" &
        " already exists, not redeclaring")
when not declared(Tlnsetworldposition):
  proc Tlnsetworldposition*(x: cint; y: cint): void {.cdecl,
      importc: "TLN_SetWorldPosition".}
else:
  static :
    hint("Declaration of " & "TLN_SetWorldPosition" &
        " already exists, not redeclaring")
when not declared(Tlngettilemapcols):
  proc Tlngettilemapcols*(tilemap: Tlntilemap_27263301): cint {.cdecl,
      importc: "TLN_GetTilemapCols".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapCols" &
        " already exists, not redeclaring")
when not declared(Tlnsetwindowtitle):
  proc Tlnsetwindowtitle*(title: cstring): void {.cdecl,
      importc: "TLN_SetWindowTitle".}
else:
  static :
    hint("Declaration of " & "TLN_SetWindowTitle" &
        " already exists, not redeclaring")
when not declared(Tlngettilemaprows):
  proc Tlngettilemaprows*(tilemap: Tlntilemap_27263301): cint {.cdecl,
      importc: "TLN_GetTilemapRows".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapRows" &
        " already exists, not redeclaring")
when not declared(Tlndeletebitmap):
  proc Tlndeletebitmap*(bitmap: Tlnbitmap_27263313): bool {.cdecl,
      importc: "TLN_DeleteBitmap".}
else:
  static :
    hint("Declaration of " & "TLN_DeleteBitmap" &
        " already exists, not redeclaring")
when not declared(Tlnsetcontext):
  proc Tlnsetcontext*(context: Tlnengine_27263341): bool {.cdecl,
      importc: "TLN_SetContext".}
else:
  static :
    hint("Declaration of " & "TLN_SetContext" &
        " already exists, not redeclaring")
when not declared(Tlngetwindowwidth):
  proc Tlngetwindowwidth*(): cint {.cdecl, importc: "TLN_GetWindowWidth".}
else:
  static :
    hint("Declaration of " & "TLN_GetWindowWidth" &
        " already exists, not redeclaring")
when not declared(Tlnsetfirstsprite):
  proc Tlnsetfirstsprite*(nsprite: cint): bool {.cdecl,
      importc: "TLN_SetFirstSprite".}
else:
  static :
    hint("Declaration of " & "TLN_SetFirstSprite" &
        " already exists, not redeclaring")
when not declared(Tlnsetlayer):
  proc Tlnsetlayer*(nlayer: cint; tileset: Tlntileset_27263309;
                    tilemap: Tlntilemap_27263301): bool {.cdecl,
      importc: "TLN_SetLayer".}
else:
  static :
    hint("Declaration of " & "TLN_SetLayer" & " already exists, not redeclaring")
when not declared(Tlndefineinputkey):
  proc Tlndefineinputkey*(player: Tlnplayer_27263376; input: Tlninput_27263307;
                          keycode: uint32): void {.cdecl,
      importc: "TLN_DefineInputKey".}
else:
  static :
    hint("Declaration of " & "TLN_DefineInputKey" &
        " already exists, not redeclaring")
when not declared(Tlnenableinput):
  proc Tlnenableinput*(player: Tlnplayer_27263376; enable: bool): void {.cdecl,
      importc: "TLN_EnableInput".}
else:
  static :
    hint("Declaration of " & "TLN_EnableInput" &
        " already exists, not redeclaring")
when not declared(Tlngettilemaptiletileset):
  proc Tlngettilemaptiletileset*(tilemap: Tlntilemap_27263301; row: cint;
                                 col: cint): cint {.cdecl,
      importc: "TLN_GetTilemapTileTileset".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapTileTileset" &
        " already exists, not redeclaring")
when not declared(Tlngetspriteposy):
  proc Tlngetspriteposy*(nsprite: cint): cint {.cdecl,
      importc: "TLN_GetSpritePosY".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpritePosY" &
        " already exists, not redeclaring")
when not declared(Tlnloadtileset):
  proc Tlnloadtileset*(filename: cstring): Tlntileset_27263309 {.cdecl,
      importc: "TLN_LoadTileset".}
else:
  static :
    hint("Declaration of " & "TLN_LoadTileset" &
        " already exists, not redeclaring")
when not declared(Tlncreatewindowthread):
  proc Tlncreatewindowthread*(overlay: cstring; flags: cint): bool {.cdecl,
      importc: "TLN_CreateWindowThread".}
else:
  static :
    hint("Declaration of " & "TLN_CreateWindowThread" &
        " already exists, not redeclaring")
when not declared(Tlnenableblur):
  proc Tlnenableblur*(mode: bool): void {.cdecl, importc: "TLN_EnableBlur".}
else:
  static :
    hint("Declaration of " & "TLN_EnableBlur" &
        " already exists, not redeclaring")
when not declared(Tlnsettilesetpalette):
  proc Tlnsettilesetpalette*(tileset: Tlntileset_27263309; palette: Tlnpalette_27263315): bool {.
      cdecl, importc: "TLN_SetTilesetPalette".}
else:
  static :
    hint("Declaration of " & "TLN_SetTilesetPalette" &
        " already exists, not redeclaring")
when not declared(Tlngettilemaptileset):
  proc Tlngettilemaptileset*(tilemap: Tlntilemap_27263301): Tlntileset_27263309 {.
      cdecl, importc: "TLN_GetTilemapTileset".}
else:
  static :
    hint("Declaration of " & "TLN_GetTilemapTileset" &
        " already exists, not redeclaring")
when not declared(Tlngetticks):
  proc Tlngetticks*(): uint32 {.cdecl, importc: "TLN_GetTicks".}
else:
  static :
    hint("Declaration of " & "TLN_GetTicks" & " already exists, not redeclaring")
when not declared(Tlnoverlayscanlines):
  const
    Tlnoverlayscanlines* = 0 ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:240:9
else:
  static :
    hint("Declaration of " & "TLN_OVERLAY_SCANLINES" &
        " already exists, not redeclaring")
when not declared(Tlnsetspriteset):
  proc Tlnsetspriteset*(nsprite: cint; spriteset: Tlnspriteset_27263319): bool {.
      cdecl, importc: "TLN_SetSpriteSet".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpriteSet" &
        " already exists, not redeclaring")
when not declared(Tlngetwindowheight):
  proc Tlngetwindowheight*(): cint {.cdecl, importc: "TLN_GetWindowHeight".}
else:
  static :
    hint("Declaration of " & "TLN_GetWindowHeight" &
        " already exists, not redeclaring")
when not declared(Tlnsetspritesmaskregion):
  proc Tlnsetspritesmaskregion*(topline: cint; bottomline: cint): void {.cdecl,
      importc: "TLN_SetSpritesMaskRegion".}
else:
  static :
    hint("Declaration of " & "TLN_SetSpritesMaskRegion" &
        " already exists, not redeclaring")
when not declared(Tlndrawframe):
  proc Tlndrawframe*(frame: cint): void {.cdecl, importc: "TLN_DrawFrame".}
else:
  static :
    hint("Declaration of " & "TLN_DrawFrame" &
        " already exists, not redeclaring")
when not declared(Tlnsetpalettecolor):
  proc Tlnsetpalettecolor*(palette: Tlnpalette_27263315; color: cint; r: uint8;
                           g: uint8; b: uint8): bool {.cdecl,
      importc: "TLN_SetPaletteColor".}
else:
  static :
    hint("Declaration of " & "TLN_SetPaletteColor" &
        " already exists, not redeclaring")
when not declared(Tlnaddtileobjecttolist):
  proc Tlnaddtileobjecttolist*(list: Tlnobjectlist_27263343; id: uint16;
                               gid: uint16; flags: uint16; x: cint; y: cint): bool {.
      cdecl, importc: "TLN_AddTileObjectToList".}
else:
  static :
    hint("Declaration of " & "TLN_AddTileObjectToList" &
        " already exists, not redeclaring")
when not declared(Tlnsubpalettecolor):
  proc Tlnsubpalettecolor*(palette: Tlnpalette_27263315; r: uint8; g: uint8;
                           b: uint8; start: uint8; num: uint8): bool {.cdecl,
      importc: "TLN_SubPaletteColor".}
else:
  static :
    hint("Declaration of " & "TLN_SubPaletteColor" &
        " already exists, not redeclaring")
when not declared(Tlnoverlayaperture):
  const
    Tlnoverlayaperture* = 0  ## Generated based on C:/Users/nicol/Documents/programmation/testTilengineNim/includes\Tilengine.h:239:9
else:
  static :
    hint("Declaration of " & "TLN_OVERLAY_APERTURE" &
        " already exists, not redeclaring")
when not declared(Tlngetlayerposx):
  proc Tlngetlayerposx*(nlayer: cint): cint {.cdecl, importc: "TLN_GetLayerPosX".}
else:
  static :
    hint("Declaration of " & "TLN_GetLayerPosX" &
        " already exists, not redeclaring")
when not declared(Tlngetspriteposx):
  proc Tlngetspriteposx*(nsprite: cint): cint {.cdecl,
      importc: "TLN_GetSpritePosX".}
else:
  static :
    hint("Declaration of " & "TLN_GetSpritePosX" &
        " already exists, not redeclaring")
when not declared(Tlnsetcustomblendfunction):
  proc Tlnsetcustomblendfunction*(a0: Tlnblendfunction_27263347): void {.cdecl,
      importc: "TLN_SetCustomBlendFunction".}
else:
  static :
    hint("Declaration of " & "TLN_SetCustomBlendFunction" &
        " already exists, not redeclaring")
when not declared(Tlndeinit):
  proc Tlndeinit*(): void {.cdecl, importc: "TLN_Deinit".}
else:
  static :
    hint("Declaration of " & "TLN_Deinit" & " already exists, not redeclaring")
when not declared(Tlnsetloadpath):
  proc Tlnsetloadpath*(path: cstring): void {.cdecl, importc: "TLN_SetLoadPath".}
else:
  static :
    hint("Declaration of " & "TLN_SetLoadPath" &
        " already exists, not redeclaring")
when not declared(Tlnaddpalettecolor):
  proc Tlnaddpalettecolor*(palette: Tlnpalette_27263315; r: uint8; g: uint8;
                           b: uint8; start: uint8; num: uint8): bool {.cdecl,
      importc: "TLN_AddPaletteColor".}
else:
  static :
    hint("Declaration of " & "TLN_AddPaletteColor" &
        " already exists, not redeclaring")
when not declared(Tlncreatecycle):
  proc Tlncreatecycle*(name: cstring; numstrips: cint; strips: ptr Tlncolorstrip_27263323): Tlnsequence_27263349 {.
      cdecl, importc: "TLN_CreateCycle".}
else:
  static :
    hint("Declaration of " & "TLN_CreateCycle" &
        " already exists, not redeclaring")
when not declared(Tlnconfigsprite):
  proc Tlnconfigsprite*(nsprite: cint; spriteset: Tlnspriteset_27263319;
                        flags: uint32): bool {.cdecl,
      importc: "TLN_ConfigSprite".}
else:
  static :
    hint("Declaration of " & "TLN_ConfigSprite" &
        " already exists, not redeclaring")