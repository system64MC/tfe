import actor
import ../../common/vectors
import ../../common/message
import ../utils/hitbox
import flatty
import netty
import tilengine/tilengine
import ../room/room
import math

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
        timers*: array[8, uint16]

proc constructPlayer*(position: VectorF64, character: uint8, lifes: uint8): Player =
    var player = Player()
    player.position = position
    player.character = character
    player.lifes = lifes
    player.hitbox = Hitbox(size: VectorU8(x: 15, y: 31))
    return player

proc inputUp(player: Player):    bool = return ((player.input and 0b0000_1000) > 0) 
proc inputDown(player: Player):  bool = return ((player.input and 0b0000_0100) > 0)
proc inputLeft(player: Player):  bool = return ((player.input and 0b0000_0010) > 0)
proc inputRight(player: Player): bool = return ((player.input and 0b0000_0001) > 0)
proc inputFire(player: Player):  bool = return ((player.input and 0b0001_0000) > 0)
proc inputA(player: Player):     bool = return ((player.input and 0b0010_0000) > 0)
proc inputB(player: Player):     bool = return ((player.input and 0b0100_0000) > 0)



method setPlayerCallback*(player: Player, callback: proc(): void {.gcsafe.}, index: uint8): void {.base, gcsafe.} =
    player.callbacks[index] = callback
    return

method checkCollisionsNew(player: Player): void =
    let camX = player.currentRoom.camera.position.x
    let camV = player.currentRoom.camera.velocity.x

    let map = player.currentRoom

    # We get all Wall tiles at the start, so this way, we can get all informations about the environment
    # This can be useful to check if the player got crushed by 2 walls or other use cases
    let wallTiles: array[6, Tile] = [
        # Left side
        getTile(VectorF64(x: player.position.x + player.velX + camX, y: player.position.y), map),
        getTile(VectorF64(x: player.position.x + player.velX + camX, y: player.position.y + player.hitbox.size.y.float64 / 2), map),
        getTile(VectorF64(x: player.position.x + player.velX + camX, y: player.position.y + player.hitbox.size.y.float64), map),
        
        # Right side
        getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX + camX, y: player.position.y), map),
        getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX + camX, y: player.position.y + player.hitbox.size.y.float64 / 2), map),
        getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX + camX, y: player.position.y + player.hitbox.size.y.float64), map),
    ]

    # Walls
    for i in 0..<6:
        case wallTiles[i].index.Collision:

            of Collision.SOLID:
                let correct = (player.position.x + player.velX + camX) mod 16.0
                if i < 3:
                # Left side
                    player.velX += 16 - correct
                    break
                # Right side
                player.velX -= correct
                break

            of Collision.DESTROYABLE_TILE:
                let correct = (player.position.x + player.velX + camX) mod 16.0
                if i < 3:
                # Left side
                    player.velX += 16 - correct
                    break
                # Right side
                player.velX -= correct
                break
            of Collision.SWITCH_TILE:
                let correct = (player.position.x + player.velX + camX) mod 16.0
                if i < 3:
                # Left side
                    player.velX += 16 - correct
                    break
                # Right side
                player.velX -= correct
                break
            of Collision.TILE_SWITCH_ON:
                # If the Switch is not ON, the ON tiles are not solid
                if(not player.currentRoom.switchOn): continue
                let correct = (player.position.x + player.velX + camX) mod 16.0
                if i < 3:
                # Left side
                    player.velX += 16 - correct
                    break
                # Right side
                player.velX -= correct
                break
            of Collision.TILE_SWITCH_OFF:
                # If the Switch is ON, the OFF tiles are not solid
                if(player.currentRoom.switchOn): continue
                let correct = (player.position.x + player.velX + camX) mod 16.0
                if i < 3:
                # Left side
                    player.velX += 16 - correct
                    break
                # Right side
                player.velX -= correct
                break
            else:
                continue

    # We get all Ceiling and Floor tiles at the start, so this way, we can get all informations about the environment
    # This can be useful to check if the player got crushed by 2 ceilings or other use cases
    let ceilingTiles: array[4, Tile] = [
        # Top side
        getTile(VectorF64(x: player.position.x + player.velX + camX, y: player.position.y + player.velY), map),
        getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX + camX, y: player.position.y + player.velY), map),

        # Bottom side
        getTile(VectorF64(x: player.position.x + player.velX + camX, y: player.position.y + player.hitbox.size.y.float64 + player.velY), map),
        getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX + camX, y: player.position.y + player.hitbox.size.y.float64 + player.velY), map),
    ]

    # Ceilings
    for i in 0..<4:
        case ceilingTiles[i].index.Collision:

            of Collision.SOLID:
                let correct = (player.position.y + player.velY) mod 16.0
                if i < 2:
                    # Top side
                    player.velY += 16 - correct
                    break
                # Bottom side
                player.velY -= correct
                break

            of Collision.DESTROYABLE_TILE:
                let correct = (player.position.y + player.velY) mod 16.0
                if i < 2:
                    # Top side
                    player.velY += 16 - correct
                    break
                # Bottom side
                player.velY -= correct
                break
            of Collision.SWITCH_TILE:
                let correct = (player.position.y + player.velY) mod 16.0
                if i < 2:
                    # Top side
                    player.velY += 16 - correct
                    break
                # Bottom side
                player.velY -= correct
                break
            of Collision.TILE_SWITCH_ON:
                if(not player.currentRoom.switchOn): continue
                let correct = (player.position.y + player.velY) mod 16.0
                if i < 2:
                    # Top side
                    player.velY += 16 - correct
                    break
                # Bottom side
                player.velY -= correct
                break
            of Collision.TILE_SWITCH_OFF:
                if(player.currentRoom.switchOn): continue
                let correct = (player.position.y + player.velY) mod 16.0
                if i < 2:
                    # Top side
                    player.velY += 16 - correct
                    break
                # Bottom side
                player.velY -= correct
                break
            else:
                continue

