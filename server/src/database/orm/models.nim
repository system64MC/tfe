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

    GameORMState* = enum
        NONE,
        HAS_STARTED,
        HAS_FINISHED,
        GAME_OVER

    GameORM* = ref object of Model
        # Game code
        gameCode*: string
        # List of players of the game. 4 players max per game.
        # players*: seq[PlayerORM]
        # Creator of the game instance
        # The current level
        level*: int
        # Game State?
        state*: GameORMState
        # When the game is created?
        creationDate*: DateTime
        creator*: UserORM
        totalScore*: int

    PlayerORM* = ref object of Model
        # The user that controls this player
        user*: UserORM
        # Number of lifes left
        lifes*: uint8 = 5
        # Player's score
        score*: int = 0
        # Powerup
        powerup*: uint8 = 0
        # Bombs
        bombs*: uint8 = 3
        # The character that player controls.
        character*: int8
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

proc getUserByNameAndPassword*(name: string, password: string): Option[UserORM] {.gcsafe.} =
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
    var game = GameORM(creator: creator, gameCode: code, creationDate: now())
    return game

func newPlayer*(user: UserORM, game: GameORM): PlayerORM = 
    return PlayerORM(
    user: user,
    game: game,
    character: -1
    )

proc getGameByCode*(code: string): Option[GameORM] {.gcsafe.} =
    var game = GameORM(newGame(newUser("", ""), ""))
    echo code
    try:
        withDbConn(con):
            echo "test db"
            echo game == nil
            con.select(game, "GameORM.gameCode = ?", code)
        return some(game)
    except:
        return none(GameORM)

proc save*(game: var seq[GameORM]) =
    try:
        withDbConn(con):
            con.update(game)
    except:
        echo "error"

proc save*(player: var PlayerORM) =
    try:
        withDbConn(con):
            con.update(player)
    except:
        discard

proc save*(players: var seq[PlayerORM]) =
    try:
        withDbConn(con):
            con.update(players)
    except:
        discard

proc getPlayersByGame*(game: GameORM): Option[seq[PlayerORM]] =
    var players = @[newPlayer(newUser("", ""), game)]
    try:
        withDbConn(con):
            con.select(players, "PlayerORM.game = ?", game)
        return some(players)
    except:
        return none(seq[PlayerORM])
