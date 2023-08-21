import common/hitbox
import common/vectors
import common/message
import common/constants
import common/commonActors

type
    # Powerup* = enum
    #     SIMPLE
    #     DOUBLE
    #     TRIPLE

    # Actor* = ref object of RootObj
    #     position*: VectorF64
    #     hitbox*: Hitbox
    #     velX*: float64
    #     velY*: float64
    #     # timers*: array[8, uint16]

    Player* = ref object of Actor
        character*: uint8
        lifes*: uint8
        input*: uint8
        # currentRoom*: Room
        timers*: array[8, uint16]
        deltaTimeHowManyValues*: int = 0
        deltaTimeAccumulator*: float64 = 0
        deltaTime*: float64 = 0
        # Which bonus the player has
        powerUp*: Powerup
        # How many bombs the player has
        bombs*: byte

    # Ennemy* = ref object of Actor
    #     ennemyType*: int
    #     lifePoints*: int

    # Bullet* = ref object of Actor
    #     bulletType*: int
    #     isPlayer*: bool
    #     bulletId*: uint16
    #     vector*: VectorF64
    #     # currentRoom*: Room

    