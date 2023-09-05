import tilengine/tilengine
import math
import game/game
import common/constants
import drawing

proc lerp(x, x0, x1, fx0, fx1: float): float =
    return (fx0) + ((fx1) - (fx0))*((x) - (x0))/((x1) - (x0))

proc titleScreenRasterEffect*(line: int32) {.cdecl.} =
    var x = 0
    setBgColor((255 - line.uint8) shr 3, line.uint8 shr 1, (255 - line.uint8) shr 1)
    if(line < 40):
        Layer(2).disable
        x = int(sin((TAU * line.float + (frame.float))/16) * 3)
    if(line >= 33):
        Layer(2).enable
        const centerY = SCREEN_Y div 2
        Layer(2).setPosition(512 - (SCREEN_X shr 1), 512 - centerY)
        let sx = lerp(line.float, 29.897, 81.959, 0.200, 0.515)
        Layer(2).setTransform(frame.float / 2, SCREEN_X / 2, SCREEN_Y / 2, sx, sx)
    Layer(1).setPosition(x, 0)
    
proc selectScreenRasterEffect*(line: int32) {.cdecl.} =
    var x = 0
    if(line < 16):
        x = frame shl 1
    Layer(1).setPosition(x, 0)

proc displayHud*(line: int32) =
    if(line < 8):
        Layer(0).enable
    else:
        Layer(0).disable

proc levelRasterEffect*(line: int32) {.cdecl.} =
    displayHud(line)