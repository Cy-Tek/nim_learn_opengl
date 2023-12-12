# OpenGL example using SDL2

import sdl2
import opengl

var
  screenWidth: cint = 640
  screenHeight: cint = 480
  window: WindowPtr = nil
  context: GlContextPtr = nil
  evt = sdl2.defaultEvent
  runGame = true

const
  vertices: array[18, GLfloat] = [
    # First triangle
    0.5, 0.5, 0.0,
    0.5, -0.5, 0.0,
    -0.5, 0.5, 0.0,

    # Second triangle
    0.5, -0.5, 0.0,
    -0.5, -0.5, 0.0,
    -0.5, 0.5, 0.0
  ]

proc reshape(newWidth: cint, newHeight: cint) =
  screenWidth = newWidth
  screenHeight = newHeight
  glViewport(0, 0, screenWidth, screenHeight) # Set the viewport to cover the new window

proc initSDL() =
  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow("Learn OpenGL", SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED, screenWidth, screenHeight, SDL_WINDOW_OPENGL or
      SDL_WINDOW_RESIZABLE)

  if isNil window:
    raiseAssert("Failed to initialize SDL2 window")

  context = window.glCreateContext()

  # Initialize OpenGL
  loadExtensions()
  reshape(screenWidth, screenHeight)

proc processInput() =
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      runGame = false
      break
    if evt.kind == WindowEvent:
      var windowEvent = cast[WindowEventPtr](addr(evt))
      if windowEvent.event == WindowEvent_Resized:
        let newWidth = windowEvent.data1
        let newHeight = windowEvent.data2
        reshape(newWidth, newHeight)

proc processCompileStatus(shader: GLuint, status: GLint) =
  var
    logSize: GLint
    logLength: GLsizei

  if status == 0:
    echo "Shader wasn't compiled. Reason:"

    # Query the log size
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, logSize.addr)
    var logStr = cast[cstring](alloc(logSize))
    defer: dealloc(logStr)

    glGetShaderInfoLog(shader, logSize, logLength.addr, logStr)
    echo $logStr
  else:
    echo "Shader was compiled successfully"


proc compileShader(vertSrcPath, fragSrcPath: string): cuint =
  var
    vertexShader = glCreateShader(GL_VERTEX_SHADER)
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
    shaderProgram = glCreateProgram()
    isCompiled: GLint

  let
    vertSrc = readFile(vertSrcPath)
    vertShaderArray = allocCStringArray([vertSrc])
    fragSrc = readFile(fragSrcPath)
    fragShaderArray = allocCStringArray([fragSrc])

  defer:
    deallocCStringArray(vertShaderArray)
    glDeleteShader(vertexShader)

    deallocCStringArray(fragShaderArray)
    glDeleteShader(fragmentShader)

  glShaderSource(vertexShader, 1, vertShaderArray, nil)
  glCompileShader(vertexShader)
  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, isCompiled.addr)
  processCompileStatus(vertexShader, isCompiled)

  glShaderSource(fragmentShader, 1, fragShaderArray, nil)
  glCompileShader(fragmentShader)
  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, isCompiled.addr)
  processCompileStatus(fragmentShader, isCompiled)

  glAttachShader(shaderProgram, vertexShader)
  glAttachShader(shaderProgram, fragmentShader)
  glLinkProgram(shaderProgram)

  return shaderProgram

when isMainModule:
  initSDL()

  let shaderProgram = compileShader(r".\shaders\triangle_basic.vert", r".\shaders\triangle_basic.frag")
  var vbo, vao: cuint

  glGenBuffers(1, vbo.addr)

  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)

  # Copy our vertices array in a buffer for OpenGL to use
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * vertices.len, vertices.addr, GL_STATIC_DRAW)

  # Then set our vertex attributes pointers
  glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), nil)
  glEnableVertexAttribArray(0)


  while runGame:
    processInput()

    # Begin rendering
    glClearColor(0.2, 0.3, 0.3, 1.0) # Set background color to black and opaque
    glClear(GL_COLOR_BUFFER_BIT) # Clear color and depth buffers

    glUseProgram(shaderProgram)
    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES, 0, 6)
    # End rendering

    window.glSwapWindow() # Swap the front and back frame buffers (double buffering)

  glDeleteContext(context)
  destroy window