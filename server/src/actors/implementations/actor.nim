import ../../utils/hitbox
import common/vectors
import ../../gameInfos
import ../actors
# from actors import Actor

type
    # Actor* = ref object of RootObj
    #     position*: VectorF64
    #     hitbox*: Hitbox
    #     velX*: float64
    #     velY*: float64
    #     # timers*: array[8, uint16]
    
    ActorType* = enum
        ENNEMY

# method update*(actor: Actor, infos: var GameInfos): void {.base.} = 
#     return



# method checkCollisions(actor: Actor): void {.base.} =
#     return