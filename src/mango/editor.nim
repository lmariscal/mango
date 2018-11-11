# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import ioman, loger, material, mesh, shader, texture, utils, window

when defined(release):
  logMinLevel = llCrash
else:
  logMinLevel = llMango

proc startEditor*() =
  mlog("starting editor")
