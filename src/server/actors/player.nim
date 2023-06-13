import actor
import ../../common/vectors
import ../utils/hitbox
import flatty
import netty
import tilengine/tilengine
import ../room/room
import math
from ../room/room import Room

var playerInput*: uint8 = 0b0000_0000 # Input of player.

type
    # This object is for serializing only! Do not use for gameplay!
    PlayerSerialize = ref object of Actor
        character*: uint8
        lifes*: uint8

    Player* = ref object of Actor
        character*: uint8
        lifes*: uint8
        input*: uint8
        callbacks: array[4, proc(): void {.gcsafe.}]
        currentRoom*: Room

proc constructPlayer*(position: VectorF64, character: uint8, lifes: uint8): Player =
    var player = Player()
    player.position = position
    player.character = character
    player.lifes = lifes
    player.hitbox = Hitbox(size: VectorU8(x: 16, y: 32))
    return player

proc inputUp(player: Player):    bool = return ((player.input and 0b0000_1000) > 0) 
proc inputDown(player: Player):  bool = return ((player.input and 0b0000_0100) > 0)
proc inputLeft(player: Player):  bool = return ((player.input and 0b0000_0010) > 0)
proc inputRight(player: Player): bool = return ((player.input and 0b0000_0001) > 0)
proc inputFire(player: Player):  bool = return ((player.input and 0b0001_0000) > 0)

proc getTile(pos: VectorF64, currentRoom: Room): Tile =
    return currentRoom.collisions.getTile(pos.y.int shr 4, pos.x.int shr 4)

method setPlayerCallback*(player: Player, callback: proc(): void {.gcsafe.}, index: uint8): void {.base, gcsafe.} =
    player.callbacks[index] = callback
    return

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

    var hTests = @[player.position.y, (player.position.y + player.hitbox.size.y.float64) - 1, player.position.y + (player.hitbox.size.y shr 1).float64]
    var vTests = @[player.position.x, (player.position.x + player.hitbox.size.x.float64) - 1]

    for i in hTests:

        var tile:Tile

        if(player.velX >= 0):
            tile = getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX, y: i), player.currentRoom)        
        else:
            tile = getTile(VectorF64(x: player.position.x + player.velX, y: i), player.currentRoom)        

        case tile.index.Collision:
            of Collision.SOLID:
                if(player.velX >= 0):
                    let correct = (player.position.x + player.hitbox.size.x.float64 + player.velX) mod 16.0
                    player.velX -= correct
                elif(player.velX < 0):
                    let correct = (player.position.x + player.velX) mod 16.0
                    player.velX += ((16 - correct) mod 16.0)


                continue
            else:
                continue

    for i in vTests:

        var tile:Tile

        if(player.velY >= 0):
            tile = getTile(VectorF64(x: i, y: player.position.y + player.hitbox.size.y.float64 + player.velY), player.currentRoom)        
        else:
            tile = getTile(VectorF64(x: i, y: player.position.y + player.velY), player.currentRoom)        

        case tile.index.Collision:
            of Collision.SOLID:
                if(player.velY >= 0):
                    let correct = (player.position.y + player.hitbox.size.y.float64 + player.velY) mod 16.0
                    player.velY -= correct
                elif(player.velY < 0):
                    let correct = (player.position.y + player.velY) mod 16.0
                    player.velY += ((16 - correct) mod 16.0)


                continue    
            else:
                continue
    
    
method fire*(player: Player): void {.base, gcsafe.} =
    echo "Fire"
    player.callbacks[0]()
    return

method update*(player: Player): void =
    if(player.isNil): return
    if(player.inputUp()):    player.velY -= 4
    if(player.inputDown()):  player.velY += 4
    if(player.inputLeft()):  player.velX -= 4
    if(player.inputRight()): player.velX += 4
    if(player.inputFire()): player.fire()
    player.checkCollisions()
    player.position.x += player.velX
    player.position.y += player.velY
    player.velX = 0
    player.velY = 0
    return

method serialize*(player: Player): string = 
    var p = PlayerSerialize()
    p.position = player.position
    p.hitbox = player.hitbox
    p.velX = player.velX
    p.velY = player.velY
    p.lifes = player.lifes
    p.character = player.character
    return toFlatty(p)