method checkCollisions(player: Player): void =
    let camX = player.currentRoom.camera.position.x
    let camV = player.currentRoom.camera.velocity.x
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

    # Getting test points for walls
    var hTests = @[player.position.y, (player.position.y + player.hitbox.size.y.float64) - 1, player.position.y + (player.hitbox.size.y shr 1).float64]
    
    # Getting test points for ceilings
    var vTests = @[player.position.x, (player.position.x + player.hitbox.size.x.float64) - 1]

    # Testing for walls
    for i in hTests:

        var tile:Tile
        var tileLeft:Tile

        # Getting the tile to test against
        if(player.velX >= 0):
            tile = getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX + camX, y: i), player.currentRoom)        
        else:
            tile = getTile(VectorF64(x: player.position.x + player.velX + camX, y: i), player.currentRoom)

        # Doing the according action depending of the tile type
        case tile.index.Collision:
            # Here we do a correction
            of Collision.SOLID:
                if(player.velX >= 0):
                    let correct = (player.position.x + player.hitbox.size.x.float64 + player.velX + camX - camV) mod 16.0
                    player.velX -= correct
                elif(player.velX < 0):
                    let correct = (player.position.x + player.velX + camX - camV) mod 16.0
                    player.velX += ((16 - correct) mod 16.0)
            # If the tile is unknown, we do nothing and we test the next point.
            else:
                player.velX = player.velX

        if(player.velX == 0):
            tileLeft = getTile(VectorF64(x: player.position.x + player.velX + camX, y: i), player.currentRoom)
            case tileLeft.index.Collision:
            # Here we do a correction
            of Collision.SOLID:
                let correct = (player.position.x + player.velX + camX - camV) mod 16.0
                player.velX += ((16 - correct) mod 16.0)
            # If the tile is unknown, we do nothing and we test the next point.
            else:
                player.velX = player.velX

    player.position.x += player.velX

    # Testing for ceilings
    for i in vTests:

        var tile:Tile

        # Getting the tile to test against
        if(player.velY >= 0):
            tile = getTile(VectorF64(x: i + camX + camV, y: player.position.y + player.hitbox.size.y.float64 + player.velY), player.currentRoom)        
        else:
            tile = getTile(VectorF64(x: i + camX + camV, y: player.position.y + player.velY), player.currentRoom)        

        # Doing the according action depending of the tile type
        case tile.index.Collision:
            # Here we do a correction
            of Collision.SOLID:
                if(player.velY >= 0):
                    let correct = (player.position.y + player.hitbox.size.y.float64 + player.velY) mod 16.0
                    player.velY -= correct
                elif(player.velY <= 0):
                    let correct = (player.position.y + player.velY) mod 16.0
                    player.velY += ((16 - correct) mod 16.0)
            # If the tile is unknown, we do nothing and we test the next point.
            else:
                player.velY = player.velY

    player.position.y += player.velY
    
    
method fire*(player: Player): void {.base, gcsafe.} =
    if(player.timers[0] == 0):
        player.callbacks[0]()
        player.timers[0] = 5
    return

method update*(player: Player): void =
    for i in 0..<player.timers.len:
        if(player.timers[i] > 0):
            player.timers[i].dec
    if(player.isNil): return
    if(player.inputUp()):    player.velY -= 4
    if(player.inputDown()):  player.velY += 4
    if(player.inputLeft()):  player.velX -= 4
    if(player.inputRight()): player.velX += 4
    if(player.inputFire()): player.fire()

    # DODO : Remove this
    if(player.inputA()): player.currentRoom.camera.velocity.x = -1.0
    if(player.inputB()): player.currentRoom.camera.velocity.x =  1.0
    player.currentRoom.camera.position.x += player.currentRoom.camera.velocity.x
    player.checkCollisionsNew()
    player.position.x += player.velX
    player.position.y += player.velY
    player.currentRoom.camera.velocity.x = 0
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
    return toFlatty(message.Message(header: MessageHeader.PLAYER_DATA, data: toFlatty(p)))