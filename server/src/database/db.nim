import norm/[model, sqlite, pool]
import orm/models
import os
import conn
import nimcrypto
import nimcrypto/pbkdf2

const DBNAME = "game.db"

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
    if(SEED): removeFile(DBNAME)
    initConnectionPool(DBNAME, 10000)
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
        newGame(users[2], "aaaaaa")
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

        # con.exec(SqlQuery(
        # """
        # CREATE TABLE GameORM(
        #     gameCode TEXT NOT NULL,
        #     creator INTEGER NOT NULL,
        #     level INTEGER NOT NULL,
        #     isFinished INTEGER NOT NULL,
        #     hasStarted INTEGER NOT NULL,
        #     creationDate FLOAT NOT NULL,
        #     id INTEGER NOT NULL PRIMARY KEY,
        #     FOREIGN KEY(creator) REFERENCES "UserORM"(id))
        # """))

        # Creating tables
        con.createTables(games[0])
        con.createTables(players[0])

        # con.exec(SqlQuery(
        # """
        # CREATE UNIQUE INDEX unique_code ON GameORM(code);
        # """))

        # Seeding data into the Database.
        con.insert(users)
        con.insert(games)
        con.insert(players)
    # var game = newGame(users[0], "test")
    # var gamePlayers: array[4, PlayerORM] = [
    #     newPlayer(users[0], game),
    #     newPlayer(users[1], game),
    #     newPlayer(users[2], game),
    #     nil]
    # insertPlayers(gamePlayers, game)