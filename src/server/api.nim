import asyncdispatch, jester, os, strutils
import std/threadpool

router apiRouter:
    get "/availlableName/@name":
        echo "API called"
        resp @"name"

    get "/":
        sleep(3000)
        resp "This is a simple test..."

proc bootApi*(): void =
    let port = 80.Port
    let settings = newSettings(port=port)
    var jester = initJester(apiRouter, settings=settings)
    jester.serve()