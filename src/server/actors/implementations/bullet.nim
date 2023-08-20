import actor
import ../../../common/vectors
import math
import ../../room/room
import ../../../common/message
import ../../../common/events
import ../../utils/hitbox
import ../../gameInfos
import tilengine/tilengine
import flatty
from ../actors import Bullet
from ../actors import Actor
import std/tables

type
    BulletSerialize* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        bulletId*: uint16

    # Bullet* = ref object of Actor
    #     bulletType*: int
    #     isPlayer*: bool
    #     bulletId*: uint16
    #     vector*: VectorF64
    #     currentRoom*: Room
    #     eventCallback*: proc(message: message.Message): void {.gcsafe.}

proc checkCollisions(bullet: Bullet, infos: var GameInfos): bool =
    var tile:Tile
    let camX = infos.loadedRoom.camera.position.x
    tile = getTile(VectorF64(x: bullet.position.x + camX, y: bullet.position.y), infos.loadedRoom)
    case tile.index.Collision:
        of Collision.SOLID:
            return true
        of Collision.DESTROYABLE_TILE:
            tile.index = AIR.uint16
            let x = (bullet.position.x + camX).int shr 4 
            let y = bullet.position.y.int shr 4
            infos.loadedRoom.collisions.setTile(y, x, tile)
            infos.loadedRoom.destroyableTilesList[VectorI64(x: x.int, y: y.int)] = false
            let pos = VectorI64(x: x, y: y)
            let tileChangeEvent = EventTileChange(coordinates: pos, tileType: AIR.uint16)
            let m = Message(header: message.EVENT_DESTROY_TILE, data: toFlatty(tileChangeEvent))
            infos.eventList.add(m)
            return true
        of Collision.SWITCH_TILE:
            infos.loadedRoom.switchOn = not infos.loadedRoom.switchOn
            let switchEvent = EventSwitch(state: infos.loadedRoom.switchOn)
            let m = Message(header: message.EVENT_SWITCH, data: toFlatty(switchEvent))
            infos.eventList.add(m)
            return true
        of Collision.TILE_SWITCH_ON:
            if(not infos.loadedRoom.switchOn): return false
            return true
        of Collision.TILE_SWITCH_OFF:
            if(infos.loadedRoom.switchOn): return false
            return true
        else:
            return false

method update*(bullet: Bullet, infos: var GameInfos): void = 
    if(bullet.checkCollisions(infos)):
        infos.bulletList.remove(bullet.bulletId.int)
        # bullet.bulletType = -1
        return

    # Getting X component
    let xSpeed = bullet.vector.y * cos(bullet.vector.x.degToRad)
    
    # Getting Y component
    let ySpeed = bullet.vector.y * sin(bullet.vector.x.degToRad)

    bullet.position.x += xSpeed
    bullet.position.y += ySpeed
    return

proc toSerializeObject*(bullet: Bullet): BulletSerialize = 
    var b = BulletSerialize()
    b.position = bullet.position
    b.hitbox = bullet.hitbox
    b.velX = bullet.velX
    b.velY = bullet.velY
    b.bulletType = bullet.bulletType
    b.isPlayer = bullet.isPlayer
    b.bulletId = bullet.bulletId
    return b

method serialize*(bullet: Bullet): string = 
    var b = BulletSerialize()
    b.position = bullet.position
    b.hitbox = bullet.hitbox
    b.velX = bullet.velX
    b.velY = bullet.velY
    b.bulletType = bullet.bulletType
    b.isPlayer = bullet.isPlayer
    b.bulletId = bullet.bulletId
    return toFlatty(message.Message(header: MessageHeader.BULLET_DATA, data: toFlatty(b)))