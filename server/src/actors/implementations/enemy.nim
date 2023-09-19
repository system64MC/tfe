import common/[vectors, commonActors, constants, hitbox]
import../../gameInfos
import../../room/room
import bullet
import ../bulletList
import ../actors
import math

proc updateEnemy0(enemy: Enemy, infos: var GameInfos) =
    let myPos = enemy.position - infos.loadedRoom.camera.position
    case enemy.state:
        of SLEEPING:
            
            if(myPos.x >= (0 - enemy.hitbox.size.x.float) and myPos.x <= SCREEN_X):
                # echo "Go in !!"
                enemy.state = GO_IN
        
        of GO_IN:
            if(enemy.eCountup > 40):
                enemy.state = SHOOTING
                enemy.eCountup = 0
                return
            enemy.position.x -= 2.0
            enemy.eCountup.inc

        of SHOOTING:
            # echo "Shoot!!"
            if(enemy.eCountup > 10):
                enemy.state = GO_OUT
                enemy.eCountup = 0
                return
            
            let b = Bullet(
                    playerId: -1, 
                    bulletType: 0, 
                    vector: VectorF64(x: 36 * (10 - enemy.eCountup).float64, y: 2.5),
                    position: VectorF64(
                        x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                        y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                    ),
                    bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                )
            
            infos.loadedRoom.bulletList.add(b)
            enemy.eCountup.inc

        of GO_OUT:
            enemy.position.x -= 2
            enemy.position.y -= 2
            if(myPos.x < (0 - enemy.hitbox.size.x.float) or myPos.x > SCREEN_X or 
                myPos.y < (0 - enemy.hitbox.size.y.float) or myPos.y >= SCREEN_Y):
                enemy.state = FINISHED

        of DYING:
            if(enemy.eCountup > 3 * 60):
                enemy.state = DEAD
                enemy.eCountup = 0
                return
            enemy.eCountup.inc

        else:
            discard


proc updateEnemy1(enemy: Enemy, infos: var GameInfos) =
    let myPos = enemy.position - infos.loadedRoom.camera.position
    case enemy.state:
        of SLEEPING:
            
            if(myPos.x >= (0 - enemy.hitbox.size.x.float) and myPos.x <= SCREEN_X):
                # echo "Go in !!"
                enemy.state = GO_IN
        
        of GO_IN:
            if(enemy.eCountup > 40):
                enemy.state = SHOOTING
                enemy.eCountup = 0
                return
            enemy.position.x -= 2.0
            enemy.eCountup.inc

        of SHOOTING:
            # echo "Shoot!!"
            

            for i in 0..10:
                let b = Bullet(
                    playerId: -1, 
                    bulletType: 0, 
                    vector: VectorF64(x: 36 * (10 - i).float64, y: 2.5),
                    position: VectorF64(
                        x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                        y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                    ),
                    bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                )
                infos.loadedRoom.bulletList.add(b)
            enemy.state = SHOOTED

        of SHOOTED:
            if(enemy.eCountup > 10):
                enemy.state = GO_OUT
                enemy.eCountup = 0
                return
            enemy.eCountup.inc

        of GO_OUT:
            enemy.position.x -= 2
            enemy.position.y -= 2
            if(myPos.x < (0 - enemy.hitbox.size.x.float) or myPos.x > SCREEN_X or 
                myPos.y < (0 - enemy.hitbox.size.y.float) or myPos.y >= SCREEN_Y):
                enemy.state = FINISHED

        of DYING:
            if(enemy.eCountup > 3 * 60):
                enemy.state = DEAD
                enemy.eCountup = 0
                return
            enemy.eCountup.inc

        else:
            discard

# TODO : Check if works correctly
proc updateEnemy2(enemy: Enemy, infos: var GameInfos) =
    let myPos = enemy.position - infos.loadedRoom.camera.position
    case enemy.state:
        of SLEEPING:
            
            if(myPos.x >= (0 - enemy.hitbox.size.x.float) and myPos.x <= SCREEN_X):
                # echo "Go in !!"
                enemy.state = GO_IN
        
        of GO_IN:
            if(enemy.eCountup > 40):
                enemy.state = SHOOTING
                enemy.eCountup = 0
                return
            enemy.position.x -= 2.0
            enemy.eCountup.inc

        of SHOOTING:
            # echo "Shoot!!"
            if(enemy.eCountup > 10):
                enemy.state = GO_OUT
                enemy.eCountup = 0
                return
            
            if((enemy.eCountup and 1) == 0):
                for p in infos.loadedRoom.playerList:
                    if p == nil: continue
                    if p.state != PLAYER_ALIVE: continue
                    let ePos = enemy.position - infos.loadedRoom.camera.position
                    let distX = p.position.x - ePos.x
                    let distY = p.position.y - ePos.y
                    let angle = arctan2(distY, distX).radToDeg()
                    let b = Bullet(
                            playerId: -1, 
                            bulletType: 0, 
                            vector: VectorF64(x: angle, y: 2.5),
                            position: VectorF64(
                                x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                                y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                            ),
                            bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                    )
                
                    infos.loadedRoom.bulletList.add(b)
            enemy.eCountup.inc

        of GO_OUT:
            enemy.position.x -= 2
            enemy.position.y -= 2
            if(myPos.x < (0 - enemy.hitbox.size.x.float) or myPos.x > SCREEN_X or 
                myPos.y < (0 - enemy.hitbox.size.y.float) or myPos.y >= SCREEN_Y):
                enemy.state = FINISHED

        of DYING:
            if(enemy.eCountup > 3 * 60):
                enemy.state = DEAD
                enemy.eCountup = 0
                return
            enemy.eCountup.inc

        else:
            discard

