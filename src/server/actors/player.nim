import actor

type
    Player* = ref object of Actor
        character*: int
        lifes*: int

method update(player: Player): void =
    return