import user

type
    PlayerORM* = ref object
        # The user that controls this player
        user*: UserORM
        # Number of lifes left
        lifes*: int
        # Player's score
        score*: int
        # The character that player controls.
        character*: int