method update*(enemy: Enemy, infos: var GameInfos): void =
    # echo "updating enemy!"
    # let myPos = enemy.position - infos.loadedRoom.camera.position
    # if(myPos.x < (0 - enemy.hitbox.size.x.float) or myPos.x > SCREEN_X or 
    #     myPos.y < 0 - enemy.hitbox.size.y.float or myPos.y >= SCREEN_Y):
    #     enemy.state = SLEEPING

    case enemy.enemyType:
    of 0:
        enemy.updateEnemy0(infos)
    of 1:
        enemy.updateEnemy1(infos)
    of 2:
        enemy.updateEnemy2(infos)

    else:
        discard
    
    if(enemy.state notin {GO_IN, SHOOTING, GO_OUT}): return
    for p in infos.loadedRoom.playerList:
        if(p == nil): continue
        if(p.state != PLAYER_ALIVE): continue
        let relPos = enemy.position - infos.loadedRoom.camera.position
        if(
            (relPos.x + enemy.hitbox.size.x.float >= p.position.x) and
            (relPos.x <= p.position.x + p.hitbox.size.x.float) and
            (relPos.y + enemy.hitbox.size.y.float >= p.position.y) and
            (relPos.y <= p.position.y + p.hitbox.size.y.float)
            ):
                p.die()

    return

proc updateBoss666(enemy: Enemy, infos:var GameInfos) =
    let myPos = enemy.position - infos.loadedRoom.camera.position
    case enemy.state:
        of SLEEPING:
            
            if(myPos.x >= (0 - enemy.hitbox.size.x.float) and myPos.x <= SCREEN_X):
                # echo "Go in !!"
                enemy.state = GO_IN
        
        of GO_IN:
            if(enemy.eCountup > 40):
                enemy.state = SHOOTING
                enemy.eCountup = 0
                return
            # enemy.position.x -= 2.0
            enemy.eCountup.inc

        of SHOOTING:
            # echo "Shoot!!"
            # if(enemy.eCountup > 10):
            #     enemy.state = GO_OUT
            #     enemy.eCountup = 0
            #     return
            
            if(enemy.lifePoints > 75):
                let b = Bullet(
                        playerId: -1, 
                        bulletType: 0, 
                        vector: VectorF64(x: 36 * (10 - enemy.eCountup).float64, y: 2.5),
                        position: VectorF64(
                            x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                            y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                        ),
                        bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                    )
                
                infos.loadedRoom.bulletList.add(b)
            
            if(enemy.lifePoints <= 75 and enemy.lifePoints > 50):
                if((enemy.eCountup and 15) == 0):
                    for i in 0..10:
                        let b = Bullet(
                            playerId: -1, 
                            bulletType: 0, 
                            vector: VectorF64(x: 36 * (10 - i).float64, y: 2.5),
                            position: VectorF64(
                                x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                                y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                            ),
                            bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                        )
                        infos.loadedRoom.bulletList.add(b)

            if(enemy.lifePoints <= 50 and enemy.lifePoints > 25):
                if((enemy.eCountup and 15) == 0):
                    for p in infos.loadedRoom.playerList:
                        if p == nil: continue
                        if p.state != PLAYER_ALIVE: continue
                        let ePos = enemy.position - infos.loadedRoom.camera.position
                        let distX = p.position.x - ePos.x
                        let distY = p.position.y - ePos.y
                        let angle = arctan2(distY, distX).radToDeg()
                        let b = Bullet(
                                playerId: -1, 
                                bulletType: 0, 
                                vector: VectorF64(x: angle, y: 2.5),
                                position: VectorF64(
                                    x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                                    y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                                ),
                                bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                        )
                    
                        infos.loadedRoom.bulletList.add(b)

            if(enemy.lifePoints <= 25):
                let b = Bullet(
                        playerId: -1, 
                        bulletType: 0, 
                        vector: VectorF64(x: 36 * (10 - enemy.eCountup).float64, y: 2.5),
                        position: VectorF64(
                            x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                            y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                        ),
                        bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                    )
                
                infos.loadedRoom.bulletList.add(b)
            enemy.eCountup.inc

        of GO_OUT:
            enemy.position.x -= 2
            enemy.position.y -= 2
            if(myPos.x < (0 - enemy.hitbox.size.x.float) or myPos.x > SCREEN_X or 
                myPos.y < (0 - enemy.hitbox.size.y.float) or myPos.y >= SCREEN_Y):
                enemy.state = FINISHED

        of DYING:
            if(enemy.eCountup > 3 * 60):
                enemy.state = DEAD
                enemy.eCountup = 0
                return
            enemy.eCountup.inc

        else:
            discard

