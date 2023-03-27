import actor

type
    Enemy* = ref object of Actor
        enemyType*: int
        lifePoints*: int

method update(enemy: Enemy): void =
    return