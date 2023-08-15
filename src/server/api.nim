import asyncdispatch, jester, os, strutils
import std/threadpool
import database/db
import database/orm/models
import std/options
import std/encodings

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
        resp "0"

proc bootApi*(): void =
    let port = 80.Port
    let settings = newSettings(port=port)
    var jester = initJester(apiRouter, settings=settings)
    jester.serve()