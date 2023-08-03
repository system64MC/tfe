import ../utils/hitbox
import ../../common/vectors

type
    Actor* = ref object of RootObj
        position*: VectorF64
        hitbox*: Hitbox
        velX*: float64
        velY*: float64
        # timers*: array[8, uint16]
    
    ActorType* = enum
        ENNEMY

method update*(actor: Actor): void {.base.} = 
    return

method serialize*(actor: Actor): string {.base.} =
    return ""

method checkCollisions(actor: Actor): void {.base.} =
    return