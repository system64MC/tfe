import std/[times, os, tables, httpclient, asyncdispatch, strformat, strutils, asyncfutures]
import imgui, imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import regex
import ../common/credentials
import libsodium/sodium

var
    loginName = newString(16)
    loginPass = newString(32)
    loginErrorName = " "
    loginErrorPass = " "

    registerName = newString(16)
    registerPass = newString(32)
    registerErrorName = " "
    # Added this because if I try to access registerErrorName directly from the callback, I have a segfault.
    # So I use this hack to avoid any kind of segfault
    registerNameAvaillable = true
    registerErrorPass = " "
    registerProblem = false
    loginProblem = false
    loginError = false
    key = ""
    isLogged = false

proc checkNameAvaillability(client: AsyncHttpClient, name: string): Future[AsyncResponse] {.async.} =
  var a = await client.get(fmt"http://127.0.0.1/availlableName/{name.cstring}")
  echo fmt"name: {name}"
  return a

proc validateName(name: string): string =
  if(name.len < 3 or name.len > 16):
    return "Name must be between 3 and 16 characters long!"
  var m: RegexMatch2
  if(not match(name, re2"^[a-zA-Z0-9]+$", m)):
    return "Only alphanumeric characters are allowed!"
  
  return ""

proc validatePassword(password: string): string =
  if(password.len < 6):
    return "Password must be at least 6 characters long!"
  return ""

