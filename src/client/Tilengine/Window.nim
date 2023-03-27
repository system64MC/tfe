import Types
import TilengineBinding
import Engine

# WINDOWING
proc createWindow*(overlay: string, flags: set[WindowFlags] = {SIZE3, VSYNC}, thread: bool = false): bool =
    var a = 0
    for i in flags:
        a = a or i.int
    if(thread):
        return TLN_CreateWindowThread(overlay.cstring, a.cint)
    return TLN_CreateWindow(overlay.cstring, a.cint)

proc setWindowTitle*(title: string): void =
    TLN_SetWindowTitle(title.cstring)

proc processWindow*(): bool =
    timeStart = Engine.getTicks().float
    delta = (timeStart - timeFinish).float
    return TLN_ProcessWindow()

proc isWindowActive*(): bool =
    return TLN_IsWindowActive()

proc getInput*(id: TLN_Input): bool =
    return TLN_GetInput(id)

proc enableInput*(player: TLN_Player, enable: bool): void =
    TLN_EnableInput(player, enable)

proc assignInputJoystick*(player: TLN_Player, index: int): void =
    TLN_AssignInputJoystick(player, index.cint)

proc defineInputKey*(player: TLN_Player, input: TLN_Input, keycode: uint): void =
    TLN_DefineInputKey(player, input, keycode.cuint)

proc defineInputButton*(player: TLN_Player, input: TLN_Input, joybutton: uint8): void =
    TLN_DefineInputButton(player, input, joybutton)

proc drawFrame*(frame: int): void =
    TLN_DrawFrame(frame.cint)
    timeFinish = Engine.getTicks().float
    delta = timeFinish - timeStart
    if(delta < DELAY):
        Engine.delay((DELAY - delta).uint32)

proc waitRedraw*(): void =
    TLN_WaitRedraw()

proc deleteWindow*(): void =
    TLN_DeleteWindow()

proc enableBlur*(mode: bool): void =
    TLN_EnableBlur(mode)

proc enableCRTEffect*(overlay: cint, factor: uint8, threshold: uint8, v0: uint8, v1: uint8, v2: uint8, v3: uint8, blur: bool, glowFactor: uint8): void =
    TLN_EnableCRTEffect(overlay.cint, factor, threshold, v0, v1, v2, v3, blur, glowFactor)

proc configCRTEffect*(crtType: Crt = Crt.Aperture, blur: bool = true): void =
    TLN_ConfigCRTEffect(crtType.Tlncrt, blur)

proc disableCRTEffect*(): void =
    TLN_DisableCRTEffect()

proc setSDLCallback*(self: TLN_SDLCallback): void =
    TLN_SetSDLCallback(self)

proc delay*(msecs: uint): void =
    TLN_Delay(msecs.cuint)

proc getTicks*(): uint = 
    return TLN_GetTicks().uint

proc getWindowW*(): int =
    return TLN_GetWindowWidth().int

proc getWindowH*(): int =
    return TLN_GetWindowHeight().int