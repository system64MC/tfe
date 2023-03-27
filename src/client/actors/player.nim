import actor

type
    Player* = ref object of Actor
        character*: int
        lifes*: int

method draw(player: Player): void =
    return