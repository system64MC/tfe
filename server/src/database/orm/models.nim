import norm/[model, sqlite, pool]
import ../conn
import std/options
import std/times
import nimcrypto
    
type
    UserORM* = ref object of Model
        pseudo*: string
        # Some security is always good.
        password*: string

    GameORM* = ref object of Model
        # List of players of the game. 4 players max per game.
        # players*: seq[PlayerORM]
        # Creator of the game instance
        creator*: UserORM
        # The current level
        level*: int
        # Is the game finished?
        isFinished*: bool
        # Did the game started?
        hasStarted*: bool
        # Game code
        code*: string
        # When the game is created?
        creationDate*: DateTime


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
    return UserORM(pseudo: pseudo, password: password)

proc getUserByPseudo*(pseudo: string): Option[UserORM] {.gcsafe.} =
    var user = UserORM()
    echo pseudo
    try:
        withDbConn(con):
            con.select(user, "UserORM.pseudo = ?", pseudo)
        return some(user)
    except:
        return none(UserORM)

proc getUserByNameAndPassword*(name: string, password: string): Option[UserORM] =
    var user = UserORM()
    echo password
    try:
        withDbConn(con):
            con.select(user, "UserORM.pseudo = ? AND UserORM.password = ?", name, $sha_256.digest(password))
        return some(user)
    except:
        return none(UserORM)

proc addUserToDb*(name: string, password: string): bool =
    try:
        var user = newUser(name, $(sha_256.digest(password)))
        withDbConn(con):
            con.insert(user)
        return true
    except:
        return false
        
proc newGame*(creator: UserORM, code: string): GameORM =
    var game = GameORM(creator: creator, code: code, creationDate: now())
    return game

func newPlayer*(user: UserORM, game: GameORM): PlayerORM = 
    return PlayerORM(
    user: user,
    game: game,
    character: -1
    )