import ../camera
# import ../actors/actor
# import ../actors/ennemy
import ../../common/vectors
# import ../actors/player
# import ../actors/bullet
import tilengine/tilengine

type
  Room* = ref object
    camera*: Camera
    collisions*: Tilemap
    switchOn*: bool
    # playerList*: array[4, player.Player]
    # actorList*: seq[Actor]
    # bulletList*: seq[Bullet]

  Collision* = enum
    NULL_TILE
    AIR
    SOLID
    DESTROYABLE_TILE
    SWITCH_TILE
    TILE_SWITCH_ON
    TILE_SWITCH_OFF

var loadedRoom*: Room

proc loadRoom*(path: string): Room =
    var room = Room()
    room.collisions = loadTilemap(path, "collisions")
    room.camera = Camera(position: VectorF64(x: 0, y: 0))
    room.switchOn = true
    
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

proc getTile*(pos: VectorF64, currentRoom: Room): Tile =
    return currentRoom.collisions.getTile(pos.y.int shr 4, pos.x.int shr 4)

method update(room: Room): void =
    room.camera.update()

    # for p in room.playerList:
    #     p.update()
    
    # for a in room.actorList:
    #     a.update()

    # for b in room.actorList:
    #     b.update()