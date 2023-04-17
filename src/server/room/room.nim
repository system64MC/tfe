import ../camera
import ../actors/actor
import ../actors/ennemy
import ../../common/vectors
import ../actors/player
import ../actors/bullet
import tilengine/tilengine

type
  Room* = ref object
    camera*: Camera
    collisions*: Tilemap
    # playerList*: array[4, player.Player]
    actorList*: seq[Actor]
    bulletList*: seq[Bullet]

  Collision* = enum
    NULL_TILE
    AIR
    SOLID
    SWITCH_TILE

var loadedRoom*: Room

proc loadRoom*(path: string): Room =
    var room = Room()
    room.collisions = loadTilemap(path, "collisions")
    
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

method update(room: Room): void =
    room.camera.update()

    # for p in room.playerList:
    #     p.update()
    
    for a in room.actorList:
        a.update()

    for b in room.actorList:
        b.update()