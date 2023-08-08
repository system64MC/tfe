import gameInstance
import std/threadpool

var timeStart* = 0.0
var timeFinish* = 0.0
var delta* = 0.0

const FPS* = 60.0
const DELAY* = (1000.0 / FPS.float)




# proc serializePos(vec: VectorI16): string = return toFlatty(vec)

proc main2(): void =
  # spawn bootGameInstance()

  var th: Thread[void]
  createThread(th, bootGameInstance)
  while true:
    continue
  

main2()