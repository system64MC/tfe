import norm/[model, sqlite, pool]
import ../conn
import std/options

    
type
    UserORM* = ref object of Model
        pseudo*: string
        # Some security is always good.
        password*: string

    GameORM* = ref object of Model
        # List of players of the game. 4 players max per game.
        players*: array[4, PlayerORM]
        # Creator of the game instance
        creator*: UserORM
        # The current level
        level*: int
        # Is the game finished?
        isFinished*: bool
        # Game code
        code*: string


    PlayerORM* = ref object of Model
        # The user that controls this player
        user*: UserORM
        # Number of lifes left
        lifes*: int
        # Player's score
        score*: int
        # The character that player controls.
        character*: int
        # The game the player is in
        game*: GameORM

proc newUser*(pseudo: string, password: string): UserORM =
    UserORM(pseudo: pseudo, password: password)

proc getUserByPseudo*(pseudo: string): Option[UserORM] {.gcsafe.} =
    var user = UserORM()
    echo pseudo
    try:
        withDbConn(con):
            con.select(user, "UserORM.pseudo = ?", pseudo)
        return some(user)
    except:
        return none(UserORM)
        
func newGame(creator: UserORM, code: string): GameORM =
    GameORM(creator: creator, code: code)

