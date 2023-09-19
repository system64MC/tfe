import room
import std/[parsexml, xmlparser, streams, xmltree, strutils, os]
import common/[vectors, hitbox, commonActors]
import math

const FLIPPED_HORIZONTALLY_FLAG  = 0x80000000'u32
const FLIPPED_VERTICALLY_FLAG    = 0x40000000'u32
const FLIPPED_DIAGONALLY_FLAG    = 0x20000000'u32
const ROTATED_HEXAGONAL_120_FLAG = 0x10000000'u32
const CLEAR_ALL_FLAGS            = not (FLIPPED_HORIZONTALLY_FLAG or FLIPPED_VERTICALLY_FLAG or FLIPPED_DIAGONALLY_FLAG or ROTATED_HEXAGONAL_120_FLAG).uint64


proc loadTilemap*(path: string, layerName: string = ""): Tilemap =
    echo "LOADING TILEMAP "
    # var tilesets: array[8, Tileset]
    var gids: array[8, uint]
    var gotTileset = 0
    let name2 = layerName.toLower()

    let data = CollisionsMap()
    data.tiles = newSeq[uint16](0)


    var tree = loadXml(path)
    let path2 = path.splitPath.head & '/'
    let
        tilewidth = tree.attr("tilewidth").parseInt
        tileheight = tree.attr("tileheight").parseInt
    var
        width = 0'i32
        height = 0'i32
        # tileData: seq[uint16]
        loadedLayer = false
    for elementName in tree:
        case elementName.tag:
        of "tileset":
            if(gotTileset < 8): 
                tilesets[gotTileset] = loadTileset(path2 & elementName.attr("source"))
                gids[gotTileset] = elementName.attr("firstgid").parseUInt()
                gotTileset.inc
        of "layer":
            if((elementName.attr("name").toLower() == name2 or layerName == "") and not loadedLayer):
                data.width = elementName.attr("width").parseInt()
                data.height = elementName.attr("height").parseInt()
                let data = elementName.child("data")
                let encoding = data.attr("encoding")
                if(encoding == "csv"):
                    data.tiles = newSeq[uint16](data.width * data.height)
                    var tileId: uint = 0
                    var index = 0
                    for c in data.innerText():
                        if(c >= '0' and c <= '9'):
                            tileId = (tileId * 10) + (c.uint - '0'.uint)
                        elif(c == ','):
                          # Save the tileId somewhere before setting to 0
                            # tileData[index].flipH  = (tileId and FLIPPED_HORIZONTALLY_FLAG).bool
                            # tileData[index].flipV  = (tileId and FLIPPED_VERTICALLY_FLAG).bool
                            # TODO : rotation disabled
                            # tileData[index].rotate = (tileId and FLIPPED_DIAGONALLY_FLAG).bool
                            tileId = tileId and CLEAR_ALL_FLAGS
                            for i in countdown(gotTileset - 1, 0):
                                if(tileId >= gids[i]): 
                                    tileId -= gids[i]
                                    # tileData[index].tileset = i.byte
                                    data.tiles[index].index = tileId.uint16
                                    break
                                # If we get there, this is because nothing was found, so we have an illegal tile!
                                if(i == 0):
                                    # tileData[index].tileset = 0
                                    data.tiles[index].index = 0
                            tileId = 0
                            index.inc
                loadedLayer = true            
        else:
              discard
    return Tilemap(
        map: tileData,
        tilesets: tilesets,
        widthByTiles: width,
        heightByTiles: height,
        widthPixels: (width * tileWidth).int32,
        heightPixels: (height * tileHeight).int32,
        ttileWidth: tilewidth.int32,
        ttileHeight: tileheight.int32
    )