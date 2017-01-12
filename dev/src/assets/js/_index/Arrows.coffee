CustomGeometry = require './CustomGeometry'

class Arrows extends THREE.Mesh
  constructor: (@imgPath)->
    baseGeometry = new THREE.PlaneBufferGeometry 20, 16
    @geometry = new CustomGeometry baseGeometry, 4

    @material = new THREE.RawShaderMaterial {
      uniforms: {
        time: { type: '1f', value: 0 }
        texture: { type: 't' }
        radius: { type: '1f', value: 300 }
      }
      vertexShader: require('./glsl/arrows.vert')
      fragmentShader: require('./glsl/arrows.frag')
      transparent: true
      # wireframe: true
      # side: THREE.DoubleSide
    }

    super @geometry, @material
    baseGeometry.dispose()


  init: ->
    degree1 = Math.PI * 0.125
    degree2 = Math.PI * 0.67
    degree3 = Math.PI
    @geometry.addData 'rotationY', [ -degree1, degree1, -degree2, degree2 ], 1
    @geometry.addData 'rotationZ', [ 0, -degree3, 0, -degree3 ], 1
    @frustumCulled = false

    return new Promise (resolve)=>
      new THREE.TextureLoader().load @imgPath, (texture)=>
        texture.flipY = false
        texture.needUpdate = true
        @material.uniforms.texture.value = texture
        resolve()


  update: ->
    @material.uniforms.time.value += 0.001
    return


module.exports = Arrows
