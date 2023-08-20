import room
import ../camera
import ../../common/vectors
import ../../common/constants
import tilengine/tilengine
import std/tables

proc getDestroyableTiles(room: var Room): void =
    var buffer = initTable[VectorI64, bool]()
    var tile = Tile()
    for row in 0..<room.collisions.getRows():
        for col in 0..<room.collisions.getCols():
            tile = room.collisions.getTile(row, col)
            if tile.index.Collision == DESTROYABLE_TILE:
                buffer[VectorI64(x: col.int, y: row.int)] = true
    room.destroyableTilesList = buffer

proc loadRoom*(path: string): Room =
    var room = Room()
    room.collisions = loadTilemap(path, "collisions")
    room.camera = Camera(position: VectorF64(x: 0, y: 0))
    room.switchOn = true
    room.getDestroyableTiles()
    
    # let actorMap = tiledMap.tiledMap.layers[2]

    # for obj in actorMap.objects:
    #     case obj.id.ActorType
    #         of ENNEMY:
    #             room.actorList.add(
    #                 Ennemy(
    #                     position: VectorI16(x: obj.x.int16, y: obj.y.int16),
    #                     ennemyType: 0,
    #                     lifePoints: 100,
    #                 )
    #             )
    return room

import math
proc getTile*(pos: VectorF64, currentRoom: Room): Tile =
    # return currentRoom.collisions.getTile(pos.y.int shr 4, pos.x.int shr 4)
    return currentRoom.collisions.getTile((pos.y / 16).int, (pos.x / 16).int)

method update(room: Room): void =
    room.camera.update()