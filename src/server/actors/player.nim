import actor
import ../../common/vectors
import ../utils/hitbox
import flatty
import netty
import tilengine/tilengine
import ../room/room

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
    player.hitbox = Hitbox(size: VectorU8(x: 16, y: 32))
    return player

proc inputUp():    bool = return ((playerInput and 0b0000_1000) > 0) 
proc inputDown():  bool = return ((playerInput and 0b0000_0100) > 0)
proc inputLeft():  bool = return ((playerInput and 0b0000_0010) > 0)
proc inputRight(): bool = return ((playerInput and 0b0000_0001) > 0)

method checkCollisions(player: Player): void =
    #[
        Algorithm :
            for each points of the player :
                Check the tile
                if tile == SOLID: correct
                if tile == SwitchTile:
                    if Switch is ON: correct
                if tile == deadTile: kill
                if tile == destructible: correct
    ]#
    let tile = room.loadedRoom.collisions.getTile(player.position.y.int shr 4, player.position.x.int shr 4)
    echo tile.index
    if(tile.index == Collision.SOLID): echo "you just collided"
    return

method update*(player: Player): void =
    if(player.isNil): return
    if(inputUp()):    player.position.y -= 4
    if(inputDown()):  player.position.y += 4
    if(inputLeft()):  player.position.x -= 4
    if(inputRight()): player.position.x += 4
    player.checkCollisions()
    return

method serialize*(player: Player): string = return toFlatty(player) 