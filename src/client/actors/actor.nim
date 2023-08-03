import ../utils/hitbox
import ../../common/vectors
import tilengine/tilengine

type
    Actor* = ref object of RootObj
        position*: VectorF64
        hitbox*: Hitbox
        velX*: float64
        velY*: float64
        # timers*: array[8, uint16]

method draw*(actor: Actor): void {.base.} = 
    return

proc unserialize*(data: string): Actor =
    return nil