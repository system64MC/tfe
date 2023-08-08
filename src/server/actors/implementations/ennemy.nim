import ../actors
import../../gameInfos

type
    Ennemy* = ref object of Actor
        ennemyType*: int
        lifePoints*: int

method update(enemy: Ennemy, infos: GameInfos): void =
    return