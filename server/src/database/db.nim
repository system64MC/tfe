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

proc seedDb*(): void =
    removeFile(DBNAME)
    initConnectionPool(DBNAME, 20)
    
    # Creating data
    var users = @[
        newUser("Flandre", $sha_256.digest("Flandre")),
        newUser("Remilia", $sha_256.digest("Remilia")),
        newUser("System64", $sha_256.digest("System64")),
        newUser("Kurumi", $sha_256.digest("Kurumi")),
        newUser("KurumiA", $sha_256.digest("Kurumi")),
    ]
    var games = @[
        newGame(users[0], "abcd")
    ]
    var players = @[
        newPlayer(users[0], games[0]),
        newPlayer(users[2], games[0])
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
        CREATE UNIQUE INDEX unique_code ON GameORM(code);
        """))

        # Seeding data into the Database.
        con.insert(users)
        con.insert(games)
        con.insert(players)