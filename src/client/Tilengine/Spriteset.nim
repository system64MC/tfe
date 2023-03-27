import Types
import TilengineBinding

# SPRITESET
proc createSpriteset(bitmap: TLN_Bitmap, spriteData: ptr TLN_SpriteData, numEntries: int): TLN_Spriteset =
    # var s: TLN_SpriteData
    # s.x = (spriteData.x).cint
    # s.y = (spriteData.y).cint
    # s.w = (spriteData.w).cint
    # s.h = (spriteData.h).cint

    return TLN_CreateSpriteset(bitmap, spriteData, numEntries.cint)

proc loadSpriteset*(name: string): TLN_Spriteset =
    TLN_LoadSpriteset(name.cstring)

proc cloneSpriteset*(source: TLN_Spriteset): TLN_Spriteset =
    TLN_CloneSpriteset(source)

proc getSpriteInfo*(spriteset: TLN_Spriteset, entry: int, info: ptr TLN_SpriteInfo): bool =
    return TLN_GetSpriteInfo(spriteset, entry.cint, info)

proc getSpritesetPalette*(spriteset: TLN_Spriteset): TLN_Palette =
    TLN_GetSpritesetPalette(spriteset)

proc findSpritesetSprite*(spriteset: TLN_Spriteset, name: string): int =
    TLN_FindSpritesetSprite(spriteset, name.cstring).cint

proc setSpritesetData*(spriteset: TLN_Spriteset, entry: int, data: ptr TLN_SpriteData, pixels: ptr, pitch: int): bool =
    return TLN_SetSpritesetData(spriteset, entry.cint, data, pixels, pitch.cint)

proc deleteSpriteset*(self: TLN_Spriteset): bool =
    TLN_DeleteSpriteset(self)