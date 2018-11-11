# Written by Leonardo Mariscal <leo@cav.bz>, 2018

when not isMainModule:
  import mango/[
    ioman,
    loger,
    material,
    mesh,
    shader,
    texture,
    utils,
    window
  ]

  export
    ioman,
    loger,
    material,
    mesh,
    shader,
    texture,
    utils,
    window
else:
  import mango/editor

  startEditor()
