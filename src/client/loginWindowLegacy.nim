# This file is not important... Only keeping it as archive...

import wNim/[wApp, wMacros, wFrame, wPanel, wEvent, wPrintData, wIcon,
  wStaticBox, wButton, wRadioButton, wMessageDialog, wDirDialog, wFileDialog,
  wColorDialog, wFontDialog, wTextEntryDialog, wPasswordEntryDialog,
  wFindReplaceDialog, wPageSetupDialog, wPrintDialog, wTextCtrl, wStaticText, wNoteBook]

proc checkNameAvaillability(client: AsyncHttpClient, name: string): Future[string] {.async.} =
  return await client.getContent(fmt"http://127.0.0.1/availlableName/{name}")

proc validateName(name: string): string =
  if(name.len < 3 or name.len > 16):
    return "Name must be between 3 and 16 characters long!"
  return ""

proc validatePassword(password: string): string =
  if(password.len < 6):
    return "Password must be at least 6 characters long!"
  return ""

proc startAuthWindow(client: AsyncHttpClient): Future[void] {.async.} =
  let app = App()
  let frame = Frame(title="Welcome to my game!", size=(400, 300), style = wModalFrame)

  frame.center()
  let panel = Panel(frame)
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
      loginNameText: centerX = loginPage.centerX; top = loginPage.top + 8
      loginNameField: centerX = loginPage.centerX; top = loginNameText.bottom + 1
      loginPasswordText: centerX = loginPage.centerX; top = loginNameField.bottom + 8
      loginPassField: centerX = loginPage.centerX; top = loginPasswordText.bottom + 1

      loginNameError: centerX = loginPage.centerX; top = loginPassField.bottom + 8
      loginPassError: centerX = loginPage.centerX; top = loginNameError.bottom + 1
      loginButton: centerX = loginPage.centerX / 1.5; top = loginPassField.bottom + 44
      loginExitButton: centerX = loginPage.centerX + loginPage.centerX * 0.25; top = loginPassField.bottom + 44


  proc setRegisterLayout(): void =
  
    registerPage.layout:
      registerNameText: centerX = registerPage.centerX; top = registerPage.top + 8
      registerNameField: centerX = registerPage.centerX; top = registerNameText.bottom + 1
      registerPasswordText: centerX = registerPage.centerX; top = registerNameField.bottom + 8
      registerPassField: centerX = registerPage.centerX; top = registerPasswordText.bottom + 1

      registerNameError: centerX = registerPage.centerX; top = registerPassField.bottom + 8
      registerPassError: centerX = registerPage.centerX; top = registerNameError.bottom + 1
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

  registerNameField.wEvent_Text do ():
    registerNameError.label = validateName(registerNameField.getValue())
    # var result = await client.checkNameAvaillability(registerNameField.getValue())
    # echo "Async task result:", result
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
  return