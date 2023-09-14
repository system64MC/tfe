# import ../camera
import common/vectors
import common/constants
import common/commonActors
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
    bulletList*: BulletList
    enemyList*: array[256, Enemy]
    boss*: Enemy
    bonusList*: array[8, Bonus]
    isBoss*: bool

  Collision* = enum
    NULL_TILE,
    AIR,
    SOLID,
    DESTROYABLE_TILE,
    SWITCH_TILE,
    TILE_SWITCH_ON,
    TILE_SWITCH_OFF,
    BOSS_TRIGGER,
    KILLER_TILE

proc getTile*(pos: VectorF64, currentRoom: Room): Tile =
    # return currentRoom.collisions.getTile(pos.y.int shr 4, pos.x.int shr 4)
    
    if((pos.x / 16) < 0 or (pos.x / 16).int >= currentRoom.collisions.getCols() or (pos.y / 16) < 0 or (pos.y / 16).int >= currentRoom.collisions.getRows()): return Tile()
    return currentRoom.collisions.getTile((pos.y / 16).int, (pos.x / 16).int)

proc `[]`*(currentRoom: Room; x: int, y: int): Tile =
    return currentRoom.collisions.getTile((x shr 4).int, (y shr 4).int)

proc `[]`*(currentRoom: Room; x: float, y: float): Tile =
    return currentRoom.collisions.getTile((x / 16).int, (y / 16).int)

    # for p in room.playerList:
    #     p.update()
    
    # for a in room.actorList:
    #     a.update()

    # for b in room.actorList:
    #     b.update()