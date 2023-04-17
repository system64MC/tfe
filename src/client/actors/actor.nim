import ../utils/hitbox
import ../../common/vectors
import tilengine/tilengine

type
    Actor* = ref object of RootObj
        position*: VectorI16
        hitbox*: Hitbox
        velX*: int16
        velY*:int16

method draw*(actor: Actor): void {.base.} = 
    return

proc unserialize*(data: string): Actor =
    return nil