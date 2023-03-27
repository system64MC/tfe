import actor
import ../utils/vector

type
    Bullet* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        vector*: Vector

method update*(bullet: Bullet): void = 
    return