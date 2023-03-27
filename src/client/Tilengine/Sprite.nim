import Types, TilengineBinding

# SPRITE
proc configSprite*(nsprite: int, spriteset: TLN_Spriteset, flags: uint): bool =
    return TLN_ConfigSprite(nsprite.cint, spriteset, flags.cuint)

proc setSpriteSet*(nsprite: int, spriteset: TLN_Spriteset): bool =
    return TLN_SetSpriteSet(nsprite.cint, spriteset)

proc setSpriteFlags*(nsprite: int, flags: uint): bool =
    return TLN_SetSpriteFlags(nsprite.cint, flags.cuint)

proc enableSpriteFlags*(nsprite: int, flag: uint, enable: bool): bool =
    return TLN_EnableSpriteFlag(nsprite.cint, flag.cuint, enable)

proc setspritePivot*(nsprite: int, px: float, py: float): bool = 
    return TLN_SetSpritePivot(nsprite.cint, px.cfloat, py.cfloat)

proc setSpritePosition*(nsprite: int, x: int, y: int): bool =
    return TLN_SetSpritePosition(nsprite.cint, x.cint, y.cint)

proc setSpritePicture*(nsprite: int, entry: int): bool =
    return TLN_SetSpritePicture(nsprite.cint, entry.cint)

proc setSpritePalette*(nsprite: int, palette: TLN_Palette): bool =
    return TLN_SetSpritePalette(nsprite.cint, palette)

proc setSpriteBlendMode*(nsprite: int, mode: TLN_Blend, factor: uint8): bool =
    return TLN_SetSpriteBlendMode(nsprite.cint, mode, factor)

proc setSpriteScaling*(nsprite: int, sx: float, sy: float): bool =
    return TLN_SetSpriteScaling(nsprite.cint, sx.cfloat, sy.cfloat)

proc resetSpriteScaling*(nsprite: int): bool =
    return TLN_ResetSpriteScaling(nsprite.cint)

proc setSpriteWarpX*(nsprite: int, enable: bool): bool =
    return TLN_SetSpriteWarpX(nsprite.cint, enable)

proc setSpriteWarpY*(nsprite: int, enable: bool): bool =
    return TLN_SetSpriteWarpY(nsprite.cint, enable)

#
#

proc getSpritePicture*(nsprite: int): int =
    return TLN_GetSpritePicture(nsprite.cint).int

proc getAvaillableSprite*(): int =
    return TLN_GetAvailableSprite().int

proc enableSpriteCollision*(nsprite: int, enable: bool): bool =
    return TLN_EnableSpriteCollision(nsprite.cint, enable)

proc getSpriteCollision*(nsprite: int): bool =
    return TLN_GetSpriteCollision(nsprite.cint)

proc getSpriteState*(nsprite: int, state: ptr TLN_SpriteState): bool =
    return TLN_GetSpriteState(nsprite.cint, state)

proc setFirstSprite*(nsprite: int): bool =
    return TLN_SetFirstSprite(nsprite.cint)

proc setNextSprite*(nsprite: int, next: int): bool =
    return TLN_SetNextSprite(nsprite.cint, next.cint)

proc enableSpriteMasking*(nsprite: int, enable: bool): bool =
    return TLN_EnableSpriteMasking(nsprite.cint, enable)

proc setSpriteMaskRegion*(topLine: int, bottomLine: int): void =
    TLN_SetSpritesMaskRegion(topLine.cint, bottomLine.cint)

proc setSpriteAnimation*(nsprite: int, sequence: TLN_Sequence, loop: int): bool =
    return TLN_SetSpriteAnimation(nsprite.cint, sequence, loop.cint)

proc disableSpriteAnimation*(nsprite: int): bool =
    return TLN_DisableSpriteAnimation(nsprite.cint)

proc disableSprite*(nsprite: int): bool =
    return TLN_DisableSprite(nsprite.cint)

proc getSpritePalette*(nsprite: int): TLN_Palette =
    return TLN_GetSpritePalette(nsprite.cint)

proc getSpritePosX*(nsprite: int): int =
    return TLN_GetSpritePosX(nsprite.cint).int

proc getSpritePosY*(nsprite: int): int =
    return TLN_GetSpritePosY(nsprite.cint).int