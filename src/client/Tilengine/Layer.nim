import Types, TilengineBinding

# LAYER
proc setLayer*(nlayer: int, tileset: TLN_Tileset, tilemap: TLN_Tilemap): bool =
    return TLN_SetLayer(nlayer.cint, tileset, tilemap)

proc setLayerTilemap*(nlayer: int, tilemap: TLN_Tilemap): bool =
    return TLN_SetLayerTilemap(nlayer.cint, tilemap)

proc setLayerBitmap*(nlayer: int, bitmap: TLN_Bitmap): bool =
    return TLN_SetLayerBitmap(nlayer.cint, bitmap)

proc setLayerPalette*(nlayer: int, palette: TLN_Palette): bool =
    return TLN_SetLayerPalette(nlayer.cint, palette)

proc setLayerPosition*(nlayer: int, x: int, y: int): bool =
    return TLN_SetLayerPosition(nlayer.cint, x.cint, y.cint)

proc setLayerScaling*(nlayer: int, xfactor: float, yfactor: float): bool =
    return TLN_SetLayerScaling(nlayer.cint, xfactor.cfloat, yfactor.cfloat)

proc setLayerAffineTransform*(nlayer: int, affine: ptr TLN_Affine): bool =
    return TLN_SetLayerAffineTransform(nlayer.cint, affine)

proc setLayerTransform*(nlayer: int, angle: float, dx: float, dy: float, sx: float, sy: float): bool =
    return TLN_SetLayerTransform(nlayer.cint, angle.cfloat, dx.cfloat, dy.cfloat, sx.cfloat, sy.cfloat)

proc setLayerPixelMapping*(nlayer: int, table: ptr TLN_PixelMap): bool =
    return TLN_SetLayerPixelMapping(nlayer.cint, table)

proc setLayerBlendMode*(nlayer: int, mode: TLN_Blend, factor: uint8): bool =
    return TLN_SetLayerBlendMode(nlayer.cint, mode, factor)

proc setLayerColumnOffset*(nlayer: int, offset: ptr cint): bool =
    return TLN_SetLayerColumnOffset(nlayer.cint, offset)

proc setLayerClip*(nlayer: int, x1: int, y1: int, x2: int, y2: int): bool =
    return TLN_SetLayerClip(nlayer.cint, x1.cint, y1.cint, x2.cint, y2.cint)

proc disableLayerClip*(nlayer: int): bool =
    return TLN_DisableLayerClip(nlayer.cint)

proc setLayerMosaic*(nlayer: int, w: int, h: int): bool =
    return TLN_SetLayerMosaic(nlayer.cint, w.cint, h.cint)

proc disableLayerMosaic*(nlayer: int): bool =
    return TLN_DisableLayerMosaic(nlayer.cint)

proc resetLayerMode*(nlayer: int): bool =
    return TLN_ResetLayerMode(nlayer.cint)

proc setLayerObjects*(nlayer: int, objects: TLN_ObjectList, tileset: TLN_Tileset): bool =
    return TLN_SetLayerObjects(nlayer.cint, objects, tileset)

proc setLayerPriority*(nlayer: int, enable: bool): bool =
    return TLN_SetLayerPriority(nlayer.cint, enable)

proc setLayerParent*(nlayer: int, parent: int): bool =
    return TLN_SetLayerParent(nlayer.cint, parent.cint)

proc disableLayerParent*(nlayer: int): bool = 
    return TLN_DisableLayerParent(nlayer.cint)

proc disableLayer*(nlayer: int): bool =
    return TLN_DisableLayer(nlayer.cint)

proc enableLayer*(nlayer: int): bool =
    return TLN_EnableLayer(nlayer.cint)

proc getLayerType*(nlayer: int): TLN_LayerType =
    return TLN_GetLayerType(nlayer.cint)

proc getLayerPalette*(nlayer: int): TLN_Palette =
    return TLN_GetLayerPalette(nlayer.cint)

proc getLayerTileset*(nlayer: int): TLN_Tileset =
    return TLN_GetLayerTileset(nlayer.cint)

proc getLayerTilemap*(nlayer: int): TLN_Tilemap =
    return TLN_GetLayerTilemap(nlayer.cint)

proc getLayerBitmap*(nlayer: int): TLN_Bitmap =
    return TLN_GetLayerBitmap(nlayer.cint)

proc getLayerObjects*(nlayer: int): TLN_ObjectList =
    return TLN_GetLayerObjects(nlayer.cint)

proc getLayerTile*(nlayer: int, x: int, y: int, info: ptr TLN_TileInfo): bool =
    return TLN_GetLayerTile(nlayer.cint, x.cint, y.cint, info)

proc getLayerWidth*(nlayer: int): int =
    return TLN_GetLayerWidth(nlayer.cint)

proc getLayerHeight*(nlayer: int): int =
    return TLN_GetLayerHeight(nlayer.cint)

proc getLayerPosX*(nlayer: int): int =
    return TLN_GetLayerPosX(nlayer.cint).int

proc getLayerPosY*(nlayer: int): int =
    return TLN_GetLayerPosY(nlayer.cint).int