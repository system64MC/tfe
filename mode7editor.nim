const PAL64_VER = 2 and 0x7F

import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]#, nimgl/imnodes
import nimgl/[opengl, glfw]
import tilengine/tilengine
import streams
import std/[math, os]
import strutils
import tinydialogs
import parseutils


var tilemap: Tilemap = nil
var bitmap: Bitmap = nil


proc loadTmx(path : string) =
    if(tilemap != nil):
      tilemap.delete
    tilemap = loadTilemap(path, nil)
    # echo path
    # bg = loadTilemap(path, "layer")
    try:
      Layer(0).setTilemap(tilemap)
    except:
      discard messageBox("Error", "Error while loading Tilemap!!", DialogType.Ok, IconType.Error, Button.Yes)

    # echo tilemap.getTilemapTileset.setTilesetPalette(palettes[selectedPal])

proc loadImg(path : string) = 
    if(bitmap != nil):
      bitmap.delete()
    bitmap = loadBitmap(path)
    # discard image.deleteBitmap
    # image : Tlntilemap
    # image = img
    # discard getLayerBitmap(0).deleteBitmap
    try:
      Layer(0).setBitmap(bitmap)
    except:
      discard messageBox("Error", "Error while loading Image!!", DialogType.Ok, IconType.Error, Button.Yes)
  
proc loadAsset(path: string) =
  var f = splitFile(path)
  var p = splitPath(path)
  setLoadPath(p.head)
  if(f.ext == ".tmx"):
    loadTmx(p.tail)
  if(f.ext == ".png" or f.ext == ".bmp"):
    loadImg(p.tail)

var layerPosX: int32 = 0
var layerPosY: int32 = 0

var centerX: int32 = 0
var centerY: int32 = 0

var interpMin: float32 = 0
var interpMax: float32 = 0

var interp2min: float32 = 0
var interp2max: float32 = 0

var dx: float32 = 0
var dy: float32 = 0

var sx: float32 = 0
var sy: float32 = 0

var lineLimit: int32 = 0

var angle: float32 = 0.0

var autorotation = false


proc lerp(x, x0, x1, fx0, fx1: float): float =
    return (fx0) + ((fx1) - (fx0))*((x) - (x0))/((x1) - (x0))
proc titleScreenRasterEffect*(line: int32) {.cdecl.} =
    if(Layer(0).getTilemap == nil and Layer(0).getBitmap == nil): return
    Layer(0).disable()
    if(line >= lineLimit):
      Layer(0).enable()
      # Layer(2).setPosition(512 - (SCREEN_X shr 1), 512 - (SCREEN_Y shr 1))
      Layer(0).setPosition(layerPosX, layerPosY)
      let sx2 = lerp(line.float, interpMin, interpMax, interp2min, interp2max)
      # let sy = lerp(line.float, 50, SCREEN_X * 2, 0.2, 5.0)
      Layer(0).setTransform(angle, dx, dy, sx2, sx2)
      # Layer(2).setTransform(frame.float / 2, 0, 0, sx / 2, sx)



