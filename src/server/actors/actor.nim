import ../utils/hitbox

type
    Actor* = ref object of RootObj
        x*: int
        y*: int
        hitbox*: Hitbox

method update*(actor: Actor): void {.base.} = 
    return