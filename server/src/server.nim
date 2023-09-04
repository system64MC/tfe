import gameInstance
import api
import std/threadpool
import database/orm/models
import norm/[model, sqlite]
import database/db
import crypto
import instanceManager
import std/os

var timeStart* = 0.0
var timeFinish* = 0.0
var delta* = 0.0

const FPS* = 60.0
const DELAY* = (1000.0 / FPS.float)

proc main2(): void =
  generateKeys()
  seedDb()
  var th: Thread[void]
  var webServer: Thread[void]
  var instanceMan: Thread[void]
  # seedDb()
  # createThread(instanceMan, bootInstanceManager)
  createThread(webServer, bootApi)
  # createThread(th, bootGameInstance)
  bootInstanceManager()
  
when isMainModule:
  main2()