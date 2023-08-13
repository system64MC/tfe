import player
import user

type
    GameORM = object
        # List of players of the game. 4 players max per game.
        players: array[4, PlayerORM]
        # Creator of the game instance
        creator: UserORM
        # The current level
        level: int
        # Is the game finished?
        isFinished: bool