import gameInstance
import api
import std/threadpool

var timeStart* = 0.0
var timeFinish* = 0.0
var delta* = 0.0

const FPS* = 60.0
const DELAY* = (1000.0 / FPS.float)




# proc serializePos(vec: VectorI16): string = return toFlatty(vec)

proc main2(): void =
  # spawn bootGameInstance()
  # bootApi()
  var th: Thread[void]
  var webServer: Thread[void]
  createThread(th, bootGameInstance)
  createThread(webServer, bootApi)
  while true:
    continue
  

main2()