class Floor extends THREE.Mesh
  constructor: ->
    @geometry = new THREE.PlaneGeometry 2000, 2000, 50, 50
    @geometry.rotateX -Math.PI / 2

    @material = new THREE.RawShaderMaterial {
      uniforms: {
        time: { type: '1f', value: 0 }
        fogStart: { type: '1f', value: 0 }
        fogEnd: { type: '1f', value: 0 }
        near: { type: '1f', value: 0 }
        far: { type: '1f', value: 0 }
        fogColor: { type: '4f', value: new THREE.Vector4(1, 1, 1, 1) }
      }
      vertexShader: require('./glsl/floor.vert')
      fragmentShader: require('./glsl/floor.frag')
      # blending: THREE.AdditiveBlending
      # wireframe: true
      transparent: true
    }

    super @geometry, @material
    @position.y -= 200


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


module.exports = Floor
