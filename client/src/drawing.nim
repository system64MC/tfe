import common/commonActors
import common/serializedObjects
# import room/background
import tilengine/bitmapUtils
import common/vectors
import tilengine/tilengine

method draw*(actor: Actor, bitmap: Bitmap): void {.base.} = 
    return

type
    SpriteTypes* = enum
        CURSOR,
        PLAYER,
        CHARACTERS

var sprites*: array[256, Spriteset]
sprites[0] = loadSpriteset("./assets/sprites/cursor.png")
sprites[1] = loadSpriteset("./assets/sprites/player.png")
sprites[2] = loadSpriteset("./assets/sprites/characters.png")

proc draw*(player: PlayerSerialize, bitmap: Bitmap): void =
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, player.hitbox.size.x.int, 1, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int + player.hitbox.size.y.int, player.hitbox.size.x.int + 1, 1, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int + player.hitbox.size.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 1)
    bitmap.drawText(Point(x: (player.position.x.int + player.hitbox.size.x.int shr 1) - (player.name.len * 4) shr 1, y: player.position.y.int - 8), player.name, 2)
    Sprite(player.character + 1).setPosition(player.position.x.int32, player.position.y.int32)

proc draw*(bullet: Bullet, bitmap: Bitmap): void =
    bitmap.drawCircleFill(Point(x: bullet.position.x.int, y: bullet.position.y.int), 4)