# import Tilengine/tilengine
import tilengine/tilengine
import netty
import flatty
import flatty/hexprint

import ../common/vectors
import ../common/message
import ../common/events
import ../common/constants
import actors/player
import actors/bullet
import room/background
import camera
import tilengine/bitmapUtils
import std/monotimes
import std/[times, os, tables]

proc serializeInputs(): string =
  var input = (
    getInput(InputButton3).uint8 shl 6 or
    getInput(InputButton2).uint8 shl 5 or
    getInput(InputButton1).uint8 shl 4 or

    getInput(Inputup).uint8 shl 3 or
    getInput(Inputdown).uint8 shl 2 or
    getInput(Inputleft).uint8 shl 1 or
    getInput(Inputright).uint8)
  return toFlatty(EventInput(input: input, sentAt: getTime().toUnixFloat()))



proc `$`(vec: VectorI16): string = return ("x: " & $vec.x & " y: " & $vec.y)

proc unserializePos(data: string): VectorI16 = return fromFlatty(data, VectorI16)

var bulletList*: array[512, Bullet]

var cam = Camera(position: VectorF64(x: 0, y: 0))

# proc getTile*(pos: VectorF64, currentRoom: Room): Tile =
#     return currentRoom.collisions.getTile(pos.y.int shr 4, pos.x.int shr 4)

# TODO : This part needs to be optimized. Is it possible to use animations instead?
# Maybe I should contact Tilengine's developer to know if there is an easy way to take
# advantage of animations.
proc switchTiles(map: Tilemap, switchOn: bool) =
  for j in 0..<map.getRows:
    for i in 0..<map.getCols:
      var tile = map.getTile(j, i)
      if(tile.index > 1 and tile.index < 8):
        if(switchOn):
          if tile.index == 3: tile.index = 2
          if tile.index == 5: tile.index = 4
          if tile.index == 6: tile.index = 7
          map.setTile(j, i, tile)
          continue
        if tile.index == 2: tile.index = 3
        if tile.index == 4: tile.index = 5
        if tile.index == 7: tile.index = 6
        map.setTile(j, i, tile)

var switchState = true
var needSwitching = false

import wNim/[wApp, wMacros, wFrame, wPanel, wEvent, wPrintData, wIcon,
  wStaticBox, wButton, wRadioButton, wMessageDialog, wDirDialog, wFileDialog,
  wColorDialog, wFontDialog, wTextEntryDialog, wPasswordEntryDialog,
  wFindReplaceDialog, wPageSetupDialog, wPrintDialog, wTextCtrl, wStaticText, wNoteBook]

# proc startApp() =
#     # First create a window. Window is the root of view hierarchy.
#     var wnd = newWindow(newRect(40, 40, 800, 600))

#     # Create a static text field and add it to view hierarchy
#     let label = newLabel(newRect(20, 20, 150, 20))
#     let button = newButton(newRect(20, 20, 150, 40))
#     button.name = "Connect"
#     button.title = "Connect"
#     # button.
#     # button.text = "connect"
#     label.text = "Hello, world!"
#     wnd.addSubview(label)
#     wnd.addSubview(button)

proc validateName(name: string): string =
  if(name.len < 3 or name.len > 16):
    return "Name must be between 3 and 16 characters long!"
  return ""

proc validatePassword(password: string): string =
  if(password.len < 6):
    return "Password must be at least 6 characters long!"
  return ""

