import actor
import ../actors
import ../bulletList
import common/vectors
import math
import ../../room/room
import common/message
import common/events
import common/commonActors
import ../../utils/hitbox
import ../../gameInfos
import tilengine/tilengine
import flatty
import std/tables

proc collisionWithPlayer*(bonus: Bonus, infos: var GameInfos): bool =
    for p in infos.loadedRoom.playerList:
        if(p == nil): continue
        if(p.state notin {PLAYER_ALIVE, PLAYER_INVINCIBLE}): continue
        if(
            (bonus.position.x + 15.float >= p.position.x) and
            (bonus.position.x <= p.position.x + p.hitbox.size.x.float) and
            (bonus.position.y + 15.float >= p.position.y) and
            (bonus.position.y <= p.position.y + p.hitbox.size.y.float)
            ):
                case bonus.bType:
                of BonusType.DOUBLE: p.powerUp = Powerup.DOUBLE
                of BonusType.TRIPLE: p.powerUp = Powerup.TRIPLE
                of BonusType.ONE_UP: p.lifes = min(p.lifes + 1, 8)
                of BonusType.BOMB_UP: p.bombs = min(p.bombs + 1, 8)
                else: discard

                infos.loadedRoom.bonusList[bonus.index] = nil
                p.score += 30
                return true

    return false

proc offScreen*(bonus: Bonus, infos: var GameInfos): bool =
    if(bonus.position.x < 0 - 15): 
        infos.loadedRoom.bonusList[bonus.index] = nil
        return true
    
    return false

method update*(bonus: Bonus, infos: var GameInfos): void =
    if(bonus.collisionWithPlayer(infos) or bonus.offScreen(infos)): return
    bonus.position.x -= 0.5