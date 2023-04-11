import ../utils/hitbox
import ../../common/vectors

type
    Actor* = ref object of RootObj
        position*: VectorI16
        hitbox*: Hitbox
    
    ActorType* = enum
        ENNEMY

method update*(actor: Actor): void {.base.} = 
    return

method serialize*(actor: Actor): string {.base.} =
    return ""

method checkCollisions(actor: Actor): void {.base.} =
    return