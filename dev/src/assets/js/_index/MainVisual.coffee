window.utils = require '../_utils/utils'
KingaShinnen = require './KingaShinnen'
Floor = require './Floor'
Clouds = require './Clouds'
Message = require './Message'
Arrows = require './Arrows'

class MainVisual
  _DEFAULT_MSG = [ 'Hello world!', 'I wish you all the best for this year!' ]

  _KINGASHINNEN_IMG_PATH = '/assets/img/kingaShinnen.png'
  _HAPPY_NEW_YEAR_IMG_PATH = '/assets/img/happyNewYear.png'
  _YEAR_IMG_PATH = '/assets/img/year.png'
  _CLOUDS_SPRITES_PATH = '/assets/img/clouds.png'
  _ARROW_IMG_PATH = '/assets/img/arrow.png'

  _NUM_KINGASHINNEN_INSTANCES = 3000
  _NUM_YEAR_INSTANCES = 1000
  _NUM_CLOUDS = 400

  _AXIS_Z_ON_XZ = new THREE.Vector2 0, -1

  constructor: (@parent)->
    @$container = $ '#main'

    @isWebGLSupported = false

    @sensorAxisDir = -1
    if utils.isiPhone or utils.isiPad
      @sensorAxisDir = 1


  init: ->
    @msgs = _DEFAULT_MSG
    @swMode = false

    # parse get params
    params = location.search.replace('?', '').split '&'
    for p in params
      [key, value] = p.split '='

      if key is 'msg' and value isnt ''
        @msgs = decodeURIComponent(value).split('\n')

    # check if webGL is available
    if Detector.webgl
      # supported
      @initWebGL()
    else
      # not supported
      @showNotSupported()


  showNotSupported: ->
    log 'not supported'
    alert 'Sorry. Your Device is not supported.'
    return



  # webGL initalization
  initWebGL: ->
    @width = @$container.width()
    @height = @$container.height()

    # three.js basic
    @$canvas = @$container.find 'canvas'

    # webGL renderer
    @renderer = new THREE.WebGLRenderer
      canvas: @$canvas.get(0)
      # alpha: true
      antialias: true
    @renderer.setClearColor　0xffffff

    if !@renderer.extensions.get('OES_texture_float')? and !@renderer.extensions.get('OES_texture_half_float')?
      @showNotSupported()

    # 高解像度対応
    pixelRatio = Math.min(window.devicePixelRatio or 1, 2)
    @renderer.setPixelRatio pixelRatio

    # scene
    @scene = new THREE.Scene()

    # camera
    @camera = new THREE.PerspectiveCamera 45, 100, 0.1, 1000
    # @camera.position.z = 300

    @cameraDefaultPos = @camera.position.clone()
    @cameraMatrix = new THREE.Matrix4()

    # VRControls
    @controls = new THREE.VRControls @camera
    # @controls = new THREE.TrackballControls @camera

    # VREffect
    @effect = new THREE.VREffect @renderer
    @effect.setSize @width, @height

    # WebVRManager
    @manager = new WebVRManager @renderer, @effect

    # webfont load event
    return new Promise (resolve)=>
      WebFont.load
        # custom:
        #   families: [ 'YakuHanJP', 'NotoSansJP' ]
        custom:
          families: [ 'Sawarabi Mincho' ]
        active: =>
          log 'fonts loaded'
          resolve()
        inactive: ->
          log '?'
    .then =>
      @isWebGLSupported = true
      return @init3DObjects()


  init3DObjects: (words)->
    fogColor = new THREE.Vector4 1, 1, 1, 1

    @kintaShinnen = new KingaShinnen _NUM_KINGASHINNEN_INSTANCES
    @kintaShinnen.renderOrder = 1
    mat4 = new THREE.Matrix4()
    @kintaShinnen.setUniform 'modelMatrixInverse', { type: 'm4', value: mat4.getInverse(@kintaShinnen.matrixWorld) }

    @year2017 = new KingaShinnen _NUM_YEAR_INSTANCES
    @year2017.renderOrder = 1

    @clouds = new Clouds _NUM_CLOUDS, _CLOUDS_SPRITES_PATH
    @clouds.renderOrder = 2
    @clouds.setFog 0.2, 0.8, @camera.near, @camera.far, fogColor

    @floor = new Floor()
    @floor.renderOrder = 1
    @floor.setFog 0.2, 0.8, @camera.near, @camera.far, fogColor

    @message = new Message @msgs
    @message.createRenderTexture @renderer, @camera

    @arrows = new Arrows _ARROW_IMG_PATH

    @scene.add @floor
    @scene.add @kintaShinnen
    @scene.add @year2017
    @scene.add @clouds
    @scene.add @message
    @scene.add @arrows

    return Promise.all [
      @kintaShinnen.init _KINGASHINNEN_IMG_PATH, Math.PI
      @kintaShinnen.loadTranslate2 _HAPPY_NEW_YEAR_IMG_PATH
      @year2017.init _YEAR_IMG_PATH
      @year2017.loadTranslate2 _YEAR_IMG_PATH
      @clouds.init()
      @arrows.init()
    ]


  update3DObjects: ->
    eyeDir = @camera.getWorldDirection()
    v = new THREE.Vector2(eyeDir.x, eyeDir.z).normalize()

    cameraRotateY = Math.acos v.dot(_AXIS_Z_ON_XZ)
    if !@isShownMsgOnce
      if Math.abs(Math.PI - cameraRotateY) < 0.06
        @isShownMsgOnce = true
        @showMsg()

    @kintaShinnen.update eyeDir, cameraRotateY
    @year2017.update eyeDir, cameraRotateY
    @floor.update()
    @clouds.update()
    @message.update eyeDir
    @arrows.update()
    return


  # メッセージを表示
  showMsg: ->
    log 'show message'
    @kintaShinnen.transformTxt(1)
    .then => @message.transform()
    return



  # 描画
  draw: =>
    @update3DObjects()
    @controls.update()
    @manager.render @scene, @camera
    return


  # resize
  resize: =>
    if !@isWebGLSupported then return

    @width = @$container.width()
    @height = @$container.height()

    # @controls.handleResize()

    @effect.setSize @width, @height
    @renderer.setSize @width, @height
    @renderer.setViewport 0, 0, @width, @height

    @camera.aspect = @width / @height
    @camera.updateProjectionMatrix()

    return


  # window mosue move handler
  windowMouseMoveHandler: (e)=>
    dx = utils.map e.pageX / @width, 0, 1, -1, 1
    dy = utils.map e.pageY / @height, 0, 1, -1, 1
    @setCameraPos dx, dy
    return


  # device motion handler
  deviceMotionHandler: (e)=>
    dx = e.originalEvent.accelerationIncludingGravity.x / 4
    dy = e.originalEvent.accelerationIncludingGravity.y / 4
    @setCameraPos dx * @sensorAxisDir, dy * @sensorAxisDir
    return


  # カメラの位置をセット
  setCameraPos: (dx, dy)->
    pos = @cameraDefaultPos.clone()
    @cameraMatrix.identity()
    @cameraMatrix.makeRotationX dy * Math.PI / 6
    pos.applyMatrix4 @cameraMatrix
    @cameraMatrix.makeRotationY dx * Math.PI / 6
    pos.applyMatrix4 @cameraMatrix

    TweenMax.to @camera.position, 3.0, {
      overwrite: true
      x: pos.x
      y: pos.y
      z: pos.z
      ease: Expo.easeOut
      onUpdate: => @camera.lookAt new THREE.Vector3()
    }
    return

module.exports = MainVisual