proc startAuthWindow(): void =
  let app = App()
  let frame = Frame(title="Welcome to my game!", size=(400, 300), style = wModalFrame)

  frame.center()
  let panel = Panel(frame)
  # let mainBox = StaticBox(panel, label="Login")
  let loginOrRegisterNotebook = Notebook(panel)
  loginOrRegisterNotebook.addPage("Login")
  loginOrRegisterNotebook.addPage("Register")
  let loginPage = loginOrRegisterNotebook.getPage(0)
  let loginNameText = StaticText(loginPage, label = "Name")
  let loginNameField = TextCtrl(loginPage,)
  let loginPasswordText = StaticText(loginPage, label = "Password")
  let loginPassField = TextCtrl(loginPage, style = wTePassword)
  let loginNameError = StaticText(loginPage, label = " ")
  let loginPassError = StaticText(loginPage, label = " ", pos = (200, 200))
  let loginButton = Button(loginPage, label = "Login")
  let loginExitButton = Button(loginPage, label = "Exit")
  loginButton.enable(false)

  let registerPage = loginOrRegisterNotebook.getPage(1)
  let registerNameText = StaticText(registerPage, label = "Name")
  let registerNameField = TextCtrl(registerPage,)
  let registerPasswordText = StaticText(registerPage, label = "Password")
  let registerPassField = TextCtrl(registerPage, style = wTePassword)
  let registerNameError = StaticText(registerPage, label = " ")
  let registerPassError = StaticText(registerPage, label = " ", pos = (200, 200))
  let registerButton = Button(registerPage, label = "register")
  let registerExitButton = Button(registerPage, label = "Exit")
  registerButton.enable(false)

  panel.autolayout """
    spacing: 10
    H:|-[loginOrRegisterNotebook]-|
    V:|-[loginOrRegisterNotebook]-|
    V:|-[loginOrRegisterNotebook]-|
  """

  proc setLoginLayout(): void =
    
    loginPage.layout:
      # loginOrRegisterNotebook: centerX = panel.centerX; top = panel.top + 8
      loginNameText: centerX = loginPage.centerX; top = loginPage.top + 8
      # nameText: centerX = loginPage.centerX; top = loginOrRegisterNotebook.bottom + 8
      loginNameField: centerX = loginPage.centerX; top = loginNameText.bottom + 1
      loginPasswordText: centerX = loginPage.centerX; top = loginNameField.bottom + 8
      loginPassField: centerX = loginPage.centerX; top = loginPasswordText.bottom + 1

      loginNameError: centerX = loginPage.centerX; top = loginPassField.bottom + 8
      loginPassError: centerX = loginPage.centerX; top = loginNameError.bottom + 1
      # loginButton: centerX = panel.centerX; top = passError.bottom + 4
      loginButton: centerX = loginPage.centerX / 1.5; top = loginPassField.bottom + 44
      loginExitButton: centerX = loginPage.centerX + loginPage.centerX * 0.25; top = loginPassField.bottom + 44


  proc setRegisterLayout(): void =
  
    registerPage.layout:
      # registerOrRegisterNotebook: centerX = panel.centerX; top = panel.top + 8
      registerNameText: centerX = registerPage.centerX; top = registerPage.top + 8
      # nameText: centerX = registerPage.centerX; top = registerOrRegisterNotebook.bottom + 8
      registerNameField: centerX = registerPage.centerX; top = registerNameText.bottom + 1
      registerPasswordText: centerX = registerPage.centerX; top = registerNameField.bottom + 8
      registerPassField: centerX = registerPage.centerX; top = registerPasswordText.bottom + 1

      registerNameError: centerX = registerPage.centerX; top = registerPassField.bottom + 8
      registerPassError: centerX = registerPage.centerX; top = registerNameError.bottom + 1
      # registerButton: centerX = panel.centerX; top = passError.bottom + 4
      registerButton: centerX = registerPage.centerX / 1.5; top = registerPassField.bottom + 44
      registerExitButton: centerX = registerPage.centerX + registerPage.centerX * 0.25; top = registerPassField.bottom + 44
    
  proc shouldDisableLoginButton(): void =
    if(loginNameError.label != "" or loginPassError.label != ""):
      loginButton.enable(false)
    else:
      loginButton.enable(true)
  
  proc shouldDisableregisterButton(): void =
    if(registerNameError.label != "" or registerPassError.label != ""):
      registerButton.enable(false)
    else:
      registerButton.enable(true)

  setLoginLayout()
  setRegisterLayout()

  # Events for login page...
  loginButton.wEvent_Button do ():
    echo "Todo : Implement login on server"
  loginExitButton.wEvent_Button do ():
    quit()
  loginNameField.wEvent_Text do():
    loginNameError.label = validateName(loginNameField.getValue())
    loginNameError.size = loginNameError.getBestSize()
    setLoginLayout()
    shouldDisableLoginButton()
  loginPassField.wEvent_Text do():
    loginPassError.label = validatePassword(loginPassField.getValue())
    loginPassError.size = loginPassError.getBestSize()
    setLoginLayout()
    shouldDisableLoginButton()

  # Events for register page...
  registerButton.wEvent_Button do ():
    echo "Todo : implement register to server"
    loginOrRegisterNotebook.setSelection(0)
  registerExitButton.wEvent_Button do ():
    quit()
  registerNameField.wEvent_Text do():
    registerNameError.label = validateName(registerNameField.getValue())
    registerNameError.size = registerNameError.getBestSize()
    setRegisterLayout()
    shouldDisableregisterButton()
  registerPassField.wEvent_Text do():
    registerPassError.label = validatePassword(registerPassField.getValue())
    registerPassError.size = registerPassError.getBestSize()
    setRegisterLayout()
    shouldDisableregisterButton()

  frame.show()
  app.mainLoop()

