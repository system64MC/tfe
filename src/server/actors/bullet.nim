import actor
import ../../common/vectors
import math

type
    Bullet* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        vector*: VectorF64

method update*(bullet: Bullet): void = 
    # Getting X component
    let xSpeed = bullet.vector.y * cos(bullet.vector.x)
    
    # Getting Y component
    let ySpeed = bullet.vector.y * sin(bullet.vector.x)

    bullet.position.x += xSpeed
    bullet.position.y += ySpeed
    return