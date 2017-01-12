CustomGeometry = require './CustomGeometry'

class Clouds extends THREE.Mesh
  constructor: (@numClouds, @imgPath)->
    baseGeometry = new THREE.PlaneBufferGeometry 100, 100
    @geometry = new CustomGeometry baseGeometry, @numClouds

    @material = new THREE.RawShaderMaterial {
      uniforms: {
        time: { type: '1f', value: 0 }
        fogStart: { type: '1f', value: 0 }
        fogEnd: { type: '1f', value: 0 }
        near: { type: '1f', value: 0 }
        far: { type: '1f', value: 0 }
        texture: { type: 't' }
        fogColor: { type: '4f', value: new THREE.Vector4(1, 1, 1, 1) }
      }
      vertexShader: require('./glsl/clouds.vert')
      fragmentShader: require('./glsl/clouds.frag')
      transparent: true
      depthWrite: false
      depthTest: false
      # blending: THREE.AdditiveBlending
      # wireframe: true
      # side: THREE.DoubleSide
    }

    super @geometry, @material
    @position.y -= 150


  init: ->
    data = []
    for i in [0...@numClouds]
      v = new THREE.Vector3(
        Math.random() * 800
        utils.map Math.random(), 0, 1, -10, 10
        0
      )
      v.applyAxisAngle new THREE.Vector3(0, 1, 0), Math.random() * 2 * Math.PI
      data.push {
        x: v.x
        y: v.y
        z: v.z
      }

    @geometry.addData 'translate', data, 3
    @frustumCulled = false

    return new Promise (resolve)=>
      new THREE.TextureLoader().load @imgPath, (texture)=>
        texture.flipY = false
        texture.needUpdate = true
        @material.uniforms.texture.value = texture
        resolve()


  setFog: (fogStart, fogEnd, near, far, fogColor)->
    @material.uniforms.fogStart.value = fogStart
    @material.uniforms.fogEnd.value = fogEnd
    @material.uniforms.near.value = near
    @material.uniforms.far.value = far
    @material.uniforms.fogColor.value = fogColor
    return


  update: ->
    @material.uniforms.time.value += 0.001
    return


module.exports = Clouds
