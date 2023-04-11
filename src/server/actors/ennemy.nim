import actor

type
    Ennemy* = ref object of Actor
        ennemyType*: int
        lifePoints*: int

method update(enemy: Ennemy): void =
    return