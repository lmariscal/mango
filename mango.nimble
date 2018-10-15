# Package

version     = "0.1.0"
author      = "Leonardo Mariscal"
description = "Graphics engine made with NimGL"
license     = "MIT"
srcDir      = "src"

# Dependencies

requires "nim >= 0.18.0"
requires "nimgl >= 0.2.1"
requires "glm >= 1.1.1"
requires "fab >= 0.4.3"

# Tasks

task test, "test the engine":
  exec("nim c -r app/app.nim")
