import asyncdispatch, jester, os, strutils
import std/threadpool
import database/db
import database/orm/models
import std/options
import std/encodings
import std/json
import regex
import crypto
import common/serializedObjects

# We also validate on server side. NEVER TRUST THE CLIENT!!
proc validateName(name: string): bool =
    if(name.len < 3 or name.len > 16): return false
    var m: RegexMatch2
    if(not match(name, re2"^[a-zA-Z0-9]+$", m)): return false
    if(getUserByPseudo(name).isSome): return false
    return true

proc validatePassword(password: string): bool =
    if(password.len < 6 and password.len > 32): return false
    return true

proc serializeGames(games: seq[GameORM]): seq[GameScoreSerialize] =
    var topGamesSerialized = newSeq[GameScoreSerialize](0)
    for g in games:
        topGamesSerialized.add(GameScoreSerialize(creator: g.creator.pseudo, score: g.totalScore.int32))
    return topGamesSerialized

router apiRouter:
    get "/availlableName/@name":
        echo @"name"
        if(getUserByPseudo($((@"name").cstring)).isSome):
            echo "not availlable"
            resp Http409
        else: resp Http200
        # echo "API called"
        # resp @"name"

    get "/":
        sleep(3000)
        resp "This is a simple test..."

    get "/top":
        var games = getTopTenGames().get().serializeGames()
        let json = %* games
        resp(Http200, $json, "application/json")

    post "/register":
        var myJson = parseJson(request.body)
        let name = $(myJson["name"].getStr().cstring)
        let pass = $(myJson["password"].getStr().cstring)
        if not validatePassword(pass): resp Http400
        if not validateName(name): resp Http409
        if(addUserToDb(name, pass)): resp Http200
        resp Http500

    post "/login":
        var myJson = parseJson(request.body)
        let name = $(myJson["name"].getStr().cstring)
        let pass = $(myJson["password"].getStr().cstring)
        let user = getUserByNameAndPassword(name, pass)
        if user.isNone:
            resp Http401
        else:
            let json = %* {"key": getPublicKey()}
            resp(Http200, $json, "application/json")
        resp(Http500)


proc bootApi*(): void {.thread.} =
    {.cast(gcsafe).}:
        # let port = 80.Port
        let settings = newSettings(bindAddr="0.0.0.0")
        var jester = initJester(apiRouter, settings=settings)
        jester.serve()