proc updateBoss667(enemy: Enemy, infos:var GameInfos) =
    let myPos = enemy.position - infos.loadedRoom.camera.position
    case enemy.state:
        of SLEEPING:
            
            if(myPos.x >= (0 - enemy.hitbox.size.x.float) and myPos.x <= SCREEN_X):
                # echo "Go in !!"
                enemy.state = GO_IN
        
        of GO_IN:
            if(enemy.eCountup > 40):
                enemy.state = SHOOTING
                enemy.eCountup = 0
                return
            # enemy.position.x -= 2.0
            enemy.eCountup.inc

        of SHOOTING:
            # echo "Shoot!!"
            # if(enemy.eCountup > 10):
            #     enemy.state = GO_OUT
            #     enemy.eCountup = 0
            #     return
            
            if(enemy.lifePoints > 75):
                if((enemy.eCountup and 15) == 0):
                    for p in infos.loadedRoom.playerList:
                        if p == nil: continue
                        if p.state != PLAYER_ALIVE: continue
                        let ePos = enemy.position - infos.loadedRoom.camera.position
                        let distX = p.position.x - ePos.x
                        let distY = p.position.y - ePos.y
                        let angle = arctan2(distY, distX).radToDeg()
                        let b = Bullet(
                                playerId: -1, 
                                bulletType: 0, 
                                vector: VectorF64(x: angle, y: 2.5),
                                position: VectorF64(
                                    x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                                    y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                                ),
                                bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                        )
                    
                        infos.loadedRoom.bulletList.add(b)
            
            if(enemy.lifePoints <= 75 and enemy.lifePoints > 50):
                if((enemy.eCountup and 15) == 0):
                    for i in 0..10:
                        let b = Bullet(
                            playerId: -1, 
                            bulletType: 0, 
                            vector: VectorF64(x: 36 * (10 - i).float64, y: 2.5),
                            position: VectorF64(
                                x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                                y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                            ),
                            bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                        )
                        infos.loadedRoom.bulletList.add(b)

            if(enemy.lifePoints <= 50 and enemy.lifePoints > 25):
                let b = Bullet(
                        playerId: -1, 
                        bulletType: 0, 
                        vector: VectorF64(x: 36 * (10 - enemy.eCountup).float64, y: 2.5),
                        position: VectorF64(
                            x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                            y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                        ),
                        bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                    )
                
                infos.loadedRoom.bulletList.add(b)


                

            if(enemy.lifePoints <= 25):
                let b = Bullet(
                        playerId: -1, 
                        bulletType: 0, 
                        vector: VectorF64(x: 36 * (10 - enemy.eCountup).float64, y: 2.5),
                        position: VectorF64(
                            x: (enemy.position.x - infos.loadedRoom.camera.position.x) + enemy.hitbox.size.x.float64 / 2,
                            y: (enemy.position.y - infos.loadedRoom.camera.position.y) + enemy.hitbox.size.y.float64 / 2
                        ),
                        bulletId: infos.loadedRoom.bulletList.getFreeIndex().uint16, 
                    )
                
                infos.loadedRoom.bulletList.add(b)
            enemy.eCountup.inc

        of GO_OUT:
            enemy.position.x -= 2
            enemy.position.y -= 2
            if(myPos.x < (0 - enemy.hitbox.size.x.float) or myPos.x > SCREEN_X or 
                myPos.y < (0 - enemy.hitbox.size.y.float) or myPos.y >= SCREEN_Y):
                enemy.state = FINISHED

        of DYING:
            if(enemy.eCountup > 3 * 60):
                enemy.state = DEAD
                enemy.eCountup = 0
                return
            enemy.eCountup.inc

        else:
            discard

proc updateBoss*(enemy: Enemy, infos: var GameInfos, level: int) =
    case enemy.enemyType:
        of 666: enemy.updateBoss666(infos)
        of 667: enemy.updateBoss667(infos)
        else: discard

    if(enemy.state == DEAD):
        if(level < MAX_LEVELS - 1): infos.state = GameState.LEVEL_FINISHED
        else: infos.state = GameState.GAME_FINISHED
        return
    
    if(enemy.state notin {GO_IN, SHOOTING, GO_OUT}): return
    for p in infos.loadedRoom.playerList:
        if(p == nil): continue
        if(p.state != PLAYER_ALIVE): continue
        let relPos = enemy.position - infos.loadedRoom.camera.position
        if(
            (relPos.x + enemy.hitbox.size.x.float >= p.position.x) and
            (relPos.x <= p.position.x + p.hitbox.size.x.float) and
            (relPos.y + enemy.hitbox.size.y.float >= p.position.y) and
            (relPos.y <= p.position.y + p.hitbox.size.y.float)
            ):
                p.die()

    

    return