proc main() =
  var e = init(256, 144, 1, 0, 0)

  disableCrtEffect()


  setRasterCallback(titleScreenRasterEffect)
  # var nodeContext = imnodesCreateContext()

  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
  var w: GLFWWindow = glfwCreateWindow(1280, 720)
  if w == nil:
    quit(-1)

  

  var mult: cint = 1

  w.makeContextCurrent()

  doAssert glInit()

  let context = igCreateContext()
  #let io = igGetIO()

  doAssert igGlfwInitForOpenGL(w, true)
  doAssert igOpenGL3Init()

  # var e = initEngine()
  # configCrtEffect()
  # var tilemap = loadTilemap("assets/tilemaps/level1.tmx", "layer")
  try:
    Layer(0).setTilemap(tilemap)
    Layer(0).setPosition(0, 32)
  except:
    discard

  var tex: array[(384 * 216 * 4), byte]

  setRenderTarget(cast[ptr UncheckedArray[uint8]](tex[0].addr), 4 * 384)
  
  updateFrame(0)
  var myTextureId: Gluint
  echo(myTextureId)
  glGenTextures(1, myTextureId.addr)
  glBindTexture(GL_TEXTURE_2D, myTextureId)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST.ord)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST.ord)
  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_BGRA.ord,
    GLsizei(384),
    GLsizei(216),
    0,
    GL_BGRA,
    GL_UNSIGNED_BYTE,
    tex.addr
  )

  while not w.windowShouldClose:

    
    var style = igGetStyle()

    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    if(igBeginMainMenuBar()):
      if(igBeginMenu("File")):
          if(igBeginMenu("Load")):
            if(igMenuItem("Load asset to Tilengine")):
              var path = openFileDialog("Open TMX / PNG / BMP", getCurrentDir() / "\0", ["*.tmx", "*.png", "*.bmp"], "Tilemap or Image file")
              loadAsset(path)
            igEndMenu()
          igEndMenu()

            
      if(igBeginMenu("Zoom")):
          igSliderInt("Zoom", mult.addr, 1, 4)
          igEndMenu()
    igEndMainMenuBar()

    # Simple window
    
    var pad = style.windowPadding
    style.windowPadding.x = 0
    style.windowPadding.y = 0
    if(igBegin(name = "Tilengine window", flags = (ImGuiWindowFlags.AlwaysAutoResize.int or 
                                                    ImGuiWindowFlags.NoResize.int or 
                                                    ImGuiWindowFlags.NoCollapse.int).ImGuiWindowFlags)):
        var posVec: ImVec2
        igGetCursorScreenPosNonUDT(posVec.addr)

        updateFrame(0)

        glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_BGRA.ord,
        GLsizei(384),
        GLsizei(216),
        0,
        GL_BGRA,
        GL_UNSIGNED_BYTE,
        tex.addr
        )

        var myVec: ImVec2
        
        igGetItemRectMinNonUDT(myVec.addr)

        var sizX = igGetWindowWidth()
        var sizY = igGetWindowHeight()
        
        igImage(
            cast[ImTextureID](myTextureId),
            # ImVec2(x: 384 * (sizX / 384), y: 216 * (sizY / 216)),
            ImVec2(x: 384 * mult.float32, y: 216 * mult.float32),
            Imvec2(x: 0, y: 0), # uv0
            Imvec2(x: 1, y: 1), # uv1
            ImVec4(x: 1, y: 1, z: 1, w: 1), # tint color
            # ImVec4(x: 1, y: 1, z: 1, w: 0.5f) # border color
        )
        igEnd()
        style.windowPadding = pad
# proc igColorButton*(desc_id: cstring, col: ImVec4, flags: ImGuiColorEditFlags = 0.ImGuiColorEditFlags, size: ImVec2 = ImVec2(x: 0, y: 0).ImVec2): bool {.importc: "igColorButton".}

        if(igBegin(name = "Mode 7 controls", flags = (ImGuiWindowFlags.NoCollapse.int or ImGuiWindowFlags.AlwaysAutoResize.int).ImGuiWindowFlags)):
            igSliderInt("l. posX", layerPosX.addr, 0, 1000)
            igSliderInt("l. posY", layerPosY.addr, 0, 1000)
            
            igSliderFloat("interp. Min", interpMin.addr, 0, 100)
            igSliderFloat("interp. Max", interpMax.addr, 0, 100)

            igSliderFloat("interp. Min2", interp2min.addr, 0, 100)
            igSliderFloat("interp. Max2", interp2max.addr, 0, 100)

            igSliderFloat("DX", dx.addr, 0, 100)
            igSliderFloat("DY", dy.addr, 0, 100)

            igSliderFloat("SX", sx.addr, 0, 100)
            igSliderFloat("SY", sy.addr, 0, 100)

            igSliderInt("line limit", lineLimit.addr, 0, 256)
            igCheckbox("Autorotate", autorotation.addr)
            igEnd()
            
    # End simple window

    igRender()
    if(autorotation):
      angle += 0.25
    # sleep(5)

    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    w.swapBuffers()
    glfwSwapInterval(1)

  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  w.destroyWindow()
  glfwTerminate()

main()