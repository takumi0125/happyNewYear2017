CustomGeometry = require './CustomGeometry'
RenderTexture = require './RenderTexture'

class Message extends THREE.Mesh
  _NUM_GEOMETRIES_PER_MSG = 10
  _OFFSET_Z = -300
  _OFFSET_Y = -30
  _SCALE = 1 / 4
  _FONT_SIZE = 60

  constructor: (@msgs)->
    @geometry = new THREE.BufferGeometry()

    @currentTime = new Date().getTime()

    @vertices = []
    @translates = []
    @instanceIndices = []
    @lineIndices = []
    @uvs = []
    @randomValues = []
    @indices = []

    @numPushedIndices = 0
    @numMsgs = @msgs.length
    @numInstances = 0

    @animationParam1 = 1
    @seperationDistance = 30
    @alignmentDistance = 40
    @cohesionDistance = 40


    # txt texture
    cvs = $('<canvas>').get 0
    ctx = cvs.getContext '2d'

    lineHeight = 1.4
    msgHeight = lineHeight * _FONT_SIZE
    fontName = 'Sawarabi Mincho'
    # fontName = 'Hannari'
    fontSetting = "normal #{_FONT_SIZE}px/#{lineHeight}em georgia, '#{fontName}', serif"
    color = '#fff'

    ctx.fillStyle = color
    ctx.font = fontSetting
    maxMsgWidth = 0
    msgWidths = []

    for m, i in @msgs
      msgWidth = ctx.measureText(m).width
      msgWidths.push msgWidth
      maxMsgWidth = Math.max msgWidth, maxMsgWidth

    cvs.width = maxMsgWidth
    cvs.height = @numMsgs * msgHeight
    ctx.clearRect 0, 0, cvs.width, cvs.height
    ctx.fillStyle = color
    ctx.font = fontSetting


    # draw txt texture and create geometry
    for m, i in @msgs
      ctx.fillText m, 0, i * msgHeight + msgHeight * 0.7
      @addMsgLineGeometries i, maxMsgWidth, msgWidths[i], msgHeight

    @geometry.addAttribute 'position', new THREE.BufferAttribute(new Float32Array(@vertices), 3)
    @geometry.addAttribute 'translate', new THREE.BufferAttribute(new Float32Array(@translates), 3)
    @geometry.addAttribute 'uv', new THREE.BufferAttribute(new Float32Array(@uvs), 2)
    @geometry.addAttribute 'instanceIndex', new THREE.BufferAttribute(new Float32Array(@instanceIndices), 1)
    @geometry.addAttribute 'lineIndex', new THREE.BufferAttribute(new Float32Array(@lineIndices), 1)
    @geometry.addAttribute 'randomValues', new THREE.BufferAttribute(new Float32Array(@randomValues), 3)
    @geometry.setIndex new THREE.BufferAttribute(new Uint16Array(@indices), 1)

    numInstances = @instanceIndices.length

    delete @vertices
    delete @translates
    delete @uvs
    delete @instanceIndices
    delete @lineIndices
    delete @randomValues
    delete @indices

    @geometry.computeVertexNormals()

    # debug
    # $(cvs).css
    #   position: 'absolute'
    #   top: 0
    #   left: 0
    #   zIndex: 100000
    # document.body.appendChild cvs

    txtTexture = new THREE.Texture(cvs)
    txtTexture.flipY = false
    txtTexture.needsUpdate = true

    @material = new THREE.RawShaderMaterial {
      uniforms: {
        time: { type: '1f', value: 0 }
        numInstances: { type: '1f', value: @numInstances }
        animationParam1: { type: '1f', value: @animationParam1 }
        txtTexture: { type: 't', value: txtTexture }
        velocityTexture: { type: 't', value: null }
        posTexture: { type: 't', value: null }
        renderTextureResolution: { type: '2f', value: new THREE.Vector2() }
      }
      vertexShader: require('./glsl/message.vert')
      fragmentShader: require('./glsl/message.frag')
      transparent: true
      side: THREE.DoubleSide
      # wireframe: true
    }

    super @geometry, @material
    @frustumCulled = false

    log 'instances', @numInstances
    log 'textureColSize', @getTextureColSize()


  initDatGUI: ->
    # dat.gui
    gui = new dat.GUI()

    controler1 = gui.add(@, 'animationParam1', 0, 1);
    controler1.onChange (value)=> @material.uniforms.animationParam1.value = value

    controler2 = gui.add(@, 'seperationDistance', 0, 100);
    controler3 = gui.add(@, 'alignmentDistance', 0, 100);
    controler4 = gui.add(@, 'cohesionDistance', 0, 100);

    controler2.onChange (value)=> @updateParams @seperationDistance, @alignmentDistance, @cohesionDistance
    controler3.onChange (value)=> @updateParams @seperationDistance, @alignmentDistance, @cohesionDistance
    controler4.onChange (value)=> @updateParams @seperationDistance, @alignmentDistance, @cohesionDistance

    return


  # render texture
  createRenderTexture: (renderer, camera)->
    size = @getTextureColSize()

    @material.uniforms.renderTextureResolution.value.x = size
    @material.uniforms.renderTextureResolution.value.y = size

    @velocityTexture = new RenderTexture(
      size
      size
      renderer
      camera
      require('./glsl/renderTextureInit.vert')
      require('./glsl/velocityInit.frag')
      require('./glsl/renderTexture.vert')
      require('./glsl/velocity.frag')
    )
    @velocityTexture.initOtherTexture 'posTexture'
    @velocityTexture.initUniforms
      delta: { type: '1f', value: 0 }
      seperationDistance: { type: '1f', value: @seperationDistance }
      alignmentDistance: { type: '1f', value: @alignmentDistance }
      cohesionDistance: { type: '1f', value: @cohesionDistance }
      numInstances: { type: '1f', value: @numInstances }
      eyeDir: { type: '3f', value: new THREE.Vector3() }

    @posTexture = new RenderTexture(
      size
      size
      renderer
      camera
      require('./glsl/renderTextureInit.vert')
      require('./glsl/positionInit.frag')
      require('./glsl/renderTexture.vert')
      require('./glsl/position.frag')
    )
    @posTexture.initOtherTexture 'velocityTexture'
    @posTexture.initUniforms
      delta: { type: '1f', value: 0 }

    # @initDatGUI()

    @updateParams @seperationDistance, @alignmentDistance, @cohesionDistance

    return


  updateParams: (seperationDistance, alignmentDistance, cohesionDistance)->
    @velocityTexture.updateUniform 'seperationDistance', seperationDistance
    @velocityTexture.updateUniform 'alignmentDistance', alignmentDistance
    @velocityTexture.updateUniform 'cohesionDistance', cohesionDistance
    return



  alignPow2: (num)->
    i = 1
    while (num > (i <<= 1))
      if !i then break
    return i


  getTextureColSize: ->
    n = Math.ceil(Math.sqrt(@numInstances))
    n = @alignPow2 n
    return n


  getRandomValue: ->
    return (Math.random() + Math.random() + Math.random() + Math.random() + Math.random()) / 5


  # add geometry lines
  addMsgLineGeometries: (msgIndex, maxMsgWidth, msgWidth, msgHeight)->
    gridHeight = msgHeight / _NUM_GEOMETRIES_PER_MSG
    numGrids = Math.floor(msgWidth / gridHeight)
    gridWidth = msgWidth / numGrids

    baseGeometry = new THREE.PlaneBufferGeometry gridWidth, gridHeight

    numIndices = baseGeometry.index.array.length
    numPositions = baseGeometry.attributes.position.array.length

    for i in [0..._NUM_GEOMETRIES_PER_MSG]
      offsetX = (-msgWidth + gridWidth) / 2
      offsetY = -gridHeight / 2 - (gridHeight * i) - (gridHeight * _NUM_GEOMETRIES_PER_MSG * msgIndex)

      for j in [0...numGrids]
        randomValues = [
          @getRandomValue()
          @getRandomValue()
          @getRandomValue()
        ]

        t = new THREE.Vector3(
          (offsetX + j * gridWidth) * _SCALE
          offsetY * _SCALE + _OFFSET_Y
          _OFFSET_Z
        )

        for k in [0...numPositions / 3]
          # plane vertices
          v = new THREE.Vector3(
            baseGeometry.attributes.position.array[k * 3 + 0]
            baseGeometry.attributes.position.array[k * 3 + 1]
            baseGeometry.attributes.position.array[k * 3 + 2]
          )
          v.multiplyScalar _SCALE

          tv = v.clone()
          tv.add t
          tv.sub v

          @vertices.push v.x
          @vertices.push v.y
          @vertices.push v.z

          @translates.push tv.x
          @translates.push tv.y
          @translates.push tv.z

          @randomValues.push randomValues[0]
          @randomValues.push randomValues[1]
          @randomValues.push randomValues[2]

          uvXUnitPerGrid = 1 / numGrids * msgWidth / maxMsgWidth
          uvYUnitPerLine = 1 / @numMsgs
          uvYUnitPerInstance = uvYUnitPerLine / _NUM_GEOMETRIES_PER_MSG

          @uvs.push (baseGeometry.attributes.uv.array[k * 2 + 0] + j) * uvXUnitPerGrid
          uvY = baseGeometry.attributes.uv.array[k * 2 + 1]
          @uvs.push 1 - (uvY * uvYUnitPerInstance + (@numMsgs - msgIndex - 1) * uvYUnitPerLine + (_NUM_GEOMETRIES_PER_MSG - i) * uvYUnitPerInstance)

          @instanceIndices.push @numInstances
          @lineIndices.push i

        for k in [0...numIndices]
          @indices.push baseGeometry.index.array[k] + numPositions / 3 * (i * numGrids + j) + @numPushedIndices

        @numInstances++

    @numPushedIndices += (numPositions / 3 * numGrids * _NUM_GEOMETRIES_PER_MSG)
    baseGeometry.dispose()
    return


  transform: (delay)->
    return new Promise (resolve)=>
      TweenMax.to @material.uniforms.animationParam1, 4, {
        value: 0
        ease: Linear.easeNone
        delay: delay
        onComplete: -> resolve()
      }


  update: (eyeDir)->
    currentTime = new Date().getTime()
    delta = (currentTime - @currentTime) / 1000
    @currentTime = currentTime

    @velocityTexture.updateUniform 'eyeDir', eyeDir
    @velocityTexture.updateUniform 'delta', delta
    @velocityTexture.updateOtherTexture 'posTexture', @posTexture.getTexture()
    @velocityTexture.update()

    @posTexture.updateUniform 'delta', delta
    @posTexture.updateOtherTexture 'velocityTexture', @velocityTexture.getTexture()
    @posTexture.update()


    @material.uniforms.time.value += 0.001
    @material.uniforms.posTexture.value = @posTexture.getTexture()
    @material.uniforms.velocityTexture.value = @velocityTexture.getTexture()
    return


module.exports = Message
