import norm/[model, sqlite, pool]
import orm/models
import os
import conn
import nimcrypto
import nimcrypto/pbkdf2

const DBNAME = "game.db"

proc seedDb*(): void =
    removeFile(DBNAME)
    initConnectionPool(DBNAME, 20)
    
    # Creating data
    var users = @[
        newUser("Flandre", $sha_256.digest("Flandre")),
        newUser("Remilia", $sha_256.digest("Remilia")),
        newUser("System64", $sha_256.digest("System64")),
        newUser("Kurumi", $sha_256.digest("Kurumi")),
    ]
    var games = @[
        newGame(users[0], "abcd")
    ]
    var players = @[
        newPlayer(users[0], games[0]),
        newPlayer(users[2], games[0])
    ]

    withDbConn(con):
        # Creating tables
        con.createTables(users[0])
        con.createTables(games[0])
        con.createTables(players[0])

        # Seeding data into the Database.
        con.insert(users)
        con.insert(games)
        con.insert(players)