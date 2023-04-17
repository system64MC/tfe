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

proc getTile(pos: VectorI16): Tile =
    return room.loadedRoom.collisions.getTile(pos.y.int shr 4, pos.x.int shr 4)


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

    var hTests = @[player.position.y, (player.position.y + player.hitbox.size.y.int16) - 1, player.position.y + (player.hitbox.size.y shr 1).int16]
    var vTests = @[player.position.x, (player.position.x + player.hitbox.size.x.int16) - 1]


    for i in hTests:

        var tile:Tile

        if(player.velX >= 0):
            tile = getTile(VectorI16(x: player.position.x + player.hitbox.size.x.int16 + player.velX, y: player.position.y))        
        else:
            tile = getTile(VectorI16(x: player.position.x + player.velX, y: player.position.y))        

        case tile.index.Collision:
            of Collision.SOLID:
                if(player.velX >= 0):
                    let correct = (player.position.x + player.hitbox.size.x.int16 + player.velX) and 0xF
                    player.velX -= correct
                elif(player.velX < 0):
                    let correct = (player.position.x + player.velX) and 0xF
                    player.velX += ((16 - correct) and 15)


                return    
            else:
                return
    
    


method update*(player: Player): void =
    if(player.isNil): return
    if(inputUp()):    player.velY -= 4
    if(inputDown()):  player.velY += 4
    if(inputLeft()):  player.velX -= 4
    if(inputRight()): player.velX += 4
    player.checkCollisions()
    player.position.x += player.velX
    player.position.y += player.velY
    player.velX = 0
    player.velY = 0
    return

method serialize*(player: Player): string = return toFlatty(player) 