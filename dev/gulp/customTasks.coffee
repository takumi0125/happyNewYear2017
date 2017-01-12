####################
### custom tasks ###
####################

module.exports = (gulp, gulpPlugins, config, utils)->
  # indexSprites
  # utils.createSpritesTask 'indexSprites', "#{config.assetsDir}/img", "#{config.assetsDir}/css", 'sprites', '../img/sprites.png', true

  # lib.js
  utils.createJsConcatTask(
    'concatLibJs'
    [
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/*"

      "#{config.srcDir}/#{config.assetsDir}/js/_lib/threejs/three.js"
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/threejs/Detector.js"
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/threejs/TrackballControls.js"
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/threejs/VRControls.js"
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/threejs/VREffect.js"
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/threejs/WebVR.js"
    ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'lib'
  )

  # common.js
  utils.createWebpackJsTask(
    'indexJs'
    [ "#{config.srcDir}/#{config.assetsDir}/js/_index/init.coffee" ]
    [
      "#{config.srcDir}/#{config.assetsDir}/js/_index/**/*"
      "#{config.srcDir}/#{config.assetsDir}/js/_utils/**/*"
    ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'index'
  )
