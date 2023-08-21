import hitbox
import vectors
import message
import constants

type
    Powerup* = enum
        SIMPLE
        DOUBLE
        TRIPLE

    Actor* = ref object of RootObj
        position*: VectorF64
        hitbox*: Hitbox
        velX*: float64
        velY*: float64

    Ennemy* = ref object of Actor
        ennemyType*: int
        lifePoints*: int

    Bullet* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        bulletId*: uint16
        vector*: VectorF64

    Camera* = ref object
        position*: VectorF64
        velocity*: VectorF64