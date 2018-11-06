# Package

version     = "0.1.0"
author      = "Leonardo Mariscal"
description = "Graphics engine made with NimGL"
license     = "MIT"
srcDir      = "src"
skipDirs    = @["examples"]

let exs     = @[
  "examples/rotating_cube"
]

# Dependencies

requires "nim >= 0.18.0"
requires "nimgl >= 0.2.1"
requires "glm >= 1.1.1"
requires "msgpack4nim >= 0.2.7"

# Tasks

task run, "run the examples":
  for ex in exs:
    exec("nim c -r " & ex & ".nim")
