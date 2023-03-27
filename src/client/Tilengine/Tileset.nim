import Types
import TilengineBinding

# TILESET
proc createTileset*(numTiles: int, w: int, h: int, palette: TLN_Palette, sp: TLN_SequencePack, attributes: ptr TLN_TileAttributes): TLN_Tileset =
    return TLN_CreateTileset(numTiles.cint, w.cint, h.cint, palette, sp, attributes)

proc createImageTileset*(numTiles: int, images: ptr TLN_TileImage): TLN_Tileset =
    return TLN_CreateImageTileset(numTiles.cint, images)

proc loadTileset*(file: string): TLN_Tileset =
    return TLN_LoadTileset(file.cstring)

proc cloneTileset*(src: TLN_Tileset): TLN_Tileset =
    return TLN_CloneTileset(src)

proc setTilesetPixels*(tileset: TLN_Tileset, entry: int, srcdata: ptr uint8, srcpitch: int): bool =
    return TLN_SetTilesetPixels(tileset, entry.cint, srcdata, srcpitch.cint)

proc getTileWidth*(self: TLN_Tileset): int =
    return TLN_GetTileWidth(self).int

proc getTileHeight*(self: TLN_Tileset): int =
    return TLN_GetTileHeight(self).int

proc getTilesetNumTiles*(self: TLN_Tileset): int =
    return TLN_GetTilesetNumTiles(self).int

proc getTilesetPalette*(self: TLN_Tileset): TLN_Palette =
    return TLN_GetTilesetPalette(self)

proc setTilesetPalette*(self: TLN_Tileset, palette: TLN_Palette): bool =
    return TLN_SetTilesetPalette(self, palette)

proc getTilesetSequencePack*(self: TLN_Tileset): TLN_SequencePack =
    return TLN_GetTilesetSequencePack(self)

proc deleteTileset*(self: TLN_Tileset): bool =
    return TLN_DeleteTileset(self)