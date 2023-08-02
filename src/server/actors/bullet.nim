import actor
import ../../common/vectors
import math
import ../room/room
import ../../common/message
import ../../common/events
import ../utils/hitbox
import tilengine/tilengine
import flatty

type
    BulletSerialize* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        bulletId*: uint16

    Bullet* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        bulletId*: uint16
        vector*: VectorF64
        currentRoom*: Room
        eventCallback*: proc(message: message.Message): void {.gcsafe.}

proc checkCollisions(bullet: Bullet): bool =
    var tile:Tile
    let camX = bullet.currentRoom.camera.position.x
    tile = getTile(VectorF64(x: bullet.position.x + camX, y: bullet.position.y), bullet.currentRoom)
    case tile.index.Collision:
        of Collision.SOLID:
            return true
        of Collision.DESTROYABLE_TILE:
            tile.index = AIR.uint16
            let x = bullet.position.x.int shr 4 
            let y = bullet.position.y.int shr 4
            bullet.currentRoom.collisions.setTile(y, x, tile)
            let pos = VectorI64(x: x, y: y)
            let tileChangeEvent = EventTileChange(coordinates: pos, tileType: AIR.uint16)
            let m = Message(header: message.EVENT_DESTROY_TILE, data: toFlatty(tileChangeEvent))
            bullet.eventCallback(m)
            return true
        of Collision.SWITCH_TILE:
            bullet.currentRoom.switchOn = not bullet.currentRoom.switchOn
            return true
        of Collision.TILE_SWITCH_ON:
            if(not bullet.currentRoom.switchOn): return false
            return true
        of Collision.TILE_SWITCH_OFF:
            if(bullet.currentRoom.switchOn): return false
            return true
        else:
            return false

method update*(bullet: Bullet): void = 
    # Getting X component
    if(bullet.checkCollisions):
        bullet.bulletType = -1
        return
    let xSpeed = bullet.vector.y * cos(bullet.vector.x)
    
    # Getting Y component
    let ySpeed = bullet.vector.y * sin(bullet.vector.x)

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