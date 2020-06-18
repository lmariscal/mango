import mango
import mango/graphics
import glm
import glm/noise

converter toArray(v: Vec3f): array[3, float32] =
  result[0] = v[0]
  result[1] = v[1]
  result[2] = v[2]

proc main() =
  when defined(release):
    logMinLevel = llCrash
  else:
    logMinLevel = llMango

  log("starting...")
  let win = newWindow(1280, 720, "Terrain", true, true)

  var
    vertices: seq[f32] = @[]
    uvs: seq[f32] = @[]
    normals: seq[f32] = @[]
    indices: seq[u32] = @[]

  const
    shaderData = readShader("res/shaders/terrain.glsl")
    widthT = 100
    depthT = 100

  # Gen Terrain
  for z in 0 ..< depthT:
    for x in 0 ..< widthT:
      let n: f32 = perlin(vec2f(x.f32, z.f32) * 0.1f)
      let y: f32 = floor((n + 1) * 5)
      vertices.add(x.f32 - (depthT / 2))
      vertices.add(y)
      vertices.add(z.f32)

      if x mod 2 == 0:
        uvs.add(0.0f)
      else:
        uvs.add(1.0f)
      if z mod 2 == 0:
        uvs.add(0.0f)
      else:
        uvs.add(1.0f)

      normals.add(x.f32 - (depthT / 2))
      normals.add(y)
      normals.add(z.f32)
      # echo k

  for x in 0 ..< widthT - 1:
    for z in 0 ..< depthT - 1:
      indices.add((x       + z       * widthT).u32)
      indices.add((x       + (z + 1) * widthT).u32)
      indices.add(((x + 1) + z       * widthT).u32)

      indices.add((x       + (z + 1) * widthT).u32)
      indices.add(((x + 1) + (z + 1) * widthT).u32)
      indices.add(((x + 1) + z       * widthT).u32)

  var
    shader = newShader(shaderData)
    mesho  = newMesh(vertices, uvs, normals, indices)

    uModel      = shader.getLocation("uModel")
    uView       = shader.getLocation("uView")
    uProjection = shader.getLocation("uProjection")
    uGrass      = shader.getLocation("uGrass")
    uStone      = shader.getLocation("uStone")

    projection  = perspective(radians(45.0f), win.ratio(), 0.1f, 1000.0f)

  var tex_grass = newTexture("examples/res/images/grass.jpg")
  var tex_stone = newTexture("examples/res/images/stone.jpg")
  shader.setInt(uGrass, 0)
  shader.setInt(uStone, 1)

  mgCullTest(true)

  var
    pos = vec3(0.0f, -10.0f, -100.0f)
    wireframe = false

  const velocity = 10.0f

  while win.isOpen():
    # updat
    win.update()
    let io = igGetIO()
    if GLFWKey.Q.isPressed():
      pos.y += io.deltaTime * velocity
    elif GLFWKey.E.isPressed():
      pos.y -= io.deltaTime * velocity

    if GLFWKEy.W.isPressed():
      pos.z += io.deltaTime * velocity
    elif GLFWKEy.S.isPressed():
      pos.z -= io.deltaTime * velocity

    if GLFWKey.A.isPressed():
      pos.x += io.deltaTime * velocity
    elif GLFWKey.D.isPressed():
      pos.x -= io.deltaTime * velocity

    igText("Pos: ")
    igSameLine()
    var p: array[3, float32] = pos
    discard igDragFloat3("##pos", p)
    igText("fps: %f", io.framerate)
    igText("Wireframe: ")
    igSameLine()
    discard igCheckbox("##wireframe", wireframe.addr)

    if GLFWKey.Tab.isJustPressed():
      wireframe = not wireframe

    # draw
    win.clearScreen(vec3(33f).rgb())

    mgWireFrame(wireframe)

    tex_grass.use(0)
    tex_stone.use(1)

    var trans = mat4(1.0f)
    var view  = mat4(1.0f).translate(pos)

    shader.setMat(uModel, trans)
    shader.setMat(uView, view)
    shader.setMat(uProjection, projection)

    mesho.use()

    win.draw()

  tex_grass.clean()
  tex_stone.clean()
  shader.clean()
  mesho.clean()
  win.clean()

main()
