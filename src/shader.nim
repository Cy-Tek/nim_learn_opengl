import opengl

type Shader = object
  id: GLuint

# Helper methods

proc processCompileStatus(shader: GLuint, status: GLint) =
  if status == 0:
    var logStr = cast[cstring](alloc(512))
    defer: dealloc(logStr)

    glGetShaderInfoLog(shader, 512, nil, logStr)
    echo "Shader wasn't compiled. Reason:\n" & $logStr

proc processLinkStatus(shader: GLuint, status: GLint) =
  if status == 0:
    var infoLog = cast[cstring](alloc(512))
    defer: dealloc(infoLog)

    glGetProgramInfoLog(shader, 512, nil, infoLog)
    echo "Program wasn't linked: Reason\n" & $infoLog

# Initialization methods

proc initShader*(vertexPath, fragmentPath: string): Shader =
  result.id = glCreateProgram()

  var
    vertexShader = glCreateShader(GL_VERTEX_SHADER)
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
    success: GLint

  let
    vertSrc = readFile(vertexPath)
    vertShaderArray = allocCStringArray([vertSrc])
    fragSrc = readFile(fragmentPath)
    fragShaderArray = allocCStringArray([fragSrc])

  defer:
    deallocCStringArray(vertShaderArray)
    glDeleteShader(vertexShader)

    deallocCStringArray(fragShaderArray)
    glDeleteShader(fragmentShader)

  glShaderSource(vertexShader, 1, vertShaderArray, nil)
  glCompileShader(vertexShader)
  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, success.addr)
  processCompileStatus(vertexShader, success)

  glShaderSource(fragmentShader, 1, fragShaderArray, nil)
  glCompileShader(fragmentShader)
  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, success.addr)
  processCompileStatus(fragmentShader, success)

  glAttachShader(result.id, vertexShader)
  glAttachShader(result.id, fragmentShader)
  glLinkProgram(result.id)
  glGetProgramiv(result.id, GL_LINK_STATUS, success.addr)
  processLinkStatus(result.id, success)

# Methods on the shader

proc use*(shader: Shader) = glUseProgram(shader.id)

proc setBool*(shader: Shader, name: cstring, value: bool) =
  glUniform1i(glGetUniformLocation(shader.id, name), value.GLint)

proc setInt*(shader: Shader, name: cstring, value: GLint) =
  glUniform1i(glGetUniformLocation(shader.id, name), value)

proc setFloat*(shader: Shader, name: cstring, value: GLfloat) =
  glUniform1f(glGetUniformLocation(shader.id, name), value)
