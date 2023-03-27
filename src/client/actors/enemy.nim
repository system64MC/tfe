import actor

type
    Enemy* = ref object of Actor
        enemyType*: int
        lifePoints*: int

method draw(enemy: Enemy): void =
    return