import common/commonActors
import common/serializedObjects
import room/background
import tilengine/bitmapUtils
import common/vectors
import tilengine/tilengine

method draw*(actor: Actor): void {.base.} = 
    return

method draw*(player: PlayerSerialize): void =
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, player.hitbox.size.x.int, 1, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int + player.hitbox.size.y.int, player.hitbox.size.x.int + 1, 1, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int + player.hitbox.size.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 1)
    Sprite(player.character).setPosition(player.position.x.int32, player.position.y.int32)

method draw*(bullet: Bullet): void =
    bitmap.drawCircleFill(Point(x: bullet.position.x.int, y: bullet.position.y.int), 4)