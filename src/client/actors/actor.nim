# import ../utils/hitbox
import ../../common/vectors

type
    Actor* = ref object of RootObj
        position*: VectorI16
        # hitbox*: Hitbox

method draw*(actor: Actor): void {.base.} = 
    return

proc unserialize*(data: string): Actor =
    return nil