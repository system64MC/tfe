import Types, TilengineBinding

# WORLD
proc loadWorld(tmxFile: string, firstLayer: int): bool =
    return TLN_LoadWorld(tmxFile.cstring, firstLayer.cint)

proc setWorldPosition(x: int, y: int): void =
    TLN_SetWorldPosition(x.cint, y.cint)

proc setLayerParallaxFactor(nlayer: int, x: float, y: float): bool =
    return TLN_SetLayerParallaxFactor(nlayer.cint, x.cfloat, y.cfloat)

proc setSpriteWorldPosition(nsprite: int, x: int, y: int): bool =
    return TLN_SetSpriteWorldPosition(nsprite.cint, x.cint, y.cint)

proc releaseWorld(): void =
    TLN_ReleaseWorld()