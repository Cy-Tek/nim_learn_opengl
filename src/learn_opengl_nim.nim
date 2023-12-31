import sdl2
import opengl
import shader

var
  screenWidth: cint = 640
  screenHeight: cint = 480
  window: WindowPtr = nil
  context: GlContextPtr = nil
  evt = sdl2.defaultEvent
  runGame = true

const
  vertices: array[18, GLfloat] = [
    # positions     # colors
    0.5, -0.5, 0.0, 1.0, 0.0, 0.0,  # Top right
    -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, # Bottom right
    0.0, 0.5, 0.0, 0.0, 0.0, 1.0    # Bottom left
  ]

  indices: array[3, GLuint] = [
    0, 1, 2
  ]

proc reshape(newWidth: cint, newHeight: cint) =
  screenWidth = newWidth
  screenHeight = newHeight
  glViewport(0, 0, screenWidth, screenHeight) # Set the viewport to cover the new window

proc initSDL() =
  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow("Learn OpenGL",
      SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
      screenWidth, screenHeight,
      SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)

  if isNil window:
    raiseAssert("Failed to initialize SDL2 window")

  context = window.glCreateContext()

  # Initialize OpenGL
  loadExtensions()
  reshape(screenWidth, screenHeight)

proc processInput() =
  while pollEvent(evt):
    case evt.kind
    of QuitEvent:
      runGame = false
      break

    of KeyUp:
      if evt.key.keysym.scancode == SDL_SCANCODE_L:
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
      if evt.key.keysym.scancode == SDL_SCANCODE_P:
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

    of WindowEvent:
      if evt.window.event == WindowEvent_Resized:
        let newWidth = evt.window.data1
        let newHeight = evt.window.data2
        reshape(newWidth, newHeight)

    else: discard

when isMainModule:
  initSDL()

  let shaderProgram = initShader(r".\shaders\triangle.vert", r".\shaders\triangle.frag")
  var vbo, ebo, vao: cuint

  glGenBuffers(1, vbo.addr)
  glGenBuffers(1, ebo.addr)

  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)

  # Copy our vertices array in a buffer for OpenGL to use
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * vertices.len, vertices.addr, GL_STATIC_DRAW)

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * indices.len,
      indices.addr, GL_STATIC_DRAW)

  # Then set our vertex attributes pointers
  glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), nil)
  glEnableVertexAttribArray(0)

  # Color attribute
  glVertexAttribPointer(1, 3, cGL_FLOAT, GL_FALSE,
    6 * sizeof(GLfloat), cast[pointer](3 * sizeof(GLfloat)))
  glEnableVertexAttribArray(1)

  shaderProgram.use()

  while runGame:
    processInput()

    # Begin rendering
    glClearColor(0.2, 0.3, 0.3, 1.0)
    glClear(GL_COLOR_BUFFER_BIT) # Clear color buffer

    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES, 0, 3)

    glBindVertexArray(0)
    # End rendering

    window.glSwapWindow() # Swap the front and back frame buffers (double buffering)

  glDeleteContext(context)
  destroy window
