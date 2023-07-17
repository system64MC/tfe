import actor
import ../../common/vectors
import math
import ../room/room
import ../../common/message
import ../utils/hitbox
import tilengine/tilengine
import flatty
import netty

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

proc checkCollisions(bullet: Bullet): bool =
    var tile:Tile
    let camX = bullet.currentRoom.camera.position.x
    tile = getTile(VectorF64(x: bullet.position.x + camX, y: bullet.position.y), bullet.currentRoom)
    case tile.index.Collision:
        of Collision.SOLID:
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