proc main() =
  startAuthWindow()
  cam = Camera()
  var e = init(SCREEN_X, SCREEN_Y, 3, 128, 64)
  initBitmapLayer()
  discard ("e")

  var client = newReactor()
  var connection = client.connect("127.0.0.1", 5173)
  
  var player = player.Player()

  var playerSprite = loadSpriteset("./assets/sprites/player.png")
  let sprPlayer = Sprite(player.character)
  sprPlayer.setSpriteSet(playerSprite)

  let foreground = Layer(0)

  var map = loadTilemap("assets/tilemaps/testRoom.tmx", "background")
  foreground.setTilemap(map)

  setTargetFps(120)
  var sp = map.getTileset.getSequencePack()
  
  createWindow(flags = {cwfNoVsync})
  
  while processWindow():
    client.tick()
    var input = serializeInputs()
    client.send(connection, toFlatty(message.Message(header: EVENT_INPUT, data: input)))

    for msg in client.messages:
      let myMsg = fromFlatty(msg.data, message.Message)
      # if(msg.)
      case myMsg.header:
      of MessageHeader.PLAYER_DATA:
        player = unserialize(myMsg.data)
      of MessageHeader.BULLET_LIST:
        bulletList = fromFlatty(myMsg.data, array[512, Bullet])
      of MessageHeader.BULLET_NULL:
        let i = fromFlatty(myMsg.data, uint16)
        bulletList[i] = nil
      of MessageHeader.CAMERA_DATA:
        cam = fromFlatty(myMsg.data, Camera)
      of MessageHeader.EVENT_DESTROY_TILE:
        let e = fromFlatty(myMsg.data, EventTileChange)
        var tile = map.getTile(e.coordinates.y, e.coordinates.x)
        tile.index = e.tileType
        map.setTile(e.coordinates.y, e.coordinates.x, tile)
      of MessageHeader.EVENT_SWITCH:
        needSwitching = true
        let e = fromFlatty(myMsg.data, events.EventSwitch)
        switchState = e.state
      of MessageHeader.DESTROYABLE_TILES_DATA:
        echo "Received data!"
        let list = fromFlatty(myMsg.data, Table[VectorI64, bool])
        for coordinates, isHere in list:
          if(not isHere):
            var tile = map.getTile(coordinates.y, coordinates.x)
            tile.index = 1
            map.setTile(coordinates.y, coordinates.x, tile)
        # for i in 0..<1:
        #   # echo ()
        #   if(myArr[i] == $((1).char)): continue
        #   echo hexPrint(myArr[i])
        #   bulletList[i] = fromFlatty(myArr[i], bullet.Bullet)
      else:
        continue
    
    map.switchTiles(switchState)
        # continue
    # bulletList = fromFlatty(client.messages[0].data, array[512, Bullet])
    # player = unserialize(client.messages[1].data)
    Background.bitmap.clearBitmap()
    foreground.setPosition(cam.position.x.int, cam.position.y.int)
    player.draw()
    for b in bulletList:
      if(b == nil): continue
      b.draw()
    drawFrame(0)
    # sleep(100)
  client.disconnect(connection)
main()