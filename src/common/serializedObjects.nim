import vectors
import hitbox
import commonActors

type
    PlayerSerialize* = ref object of Actor
        character*: uint8
        lifes*: uint8

    RoomSerialize* = ref object
        camera*: Camera
        switchOn*: bool
        playerList*: array[4, PlayerSerialize]
        bulletList*: array[512, Bullet]