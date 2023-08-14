import std/[times, os, tables, httpclient, asyncdispatch, strformat]
import imgui, imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]

var
    loginName = newString(16)
    loginPass = newString(32)
    loginErrorName = " "
    loginErrorPass = " "

    registerName = newString(16)
    registerPass = newString(32)
    registerErrorName = " "
    registerErrorPass = " "

proc checkNameAvaillability(client: AsyncHttpClient, name: string): Future[string] {.async.} =
  var a = await client.getContent(fmt"http://127.0.0.1/availlableName/{name}")
#   var a = await client.getContent(fmt"http://127.0.0.1/")
#   var a = await client.request(fmt"http://127.0.0.1/", HttpGet)
  return a

proc validateName(name: string): string =
  if(name.len < 3 or name.len > 16):
    return "Name must be between 3 and 16 characters long!"
  return ""

proc validatePassword(password: string): string =
  if(password.len < 6):
    return "Password must be at least 6 characters long!"
  return ""

proc drawRegisterTab(client: AsyncHttpClient) {.inline, async.} =
    var registerNameStrC = registerName.cstring
    var registerPassStrC = registerPass.cstring

    # We add 1 to the length because the \0 is ommited, but we need to take it into account when
    # operating with C strings.
    if(igInputText("Name##R", registerNameStrC, registerName.len.uint32 + 1)):
        registerName = $registerNameStrC
        loginErrorName = validateName(registerName)
        var f = client.checkNameAvaillability(registerName)
        registerName.setLen(16)
        f.callback = (
            proc () =
                echo waitFor f
        )
        # echo "AAAAAAAAAAAAAAAAaa"

    if(igInputText("Password##R", registerPassStrC, registerPass.len.uint32 + 1)):
        registerPass = $registerPassStrC
        loginErrorPass = validatePassword(registerPass)
        registerPass.setLen(32)

    # Checks if the errors lengths are not zero.
    let hasErrorsRegister = (registerErrorName.len != 0 or registerErrorPass.len != 0)
    
    # Display the errors.
    igText(loginErrorName.cstring)
    igText(loginErrorPass.cstring)

    # This is used to disable the button if there are errors.
    if(hasErrorsRegister):
        var style = igGetStyle()
        igPushItemFlag(ImGuiItemFlags.Disabled, hasErrorsRegister)
        igPushStyleVar(ImGuiStyleVar.Alpha, style.alpha * 0.5)
    if(igButton("register")):
        echo "Hello world!"
    if(hasErrorsRegister):
        igPopItemFlag()
        igPopStyleVar()

    igSameLine()

    if(igButton("Exit##R")):
        quit()

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

    # This is used to disable the button if there are errors.
    if(hasErrorsLogin):
        var style = igGetStyle()
        igPushItemFlag(ImGuiItemFlags.Disabled, hasErrorsLogin)
        igPushStyleVar(ImGuiStyleVar.Alpha, style.alpha * 0.5)
    if(igButton("Login")):
        echo "Hello world!"
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

proc openLoginWindow*(client: AsyncHttpClient) {.async.} = 
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

    while not window.windowShouldClose:
        var a = window.drawWindow(client)
        # Waits for completion of all events and processes them. Raises ValueError if there are no pending operations.
        # In contrast to poll this processes as many events as are available until the timeout has elapsed.
        drain(16)
        

    igOpenGL3Shutdown()
    igGlfwShutdown()
    context.igDestroyContext()

    window.destroyWindow()
    glfwTerminate()
    return