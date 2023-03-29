import actor
import ../../common/vectors
import flatty
import netty

var playerInput*: uint8 = 0b0000_0000 # Input of player.

type
    Player* = ref object of Actor
        character*: uint8
        lifes*: uint8

proc constructPlayer*(position: VectorI16, character: uint8, lifes: uint8): Player =
    var player = Player()
    player.position = position
    player.character = character
    player.lifes = lifes
    return player

proc inputUp():    bool = return ((playerInput and 0b0000_1000) > 0)
proc inputDown():  bool = return ((playerInput and 0b0000_0100) > 0)
proc inputLeft():  bool = return ((playerInput and 0b0000_0010) > 0)
proc inputRight(): bool = return ((playerInput and 0b0000_0001) > 0)

method update*(player: Player): void =
    if(inputUp()):    player.position.y -= 4
    if(inputDown()):  player.position.y += 4
    if(inputLeft()):  player.position.x -= 4
    if(inputRight()): player.position.x += 4
    return

method serialize*(player: Player): string = return toFlatty(player) 