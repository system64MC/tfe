import Types, TilengineBinding

# ANIMATION
proc setPaletteAnimation*(index: int, palette: TLN_Palette, sequence: TLN_Sequence, blend: bool): bool =
    return TLN_SetPaletteAnimation(index.cint, palette, sequence, blend)

proc setPaletteAnimationSrc*(index: int, palette: TLN_Palette): bool =
    return TLN_SetPaletteAnimationSource(index.cint, palette)

proc getAnimationState*(index: int): bool =
    return TLN_GetAnimationState(index.cint)

proc setAnimationDelay*(index: int, frame: int, delay: int): bool =
    return TLN_SetAnimationDelay(index.cint, frame.cint, delay.cint)

proc getAvaillableAnimation*(): int =
    return TLN_GetAvailableAnimation().int

proc disablePaletteAnimation*(index: int): bool =
    return TLN_DisablePaletteAnimation(index.cint)