import std/json
proc register(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    var json = %* {"name": $(registerName.cstring), "password": $(registerPass.cstring)}
    echo $json
    var a = await client.post("http://127.0.0.1/register", $json)
    return a

proc login(client: AsyncHttpClient): Future[AsyncResponse] {.async.} =
    var json = %* {"name": $(loginName.cstring), "password": $(loginPass.cstring)}
    echo $json
    var a = await client.post("http://127.0.0.1/login", $json)
    return a

proc drawRegisterTab(client: AsyncHttpClient) {.inline, async.} =
    var registerNameStrC = registerName.cstring
    var registerPassStrC = registerPass.cstring

    # We add 1 to the length because the \0 is ommited, but we need to take it into account when
    # operating with C strings.
    if(igInputText("Name##R", registerNameStrC, registerName.len.uint32 + 1)):
        registerName = $registerNameStrC
        registerErrorName = validateName(registerName)
        registerName.setLen(16)

        if(registerErrorName == ""):
            var f = client.checkNameAvaillability(registerName)
            asyncfutures.addCallback(f,
                proc (f: Future[AsyncResponse]) {.closure, gcsafe.} =
                    try:
                        var res = f.read()
                        {.cast(gcsafe).}:
                            if(res.status.startsWith("409")):
                                echo "error"
                                registerNameAvaillable = false
                            else:
                                registerNameAvaillable = true
                    except:
                        discard
            )

    if(igInputText("Password##R", registerPassStrC, registerPass.len.uint32 + 1, flags = ImGuiInputTextFlags.Password)):
        registerPass = $registerPassStrC
        registerErrorPass = validatePassword(registerPass)
        registerPass.setLen(32)

    # Checks if the errors lengths are not zero.
    let hasErrorsRegister = (registerErrorName.len != 0 or registerErrorPass.len != 0 or not registerNameAvaillable)
    
    # Display the errors.
    igText(if (registerNameAvaillable or registerErrorName != ""): registerErrorName.cstring else: "Name not availlable.")
    igText(registerErrorPass.cstring)
    igText(if(not registerProblem): "".cstring else: "A problem occured during registration. Please try again".cstring)

    # This is used to disable the button if there are errors.
    if(hasErrorsRegister):
        var style = igGetStyle()
        igPushItemFlag(ImGuiItemFlags.Disabled, hasErrorsRegister)
        igPushStyleVar(ImGuiStyleVar.Alpha, style.alpha * 0.5)
    if(igButton("register")):
        let r = client.register()
        asyncfutures.addCallback(r,
                proc (r: Future[AsyncResponse]) {.closure, gcsafe.} =
                    try:
                        var res = r.read()
                        echo res.status
                        {.cast(gcsafe).}:
                            if(res.status.startsWith("200")):
                                igSetTabItemClosed("Register")
                                registerProblem = false
                            else:
                                registerProblem = true
                    except:
                        registerProblem = true
            )
    if(hasErrorsRegister):
        igPopItemFlag()
        igPopStyleVar()

    igSameLine()

    if(igButton("Exit##R")):
        quit()

proc getLoginError(): string =
    if(loginProblem): return "An error occured. Please try again."
    if(loginError): return "Invalid name or password."
    return ""

proc drawLoginTab(client: AsyncHttpClient) {.inline, async.} =
    var loginNameStrC = loginName.cstring
    var loginPassStrC = loginPass.cstring

    # We add 1 to the length because the \0 is ommited, but we need to take it into account when
    # operating with C strings.
    if(igInputText("Name##L", loginNameStrC, loginName.len.uint32 + 1)):
        loginName = $loginNameStrC
        loginErrorName = validateName(loginName)
        loginName.setLen(16)

    if(igInputText("Password##L", loginPassStrC, loginPass.len.uint32 + 1)):
        loginPass = $loginPassStrC
        loginErrorPass = validatePassword(loginPass)
        loginPass.setLen(32)

    # Checks if the errors lengths are not zero.
    let hasErrorsLogin = (loginErrorName.len != 0 or loginErrorPass.len != 0)
    
    # Display the errors.
    igText(loginErrorName.cstring)
    igText(loginErrorPass.cstring)
    igText(getLoginError().cstring)

    # This is used to disable the button if there are errors.
    if(hasErrorsLogin):
        var style = igGetStyle()
        igPushItemFlag(ImGuiItemFlags.Disabled, hasErrorsLogin)
        igPushStyleVar(ImGuiStyleVar.Alpha, style.alpha * 0.5)
    if(igButton("Login")):
        let l = client.login()
        asyncfutures.addCallback(l,
                proc (l: Future[AsyncResponse]) {.closure, gcsafe.} =
                    try:
                        var res = l.read()
                        if(res.status.startsWith("401")):
                            loginError = true
                        elif(res.status.startsWith("500")):
                            loginError = false
                            loginProblem = true
                            return
                        elif(res.status.startsWith("200")):
                            loginError = false
                            {.cast(gcsafe).}:
                                key = parseJson(res.body.read())["key"].getStr()
                                echo key
                            isLogged = true
                        # {.cast(gcsafe).}:
                        #     if(res.status.startsWith("200")):
                        #         igSetTabItemClosed("Register")
                        #         registerProblem = false
                        #     else:
                        #         registerProblem = true
                        loginProblem = false
                    except:
                        loginProblem = true
            )
    if(hasErrorsLogin):
        igPopItemFlag()
        igPopStyleVar()

    igSameLine()

    if(igButton("Exit##L")):
        quit()
    

proc drawApp(client: AsyncHttpClient) {.inline, async.} =
    if(igBegin("Auth Window", nil, (ImGuiWindowFlags.NoDecoration.int32 or ImGuiWindowFlags.NoMove.int32 or ImGuiWindowFlags.NoResize.int32).ImGuiWindowFlags)):
        igSetWindowPos(ImVec2(x: 0, y: 0))
        igSetWindowSize(ImVec2(x: 400, y: 300))
        igBeginTabBar("tab")
        if(igBeginTabItem("Login")):
            await drawLoginTab(client)
            igEndTabItem()
        if(igBeginTabItem("Register")):
            await drawRegisterTab(client)
            igEndTabItem()
        igEndTabBar()
        igEnd()

        
        

proc drawWindow(window: GLFWWindow, client: AsyncHttpClient) {.inline, async.} =
    glfwPollEvents()


    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    await drawApp(client)
    
    igRender()

    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    window.swapBuffers()
    glfwSwapInterval(1)

proc openLoginWindow*(client: AsyncHttpClient): Future[CredentialsEncrypted] {.async.} = 
    doAssert glfwInit()

    glfwWindowHint(GLFWContextVersionMajor, 3)
    glfwWindowHint(GLFWContextVersionMinor, 3)
    glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
    glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFWResizable, GLFWTrue)
    var window = glfwCreateWindow(400, 300, ("Welcome to my game!").cstring)
    if window == nil:
        quit(-1)

    window.makeContextCurrent()
    window.setWindowSizeLimits(400, 300, 400, 300)

    doAssert glInit()

    let context = igCreateContext()
    var io = igGetIO()
    io.configFlags = (io.configFlags.int or ImGuiConfigFlags.NavEnableKeyboard.int).ImGuiConfigFlags
    #let io = igGetIO()

    doAssert igGlfwInitForOpenGL(window, true)
    doAssert igOpenGL3Init()

    echo "hi"
    # context.

    while not isLogged:
        var a = window.drawWindow(client)
        drain(16)
        # Waits for completion of all events and processes them. Raises ValueError if there are no pending operations.
        # In contrast to poll this processes as many events as are available until the timeout has elapsed.
        

    igOpenGL3Shutdown()
    igGlfwShutdown()
    context.igDestroyContext()

    window.destroyWindow()
    glfwTerminate()
    # We already encrypt the password so we don't need to do it during game loop.
    return CredentialsEncrypted(name: loginName, password: crypto_box_seal(loginPass, key))
    