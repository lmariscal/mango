# Package

version     = "0.1.0"
author      = "Leonardo Mariscal"
description = "Graphics engine made with NimGL"
license     = "MIT"
srcDir      = "src"
skipDirs    = @["examples"]

# Dependencies

requires "nim >= 0.18.0"
requires "nimgl >= 0.2.1"
requires "glm >= 1.1.1"
requires "msgpack4nim >= 0.2.7"

# Tasks

task rotating_cube, "run the rotating cube example":
  exec("nim c -r examples/rotating_cube.nim")

task rectangle, "run the rectangle example":
  exec("nim c -r examples/rectangle.nim")

task run, "run the editor":
  exec("nim c -r src/mango.nim")
