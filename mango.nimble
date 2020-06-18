version     = "0.1.0"
author      = "Leonardo Mariscal"
description = "Graphics engine made with NimGL"
license     = "MIT"
srcDir      = "src"
skipDirs    = @["examples"]

requires "nim >= 0.18.0"
requires "nimgl"
requires "stb_image"
requires "glm >= 1.1.1"

task rotating_cube, "run the rotating cube example":
  exec("nim c -r examples/rotating_cube.nim")

task rectangle, "run the rectangle example":
  exec("nim c -r examples/rectangle.nim")

task terrain, "run the terrain example":
  exec("nim c -r examples/terrain.nim")

task run, "run the editor":
  exec("nim c -r -o:mango src/mango.nim")
