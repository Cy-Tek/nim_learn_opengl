# Package

version       = "0.1.0"
author        = "Josh Hannaford"
description   = "An attempt to port the excellent Learn OpenGL tutorials to the Nim programming language"
license       = "MIT"
srcDir        = "src"
bin           = @["learn_opengl_nim"]


# Dependencies

requires "nim >= 2.1.1"
requires "sdl2"
requires "opengl"
