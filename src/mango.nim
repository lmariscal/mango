# Written by Leonardo Mariscal <leo@cav.bz>, 2018

when not isMainModule:
  import mango/[
    ioman,
    logger,
    material,
    mesh,
    shader,
    texture,
    utils,
    window
  ]

  export
    ioman,
    logger,
    material,
    mesh,
    shader,
    texture,
    utils,
    window
else:
  import mango/editor

  startEditor()
