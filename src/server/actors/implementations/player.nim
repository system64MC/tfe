import ../actors
import ../../../common/vectors
import ../../../common/message
import ../../utils/hitbox
import flatty
import tilengine/tilengine
import ../../room/room
import ../../gameInfos
import math
import ../../../common/constants

# Thoses methods has to be declared here to avoid a compiler error that says invalid declaration order.
# They won't be used anyways, since actor is the root object.
method update*(actor: Actor, infos: var GameInfos): void {.base.} = 
    return
method serialize*(actor: Actor): string {.base.} =
    return ""

var playerInput*: uint8 = 0b0000_0000 # Input of player.

type
    # WARNING : This object is for serializing only! Do not use for gameplay!
    PlayerSerialize = ref object of Actor
        character*: uint8
        lifes*: uint8

proc constructPlayer*(position: VectorF64, character: uint8, lifes: uint8): actors.Player =
    var player = actors.Player()
    player.position = position
    player.character = character
    player.lifes = lifes
    player.hitbox = Hitbox(size: VectorU8(x: 15, y: 31))
    return player

proc inputUp(player: actors.Player):    bool = return ((player.input and 0b0000_1000) > 0) 
proc inputDown(player: actors.Player):  bool = return ((player.input and 0b0000_0100) > 0)
proc inputLeft(player: actors.Player):  bool = return ((player.input and 0b0000_0010) > 0)
proc inputRight(player: actors.Player): bool = return ((player.input and 0b0000_0001) > 0)
proc inputFire(player: actors.Player):  bool = return ((player.input and 0b0001_0000) > 0)
proc inputA(player: actors.Player):     bool = return ((player.input and 0b0010_0000) > 0)
proc inputB(player: actors.Player):     bool = return ((player.input and 0b0100_0000) > 0)

method checkCollisions(player: actors.Player, loadedRoom: Room): void =
    if(loadedRoom == nil): return

    let camX = loadedRoom.camera.position.x
    let camV = loadedRoom.camera.velocity.x

    let map = loadedRoom

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
                if(not loadedRoom.switchOn): continue
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
                if(loadedRoom.switchOn): continue
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
                if(not loadedRoom.switchOn): continue
                let correct = (player.position.y + player.velY) mod 16.0
                if i < 2:
                    # Top side
                    player.velY += 16 - correct
                    break
                # Bottom side
                player.velY -= correct
                break
            of Collision.TILE_SWITCH_OFF:
                if(loadedRoom.switchOn): continue
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

# Do not use. This is the old collisions engine. Keeping as archive for now.
method checkCollisionsOld(player: actors.Player, loadedRoom: Room): void =
    let camX = loadedRoom.camera.position.x
    let camV = loadedRoom.camera.velocity.x
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
            tile = getTile(VectorF64(x: player.position.x + player.hitbox.size.x.float64 + player.velX + camX, y: i), loadedRoom)        
        else:
            tile = getTile(VectorF64(x: player.position.x + player.velX + camX, y: i), loadedRoom)

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
            tileLeft = getTile(VectorF64(x: player.position.x + player.velX + camX, y: i), loadedRoom)
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
            tile = getTile(VectorF64(x: i + camX + camV, y: player.position.y + player.hitbox.size.y.float64 + player.velY), loadedRoom)        
        else:
            tile = getTile(VectorF64(x: i + camX + camV, y: player.position.y + player.velY), loadedRoom)        

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
    

# proc addBullet*(game: GameInstance, isPlayer: bool = true, bType: int = 0, direction: VectorF64 = VectorF64(x: 0, y: 1), position: VectorF64): void =
#   for i in 0..<512:
#     if(game.infos.bulletList[i] != nil): continue
#     game.infos.bulletList[i] = Bullet(
#       isPlayer: isPlayer, 
#       bulletType: bType, 
#       vector: direction, 
#       position: position, 
#       bulletId: i.uint16, 
#       currentRoom: game.infos.loadedRoom,
#       eventCallback:
#       (
#         proc(message: message.Message) =
#           game.infos.eventList.add(message)
#       )
#       )
#     break

method fire*(player: actors.Player, bulletList: var array[512, Bullet]): void {.base, gcsafe.} =
    if(player.timers[0] > 0): return
    for i in 0..<512:
        if(bulletList[i] != nil): continue
        bulletList[i] = Bullet(
        isPlayer: true, 
        bulletType: 0, 
        vector: VectorF64(x: 0, y: 4),
        position: VectorF64(
            x: player.position.x + player.hitbox.size.x.float64,
            y: player.position.y + player.hitbox.size.y.float64 / 2
        ),
        bulletId: i.uint16, 
        currentRoom: nil,
        )
        player.timers[0] = 5
        return

method update*(player: actors.Player, infos: var GameInfos): void =
    for i in 0..<player.timers.len:
        if(player.timers[i] > 0):
            player.timers[i].dec
    if(player.isNil): return
    if(player.inputUp()):    player.velY -= 2 * player.deltaTime * TPS
    if(player.inputDown()):  player.velY += 2 * player.deltaTime * TPS
    if(player.inputLeft()):  player.velX -= 2 * player.deltaTime * TPS
    if(player.inputRight()): player.velX += 2 * player.deltaTime * TPS
    if(player.inputFire()): player.fire(infos.bulletList)

    # TODO : Remove this
    if(player.inputA()): infos.loadedRoom.camera.velocity.x = -1.0
    if(player.inputB()): infos.loadedRoom.camera.velocity.x =  1.0
    infos.loadedRoom.camera.position.x += infos.loadedRoom.camera.velocity.x
    player.checkCollisions(infos.loadedRoom)

    player.position.x += player.velX
    player.position.y += player.velY
    infos.loadedRoom.camera.velocity.x = 0
    player.velX = 0
    player.velY = 0
    player.input = 0
    return

method serialize*(player: actors.Player): string = 
    var p = PlayerSerialize()
    p.position = player.position
    p.hitbox = player.hitbox
    p.velX = player.velX
    p.velY = player.velY
    p.lifes = player.lifes
    p.character = player.character
    return toFlatty(message.Message(header: MessageHeader.PLAYER_DATA, data: toFlatty(p)))