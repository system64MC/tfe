import actor
import flatty
import common/vectors
import tilengine/tilengine
import ../utils/hitbox
import ../room/background
import tilengine/bitmapUtils

type
    Player* = ref object of Actor
        character*: uint8
        lifes*: uint8

proc constructPlayer*(position: VectorF64, character: uint8, lifes: uint8): Player =
    var player = Player()
    player.position = position
    player.character = character
    player.lifes = lifes
    player.hitbox = Hitbox(size: VectorU8(x: 16, y: 32))
    return player

method draw*(player: Player): void =
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, player.hitbox.size.x.int, 1, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int + player.hitbox.size.y.int, player.hitbox.size.x.int + 1, 1, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 1)
    bitmap.drawRectWH(player.position.x.int + player.hitbox.size.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 1)
    Sprite(player.character).setPosition(player.position.x.int32, player.position.y.int32)

proc unserialize*(data: string): Player = return fromFlatty(data, Player)