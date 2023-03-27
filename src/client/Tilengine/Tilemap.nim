import Types
import TilengineBinding

# type
#     INNER_C_STRUCT_Tilengine_132* {.bycopy.} = object
#         index*: uint16
#         flags*: uint16
  
#     uniontile {.bycopy, union.} = object
#         value*: uint32
#         anoTilengine132*: INNER_C_STRUCT_Tilengine_132

type
  INNER_C_STRUCT_Tilengine_132* {.bycopy.} = object
    index*: uint16            ## !< tile index
    flags*: uint16            ## !< attributes (FLAG_FLIPX, FLAG_FLIPY, FLAG_PRIORITY)

  TileObject* {.bycopy, union.} = object
    value*: uint32
    props*: INNER_C_STRUCT_Tilengine_132
 
# importc:
#     sysPath "/c/clang/1301/include"
#     path "./includes"
#     "Tilengine.h"

# TILEMAP
proc createTilemap*(rows: int, cols: int, tiles: TLN_Tile, bgcolor: uint, tileset: TLN_Tileset): TLN_Tilemap =
    return TLN_CreateTilemap(rows.cint, cols.cint, tiles, bgcolor.cuint, tileset)

proc createTilemap*(rows: int, cols: int, tiles: TLN_Tile, bgcolor: Color, tileset: TLN_Tileset): TLN_Tilemap =
    var color = (bgcolor.r shl 24) + (bgcolor.g shl 16) + (bgcolor.b shl 24) + (bgcolor.a)
    return TLN_CreateTilemap(rows.cint, cols.cint, tiles, color.cuint, tileset)

proc loadTilemap*(file: string, layerName: string = ""): TLN_Tilemap = 
    if(layerName == ""):
        return TLN_LoadTilemap(file.cstring, nil)
    else:
        return TLN_LoadTilemap(file.cstring, layerName.cstring)

proc cloneTilemap*(self: TLN_Tilemap): TLN_Tilemap =
    return TLN_CloneTilemap(self)

proc getTilemapRows*(self: TLN_Tilemap): int =
    return TLN_GetTilemapRows(self).int

proc getTilemapCols*(self: TLN_Tilemap): int =
    return TLN_GetTilemapCols(self)

proc getTilemapTileset*(self: TLN_Tilemap): TLN_Tileset =
    return TLN_GetTilemapTileset(self)

proc setTilemapTileset*(self: TLN_Tilemap, tileset: TLN_Tileset): bool =
    return TLN_SetTilemapTileset(self, tileset)

proc setTilemapTilesetSlot*(self: TLN_Tilemap, tileset: TLN_Tileset, index: int): bool =
    return TLN_SetTilemapTileset2(self, tileset, index.cint)

proc getTilemapTilesetSlot*(self: TLN_Tilemap, index: int): TLN_Tileset =
    return TLN_GetTilemapTileset2(self, index.cint)

proc getTilemapTile*(tilemap: TLN_Tilemap, row: int, col: int, tile: TLN_Tile): bool =
    return TLN_GetTilemapTile(tilemap, row.cint, col.cint, tile)

proc setTilemapTile*(tilemap: TLN_Tilemap, row: int, col: int, tile: ptr TileObject): bool =
    return TLN_SetTilemapTile(tilemap, row.cint, col.cint, cast[TLN_Tile](tile))

proc getTilemapTileData*(tilemap: TLN_Tilemap, row: int, col: int): uint32 =
    return TLN_GetTilemapTileData(tilemap, row.cint, col.cint).uint32

proc getTilemapTileTileset*(tilemap: TLN_Tilemap, row: int, col: int): int =
    return TLN_GetTilemapTileTileset(tilemap, row.cint, col.cint).int

proc setTilemapTileTileset*(tilemap: TLN_Tilemap, row: int, col: int, tilesetSlot: uint8): bool =
    return TLN_SetTilemapTileTileset(tilemap, row.cint, col.cint, tilesetSlot)

proc setTilemapTileMask*(tilemap: TLN_Tilemap, row: int, col: int, masked: bool): bool =
    return TLN_SetTilemapTileMasked(tilemap, row.cint, col.cint, masked)

proc setTilemapTileFlipX*(tilemap: TLN_Tilemap, row: int, col: int, flip: bool): bool =
    return TLN_SetTilemapTileFlipX(tilemap, row.cint, col.cint, flip)

proc setTilemapTileFlipY*(tilemap: TLN_Tilemap, row: int, col: int, flip: bool): bool =
    return TLN_SetTilemapTileFlipY(tilemap, row.cint, col.cint, flip)

proc setTilemapTileIndex*(tilemap: TLN_Tilemap, row: int, col: int, index: uint16): bool =
    return TLN_SetTilemapTileID(tilemap, row.cint, col.cint, index)

proc copyTiles*(src: TLN_Tilemap, srcrow: int, srccol: int, rows: int, cols: int, dst: TLN_Tilemap, dstrow: int, dstcol: int): bool =
    return TLN_CopyTiles(src, srcrow.cint, srccol.cint, rows.cint, cols.cint, dst, dstrow.cint, dstcol.cint)

proc deleteTilemap*(self: TLN_Tilemap): bool =
    return TLN_DeleteTilemap(self)

proc setTilemapTilePal*(self: TLN_Tilemap, row: int, col: int, pal: int8): bool =
    return TLN_setTilemapTilePal(self, row.cint, col.cint, pal)

proc getTilemapTileId*(tilemap: TLN_Tilemap, row: int, col: int): int =
    return TLN_GetTilemapTileId(tilemap, row.cint, col.cint).int

proc putTile*(tilemap: TLN_Tilemap, x: int, y: int, flags: TileFlags): void =
        var tile: TileObject
        var val = flags.index.uint32 or (flags.tileset.uint32 shl 24) or (flags.masked.uint32 shl 27) or (flags.priority.uint32 shl 28) or (flags.rotated.uint32 shl 29) or (flags.flipy.uint32 shl 30) or (flags.flipx.uint32 shl 31) 
        tile.value = val
        discard tilemap.setTilemapTile(y, x, tile.addr)