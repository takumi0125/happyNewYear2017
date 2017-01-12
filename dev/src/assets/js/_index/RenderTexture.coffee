class RenderTexture
  constructor: (@width, @height, @renderer, @camera, initVertexShader, initFragmentShader, updateVertexShader, updateFragmentShader)->
    @currentTextureIndex = 0

    @renderTargets = [ new THREE.WebGLRenderTarget(@width, @height, {
      magFilter: THREE.NearestFilter
      minFilter: THREE.NearestFilter
      wrapS: THREE.ClampToEdgeWrapping
      wrapT: THREE.ClampToEdgeWrapping
      format: THREE.RGBAFormat
      type: (if(/(iPad|iPhone|iPod)/g.test(navigator.userAgent)) then THREE.HalfFloatType else THREE.FloatType)
      stencilBuffer: false
    })]
    @renderTargets[1] = @renderTargets[0].clone()


    initMaterial = new THREE.RawShaderMaterial {
      vertexShader: initVertexShader
      fragmentShader: initFragmentShader
    }

    mesh = new THREE.Mesh new THREE.PlaneGeometry(10000, 10000), initMaterial

    @scene = new THREE.Scene()
    @scene.add mesh

    @renderer.render @scene, @camera, @renderTargets[0]
    @renderer.render @scene, @camera, @renderTargets[1]

    initMaterial.dispose()
    initMaterial = null

    @updateMaterial = new THREE.RawShaderMaterial {
      uniforms: {
        texture: { type: 't', value: @getTexture() }
        time: { type: '1f', value: 0 }
      }
      vertexShader: updateVertexShader
      fragmentShader: updateFragmentShader
    }
    @updateMaterial.defines.resolution = 'vec2(' + @width.toFixed(1) + ', ' + @height.toFixed(1) + ')';
    mesh.material = @updateMaterial

    @renderTargets[0].texture.flipY = false
    @renderTargets[1].texture.flipY = false



  initOtherTexture: (name, value)->
    @updateMaterial.uniforms[name]= { type: 't', value: null }
    return


  updateOtherTexture: (name, value)->
    @updateMaterial.uniforms[name].value = value
    return


  setDefine: (name, value)->
    @updateMaterial.defines[name] = value;
    return



  initUniforms: (uniforms)->
    for name, uniform of uniforms
      @updateMaterial.uniforms[name] = uniform
    return


  updateUniform: (name, value)->
    @updateMaterial.uniforms[name].value = value
    return


  update: ->
    @updateMaterial.uniforms.texture.value = @getTexture()
    @updateMaterial.uniforms.time.value += 0.001
    @flipTexture()
    @renderer.render @scene, @camera, @renderTargets[@currentTextureIndex]
    return


  flipTexture: ->
    @currentTextureIndex = (@currentTextureIndex + 1) % 2
    return



  getTexture: ->
    return @renderTargets[@currentTextureIndex].texture



module.exports = RenderTexture
