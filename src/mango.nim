# Written by Leonardo Mariscal <leo@cav.bz>, 2018

when not isMainModule:
  import mango/core/[
    ioman,
    logger,
    utils,
    window
  ], mango/graphics/[
    material,
    mesh,
    shader,
    texture
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
