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
    # connPool.add open(DBNAME,"","","myDb")
    withDbConn(con):
        con.createTables(UserORM())
    # var a: seq[byte]
    # var hashMac: HMAC[sha_256]
    # var pass = hashMac.pbkdf2("myPassword", "mySalt", 32, a)
    var users = @[
        newUser("Flandre", $sha_256.digest("Flandre")),
        newUser("Remilia", $sha_256.digest("Remilia")),
        newUser("System64", $sha_256.digest("System64")),
        newUser("Kurumi", $sha_256.digest("Kurumi")),
    ]

    withDbConn(con):
        con.insert(users)