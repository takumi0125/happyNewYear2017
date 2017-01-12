CustomGeometry = require './CustomGeometry'

class KingaShinnen extends THREE.Mesh
  _IMG_POSITION_RATIO = 1 / 3
  _OFFSET_Z = -300
  _OFFSET_Y = 60

  constructor: (@numInstances)->

    # baseGeometry = new THREE.BoxBufferGeometry 1, 1, 1
    baseGeometry = new THREE.SphereBufferGeometry 0.8, 4, 2

    @geometry = new CustomGeometry baseGeometry, @numInstances

    @material = new THREE.RawShaderMaterial {
      uniforms: {
        time: { type: '1f', value: 0 }
        eyeDir: { type: '3f', value: new THREE.Vector3() }
        rotateY: { type: 'float', value: 0 }
        cameraRotateY: { type: 'float', value: 0 }
        animationParam1: { type: 'float', value: 1 }
        animationParam2: { type: 'float', value: 0 }
      }
      vertexShader: require('./glsl/kingaShinnen.vert')
      fragmentShader: require('./glsl/kingaShinnen.frag')
      transparent: true
      # blending: THREE.AdditiveBlending
      # wireframe: true
    }

    super @geometry, @material
    baseGeometry.dispose()



  transformTxt: (delay)->
    return new Promise (resolve)=>
      TweenMax.to @material.uniforms.animationParam1, 2, {
        value: 0
        ease: Linear.easeNone
        delay: delay
        onComplete: -> resolve()
      }



  init: (imgPath, @rotateY = 0)->
    @material.uniforms.rotateY.value = @rotateY
    @createRandomValues()
    return @loadImgData imgPath, 'translate'


  createRandomValues: ->
    randomValues = []

    for i in [0...@numInstances]
      randomValues.push {
        x: @geometry.getRandomValue()
        y: @geometry.getRandomValue()
        z: @geometry.getRandomValue()
      }

    @geometry.addData 'randomValues', randomValues, 3



  loadImgData: (imgPath, attributeName, offsetY = 0)->
    return new Promise (resolve)=>
      cvs = $('<canvas>').get 0
      ctx = cvs.getContext '2d'

      $img = $('<img>').one 'load', (e)=>
        img = $img.get 0

        w = img.width
        h = img.height

        cvs.width = w
        cvs.height = h
        ctx.drawImage img, 0, 0

        imgData =  ctx.getImageData(0, 0, w, h).data

        translates = []

        for y in [0...h]
          for x in [0...w]
            index = y * w + x
            alpha = imgData[index * 4 + 3]
            if alpha > 0
              v = new THREE.Vector3(
                (x - img.width / 2) * _IMG_POSITION_RATIO
                (img.height / 2 - y) * _IMG_POSITION_RATIO + offsetY
                _OFFSET_Z + Math.random() * _OFFSET_Z / 30
              )
              v.applyAxisAngle new THREE.Vector3(0, 1, 0), @rotateY
              translates.push { x: v.x, y: v.y, z: v.z }

        translates = _.shuffle translates
        translates.length = @numInstances

        @geometry.addData attributeName, translates, 3

        resolve()

      .attr 'src', imgPath


  loadTranslate2: (imgPath)->
    return @loadImgData imgPath, 'translate2', _OFFSET_Y



  setUniform: (name, data)->
    @material.uniforms[name] = data
    return


  update: (eyeDir, cameraRotateY)->
    @material.uniforms.time.value += 0.001
    @material.uniforms.eyeDir.value = eyeDir
    @material.uniforms.cameraRotateY.value = cameraRotateY
    return



module.exports = KingaShinnen
