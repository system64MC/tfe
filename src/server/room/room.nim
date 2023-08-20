import ../camera
import ../../common/vectors
import ../../common/constants
import tilengine/tilengine
import std/tables
import ../actors/actors
import ../actors/bulletList

type
  Room* = ref object
    camera*: Camera
    collisions*: Tilemap
    switchOn*: bool
    destroyableTilesList*: Table[VectorI64, bool]
    playerList*: array[4, actors.Player]
    enemyList*: array[256, Ennemy]
    bulletList*: BulletList

  Collision* = enum
    NULL_TILE
    AIR
    SOLID
    DESTROYABLE_TILE
    SWITCH_TILE
    TILE_SWITCH_ON
    TILE_SWITCH_OFF

    # for p in room.playerList:
    #     p.update()
    
    # for a in room.actorList:
    #     a.update()

    # for b in room.actorList:
    #     b.update()