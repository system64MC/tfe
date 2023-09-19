import actor
import ../actors
import ../bulletList
import common/vectors
import math
import random
import ../../room/room
import common/message
import common/events
import common/commonActors
import ../../utils/hitbox
import ../../gameInfos
import tilengine/tilengine
import flatty
import std/tables

# Thoses methods has to be declared here to avoid a compiler error that says invalid declaration order.
# They won't be used anyways, since actor is the root object.
method update*(actor: Actor, infos: var GameInfos): void {.base.} = 
    return
method serialize*(actor: Actor): string {.base.} =
    return ""

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
    if bullet.playerId < 0: return
    var tile:Tile
    let camX = infos.loadedRoom.camera.position.x
    tile = getTile(VectorF64(x: bullet.position.x + camX, y: bullet.position.y), infos.loadedRoom)
    case tile.index.Collision:
        of Collision.SOLID, KILLER_TILE:
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
            infos.loadedRoom.playerList[bullet.playerId].score += 50
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

proc addBonus*(infos: var GameInfos, bType: BonusType, position: VectorF64) =
    for i in 0..7:
        if(infos.loadedRoom.bonusList[i] == nil):
            infos.loadedRoom.bonusList[i] = Bonus(
                position: position,
                index: i,
                bType: bType
            )
            echo "add bonus : ", bType
            return

proc checkCollisionsWithActor(bullet: Bullet, infos: var GameInfos): bool =
    if(bullet.playerId < 0):
        for p in infos.loadedRoom.playerList:
            if(p == nil): continue
            if(p.state != PLAYER_ALIVE): continue
            let cx = bullet.position.x - (p.position.x + (p.hitbox.size.x.float / 2))
            let cy = bullet.position.y - (p.position.y + (p.hitbox.size.y.float / 2))

            let cx2 = cx * cx
            let cy2 = cy * cy

            if((cx2 + cy2) <= (4 + 4) * (4 + 4)):
                p.die()
                return true
    else:
        proc checkCollisionsEnemy(e: Enemy, infos: var GameInfos): bool =
            if(e == nil): return false
            if(e.state notin {GO_IN, SHOOTING, GO_OUT}): return false

            let relPos = e.position - infos.loadedRoom.camera.position 

            var testX = bullet.position.x
            var testY = bullet.position.y

            if(bullet.position.x < relPos.x): testX = relPos.x
            elif(bullet.position.x > relPos.x + e.hitbox.size.x.float): testX = relPos.x + e.hitbox.size.x.float
            
            if(bullet.position.y < relPos.y): testY = relPos.y
            elif(bullet.position.y > relPos.y + e.hitbox.size.y.float): testY = e.position.y + e.hitbox.size.y.float

            let distX = bullet.position.x - testX
            let distY = bullet.position.y - testY

            let dist = sqrt((distX * distX) + (distY * distY))

            if(dist <= 4): 
                e.hurt(1)
                if(e.lifePoints <= 0):
                    infos.loadedRoom.playerList[bullet.playerId].score += 100
                    let dice: int = rand(31)
                    case dice:
                    of 3, 9, 17, 24, 30: infos.addBonus(DOUBLE, relPos)
                    of 1, 5, 14, 28, 31: infos.addBonus(TRIPLE, relPos)
                    of 2, 4, 18: infos.addBonus(ONE_UP, relPos)
                    of 6, 10, 19, 12: infos.addBonus(BOMB_UP, relPos)
                    else: discard
                echo "Enemy hit!"
                return true

        for e in infos.loadedRoom.enemyList:
            if(e.checkCollisionsEnemy(infos)): return true

        if(infos.loadedRoom.isBoss):
            if(infos.loadedRoom.boss.checkCollisionsEnemy(infos)): return true

    return false

method update*(bullet: Bullet, infos: var GameInfos): void = 
    if(bullet.checkCollisionsWithActor(infos) or bullet.checkCollisions(infos)):
        infos.loadedRoom.bulletList.remove(bullet)
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
    b.bulletId = bullet.bulletId
    return b

# method serialize*(bullet: Bullet): string = 
#     var b = BulletSerialize()
#     b.position = bullet.position
#     b.hitbox = bullet.hitbox
#     b.velX = bullet.velX
#     b.velY = bullet.velY
#     b.bulletType = bullet.bulletType
#     b.bulletId = bullet.bulletId
#     return toFlatty(message.Message(header: MessageHeader.BULLET_DATA, data: toFlatty(b)))