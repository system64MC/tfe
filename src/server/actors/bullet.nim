import actor
import ../../common/vectors

type
    Bullet* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        vector*: VectorF64

method update*(bullet: Bullet): void = 
    return