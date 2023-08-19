import asyncdispatch, jester, os, strutils
import std/threadpool
import database/db
import database/orm/models
import std/options
import std/encodings
import std/json
import regex

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

    post "/register":
        var myJson = parseJson(request.body)
        let name = $(myJson["name"].getStr().cstring)
        let pass = $(myJson["password"].getStr().cstring)
        if not validatePassword(pass): resp Http400
        if not validateName(name): resp Http409
        if(addUserToDb(name, pass)): resp Http200
        resp Http500

proc bootApi*(): void =
    let port = 80.Port
    let settings = newSettings(port=port)
    var jester = initJester(apiRouter, settings=settings)
    jester.serve()