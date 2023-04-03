import actor
import flatty
import ../../common/vectors
import tilengine/tilengine

type
    Player* = ref object of Actor
        character*: uint8
        lifes*: uint8

proc constructPlayer*(position: VectorI16, character: uint8, lifes: uint8): Player =
    var player = Player()
    player.position = position
    player.character = character
    player.lifes = lifes

method draw*(player: Player): void =
    Sprite(player.character).setPosition(player.position.x, player.position.y)

proc unserialize*(data: string): Player = return fromFlatty(data, Player)