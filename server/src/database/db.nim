import norm/[model, sqlite, pool]
import orm/models
import os
import conn
import nimcrypto
import nimcrypto/pbkdf2

var DBNAME = getCurrentDir() & "/game.db"

proc insertPlayers*(players: var array[4, PlayerORM], game: var GameORM) = 
    echo "saving to DB"
    echo game == nil
    withDbConn(con):
        con.insert(game)
        for i in 0..<players.len:
            var p = players[i]
            if(p != nil): con.insert(p)
            players[i] = p
    echo "saved"

const SEED = true

proc seedDb*(): void =
    echo getCurrentDir()
    if(SEED): removeFile(DBNAME)
    initConnectionPool(DBNAME, 256)
    if(not SEED): return
    # Creating data
    var users = @[
        newUser("Flandre", $sha_256.digest("Flandre")),
        newUser("Remilia", $sha_256.digest("Remilia")),
        newUser("System64", $sha_256.digest("System64")),
        newUser("Kurumi", $sha_256.digest("Kurumi")),
        newUser("ElisBlood", $sha_256.digest("ElisBlood")),
    ]
    var games = @[
        newGame(users[0], "test"),
        newGame(users[1], "abcdefgh"),
        newGame(users[2], "aaaaaa"),

        
        newGame(users[4], "aeaeae", GAME_OVER   , 100),
        newGame(users[0], "xxxxxx", HAS_FINISHED, 495),
        newGame(users[1], "vvvvvv", HAS_FINISHED, 123),
        newGame(users[3], "azerty", HAS_FINISHED, 891),
        newGame(users[3], "uuuuuu", GAME_OVER   , 20),
        
        newGame(users[2], "azazaz", HAS_FINISHED, 400),
        newGame(users[0], "pppppp", GAME_OVER   , 80),
        newGame(users[2], "iiiiii", HAS_FINISHED, 1000),
        newGame(users[1], "cccccc", HAS_FINISHED, 900),
        newGame(users[4], "eeeeee", HAS_FINISHED, 900),

        newGame(users[4], "wwwwww", GAME_OVER   , 64),
    ]

    var players = @[
        newPlayer(users[0], games[0]),
        newPlayer(users[1], games[0]),

        newPlayer(users[3], games[1]),
        newPlayer(users[4], games[1]),
    ]

    withDbConn(con):
        # Adding constraints is always good and prevents business rules violations by throwing errors.
        con.exec(SqlQuery(
        """
        CREATE TABLE UserORM(
            pseudo TEXT NOT NULL CHECK(length(pseudo) >= 3 and length(pseudo) <= 16),
            password TEXT NOT NULL,
            id INTEGER NOT NULL PRIMARY KEY
        );
        """))

        # Creating tables
        con.createTables(games[0])
        con.createTables(players[0])

        con.exec(SqlQuery(
        """
        CREATE UNIQUE INDEX unique_code ON GameORM(gameCode);
        """))

        con.insert(users)
        con.insert(games)
        con.insert(players)