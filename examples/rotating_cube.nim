import mango
import glm

type
  Person = object
    name: string
    age: i32
  ShaderType = enum
    stGoraud = "Goraud Shader"
    stPhong = "Phong Shader"
    stNormals = "Normal Shader"

proc main() =
  when defined(release):
    logMinLevel = llCrash
  else:
    logMinLevel = llMango

  log("starting...")
  let win = newWindow(1280, 720, "Rotating Cube", true, true)

  var
    vertices: seq[f32] = @[
     -0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
     -0.5f,  0.5f, -0.5f,
     -0.5f, -0.5f, -0.5f,

     -0.5f, -0.5f,  0.5f,
      0.5f, -0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f,  0.5f,
     -0.5f, -0.5f,  0.5f,

     -0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f, -0.5f,
     -0.5f, -0.5f, -0.5f,
     -0.5f, -0.5f, -0.5f,
     -0.5f, -0.5f,  0.5f,
     -0.5f,  0.5f,  0.5f,

      0.5f,  0.5f,  0.5f,
      0.5f,  0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f, -0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,

     -0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f, -0.5f,  0.5f,
      0.5f, -0.5f,  0.5f,
     -0.5f, -0.5f,  0.5f,
     -0.5f, -0.5f, -0.5f,

     -0.5f,  0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
      0.5f,  0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f,  0.5f,
     -0.5f,  0.5f, -0.5f,
    ]
    uvs: seq[f32] = @[
      0.0f, 0.0f,
      1.0f, 0.0f,
      1.0f, 1.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,

      0.0f, 0.0f,
      1.0f, 0.0f,
      1.0f, 1.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,

      1.0f, 0.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,
      1.0f, 0.0f,

      1.0f, 0.0f,
      1.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 1.0f,
      0.0f, 0.0f,
      1.0f, 0.0f,

      0.0f, 1.0f,
      1.0f, 1.0f,
      1.0f, 0.0f,
      1.0f, 0.0f,
      0.0f, 0.0f,
      0.0f, 1.0f,

      0.0f, 1.0f,
      1.0f, 1.0f,
      1.0f, 0.0f,
      1.0f, 0.0f,
      0.0f, 0.0f,
      0.0f, 1.0f,
    ]
    normals_pos: seq[f32] = @[
      0.0f,  0.0f, -1.0f,
      0.0f,  0.0f, -1.0f,
      0.0f,  0.0f, -1.0f,
      0.0f,  0.0f, -1.0f,
      0.0f,  0.0f, -1.0f,
      0.0f,  0.0f, -1.0f,

      0.0f,  0.0f,  1.0f,
      0.0f,  0.0f,  1.0f,
      0.0f,  0.0f,  1.0f,
      0.0f,  0.0f,  1.0f,
      0.0f,  0.0f,  1.0f,
      0.0f,  0.0f,  1.0f,

     -1.0f,  0.0f,  0.0f,
     -1.0f,  0.0f,  0.0f,
     -1.0f,  0.0f,  0.0f,
     -1.0f,  0.0f,  0.0f,
     -1.0f,  0.0f,  0.0f,
     -1.0f,  0.0f,  0.0f,

      1.0f,  0.0f,  0.0f,
      1.0f,  0.0f,  0.0f,
      1.0f,  0.0f,  0.0f,
      1.0f,  0.0f,  0.0f,
      1.0f,  0.0f,  0.0f,
      1.0f,  0.0f,  0.0f,

      0.0f, -1.0f,  0.0f,
      0.0f, -1.0f,  0.0f,
      0.0f, -1.0f,  0.0f,
      0.0f, -1.0f,  0.0f,
      0.0f, -1.0f,  0.0f,
      0.0f, -1.0f,  0.0f,

      0.0f,  1.0f,  0.0f,
      0.0f,  1.0f,  0.0f,
      0.0f,  1.0f,  0.0f,
      0.0f,  1.0f,  0.0f,
      0.0f,  1.0f,  0.0f,
      0.0f,  1.0f,  0.0f
    ]

    indices: seq[u32] = @[]

  const
    goraudData  = readShader("res/shaders/goraud.glsl")
    phongData   = readShader("res/shaders/phong.glsl")
    normalsData = readShader("res/shaders/normals.glsl")

  var
    goraud  = newShader(goraudData)
    phong   = newShader(phongData)
    normals = newShader(normalsData)
    mesho   = newMesh(vertices, uvs, normals_pos, indices)

    uGModel       = goraud.getLocation("uModel")
    uGView        = goraud.getLocation("uView")
    uGProjection  = goraud.getLocation("uProjection")
    uGLightPos    = goraud.getLocation("uLightPos")
    uGLightColor  = goraud.getLocation("uLightColor")
    uGObjectColor = goraud.getLocation("uObjectColor")

    uPModel       = phong.getLocation("uModel")
    uPView        = phong.getLocation("uView")
    uPProjection  = phong.getLocation("uProjection")
    uPLightPos    = phong.getLocation("uLightPos")
    uPLightColor  = phong.getLocation("uLightColor")
    uPObjectColor = phong.getLocation("uObjectColor")
    uPTex         = phong.getLocation("uTex")
    uPNormal      = phong.getLocation("uNormal")

    uNModel       = normals.getLocation("uModel")
    uNView        = normals.getLocation("uView")
    uNProjection  = normals.getLocation("uProjection")
    uNLightPos    = normals.getLocation("uLightPos")
    uNLightColor  = normals.getLocation("uLightColor")
    uNTex         = normals.getLocation("uTex")
    uNNormal      = normals.getLocation("uNormal")

    projection  = perspective(radians(45.0f), 1920.0f / 1080.0f, 0.1f, 1000.0f)
    lightColor  = vec3(0.98f)
    objectColor = vec3(102.0f / 255.0f, 187.0f / 255.0f, 106.0f / 255.0f)
    shaderType  = stGoraud

  var tex_diffuse = newTexture("examples/res/images/brickwall.jpg")
  var tex_normal = newTexture("examples/res/images/brickwall_normal.jpg")

  normals.setInt(uNTex, 0)
  normals.setInt(uNNormal, 1)
  phong.setInt(uPTex, 0)
  phong.setInt(uPNormal, 1)

  var rot: f32 = 30
  var zaxis: f32 = -5
  var lightPos = vec3(1.2f, 1.0f, 2.0f)

  while win.isOpen():
    # updat
    win.update()

    # draw
    win.clearScreen(vec3(33f).rgb())

    tex_diffuse.use(0)
    tex_normal.use(1)

    var trans = mat4(1.0f).translate(0, 0, zaxis).rotate(rot.radians(), vec3(1f, 1f, 0f))
    var view  = mat4(1.0f)

    if GLFWKey.R.isPressed():
      rot += 1f
      if rot >= 360:
        rot = 0f

    igText("rotation:")
    igSameLine()
    discard igSliderFloat("##rotation", rot.addr, 0.0f, 360.0f)

    igText("zaxis:")
    igSameLine()
    discard igSliderFloat("##zaxis", zaxis.addr, -10.0f, -1.0f)

    igText("shader:")
    igSameLine()
    if igButton("Goraud", ImVec2(x: 0, y: 0)):
      shaderType = stGoraud
    igSameLine()
    if igButton("Phong", ImVec2(x: 0, y: 0)):
      shaderType = stPhong
    igSameLine()
    if igButton("Normal", ImVec2(x: 0, y: 0)):
      shaderType = stNormals

    if shaderType == stGoraud:
      goraud.setMat(uGModel, trans)
      goraud.setMat(uGView, view)
      goraud.setMat(uGProjection, projection)
      goraud.setVec(uGLightPos, lightPos)
      goraud.setVec(uGLightColor, lightColor)
      goraud.setVec(uGObjectColor, objectColor)
    elif shaderType == stPhong:
      phong.setMat(uPModel, trans)
      phong.setMat(uPView, view)
      phong.setMat(uPProjection, projection)
      phong.setVec(uPLightPos, lightPos)
      phong.setVec(uPLightColor, lightColor)
      phong.setVec(uPObjectColor, objectColor)
    elif shaderType == stNormals:
      normals.setMat(uNModel, trans)
      normals.setMat(uNView, view)
      normals.setMat(uNProjection, projection)
      normals.setVec(uNLightPos, lightPos)
      normals.setVec(uNLightColor, lightColor)

    mesho.use()

    win.draw()

  tex_diffuse.clean()
  tex_normal.clean()
  goraud.clean()
  phong.clean()
  normals.clean()
  mesho.clean()
  win.clean()

main()
