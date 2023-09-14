import common/commonActors
import common/serializedObjects
# import room/background
import tilengine/bitmapUtils
import common/vectors
import tilengine/tilengine
import std/strutils

method draw*(actor: Actor, bitmap: Bitmap): void {.base.} = 
    return

type
    SpriteTypes* = enum
        CURSOR,
        PLAYER,
        CHARACTERS,
        BONUS

var sprites*: array[256, Spriteset]
sprites[0] = loadSpriteset("./assets/sprites/cursor.png")
sprites[1] = loadSpriteset("./assets/sprites/player.png")
sprites[2] = loadSpriteset("./assets/sprites/characters.png")
sprites[3] = loadSpriteset("./assets/sprites/bonus.png")
let hud* = loadTilemap("./assets/tilemaps/hud.tmx", "hud")
let gameOver* = loadTilemap("./assets/tilemaps/gameOver.tmx", "background")
let gameFinish* = loadTilemap("./assets/tilemaps/gameFinish.tmx", "background")
var scrollTable*: array[18, float]
var camPos*: VectorF64

proc draw*(player: PlayerSerialize, bitmap: Bitmap): void =
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, player.hitbox.size.x.int, 1, 0, 0, 3)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int + player.hitbox.size.y.int, player.hitbox.size.x.int + 1, 1, 0, 0, 3)
    bitmap.drawRectWH(player.position.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 3)
    bitmap.drawRectWH(player.position.x.int + player.hitbox.size.x.int, player.position.y.int, 1, player.hitbox.size.y.int, 0, 0, 3)
    
    let cx = (player.position.x + (player.hitbox.size.x.float / 2))
    let cy = (player.position.y + (player.hitbox.size.y.float / 2))
    
    bitmap.drawCircleFill(Point(x: cx.int, y: cy.int), 4, color = 3)

    bitmap.drawText(Point(x: (player.position.x.int + player.hitbox.size.x.int shr 1) - (player.name.len * 4) shr 1, y: player.position.y.int - 8), player.name, 2)
    Sprite(player.character + 1).setPosition(player.position.x.int32, player.position.y.int32)

proc drawBombing*(player: PlayerSerialize, bitmap: Bitmap) =
    bitmap.drawCircleFill(Point(x: (player.position.x + (player.hitbox.size.x.float / 2)).int, y: (player.position.y + player.hitbox.size.y.float / 2).int), 180 - player.bombTimer)

proc draw*(enemy: Enemy, bitmap: Bitmap, offset: float): void =
    bitmap.drawRectWH((enemy.position.x - offset).int, enemy.position.y.int, enemy.hitbox.size.x.int, 1, 0, 0, 1)
    bitmap.drawRectWH((enemy.position.x - offset).int, enemy.position.y.int + enemy.hitbox.size.y.int, enemy.hitbox.size.x.int + 1, 1, 0, 0, 1)
    bitmap.drawRectWH((enemy.position.x - offset).int, enemy.position.y.int, 1, enemy.hitbox.size.y.int, 0, 0, 1)
    bitmap.drawRectWH((enemy.position.x - offset).int + enemy.hitbox.size.x.int, enemy.position.y.int, 1, enemy.hitbox.size.y.int, 0, 0, 1)
    # bitmap.drawText(Point(x: (player.position.x.int + player.hitbox.size.x.int shr 1) - (player.name.len * 4) shr 1, y: player.position.y.int - 8), player.name, 2)
    # Sprite(player.character + 1).setPosition(player.position.x.int32, player.position.y.int32)

proc drawHud*(player: PlayerSerialize): void =

    # clear lifes
    for i in 0..<8:
        hud.getTiles(0, 0)[i.int].index = 1

    # clear bombs
    for i in 0..<8:
        hud.getTiles(0, 9)[i].index = 1

    if(player.lifes > 0):
        # draw lifes :
        for i in 0..<8:
            if(i + 1 <= player.lifes.int):
                hud.getTiles(0, 0)[i.int].index = 2
    else:
        const gameover = "GameOver"
        var i = 0
        for c in gameover:
            hud.getTiles(0, 0)[i].index = (c.uint16 + 1)
            i.inc
    # draw bombs :
    for i in 0..<8:
        if(i + 1 <= player.bombs.int): hud.getTiles(0, 9)[i.int].index = 3

    # draw powerup :
    hud.getTiles(0, 19)[0].index = player.powerup.uint16 * 2 + 4
    hud.getTiles(0, 19)[1].index = player.powerup.uint16 * 2 + + 4 + 1

    # draw score :
    let str = ($player.score).align(9, '0')
    var i = 0
    for c in str:
        hud.getTiles(0, 23)[i].index = (c.uint16 + 1)
        i.inc

proc draw*(bullet: Bullet, bitmap: Bitmap): void =
    bitmap.drawCircleFill(Point(x: bullet.position.x.int, y: bullet.position.y.int), 4)