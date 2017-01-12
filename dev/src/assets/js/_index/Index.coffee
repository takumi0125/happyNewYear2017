window.utils = require '../_utils/utils'
MainVisual = require './MainVisual'

class Index
  constructor: ->
    @$window = $ window
    @$body = $ 'body'

    $indicator = $('#indicator')

    ua = new UAParser()
    os = ua.getOS().name.toLowerCase()
    if (os isnt 'ios') and (os isnt 'android')
      $indicator.find('.txt').text 'Please drag to rotate.'


    @animationId = null
    @mainVisual = new MainVisual()
    Promise.all [
      @mainVisual.init()
      new Promise (resolve)-> setTimeout resolve, 3000
    ]
    .then =>
      @$window.on
        resize: @windowResizeHanlder
        vrdisplaypresentchange: @windowResizeHanlder
      .trigger 'resize'

      @update()

      return @removeContents $('#loading')

    .then =>
      $indicator.on 'click', (e)=>
        $indicator.off 'click'
        clearTimeout timer
        @removeContents $indicator
        return false

      timer = setTimeout (=>
        clearTimeout timer
        @removeContents $indicator
      ), 3000


  removeContents: ($contents)->
    return new Promise (resolve)=>
      $contents.addClass('hidden').on utils.transitionend, (e)=>
        $contents.remove()
        resolve()
        return
      return


  update: =>
    @animationId = requestAnimationFrame @update
    @mainVisual.draw()
    return


  deviceMotionHandler: (e)=>
    return


  mouseMoveHandler: (e)=>
    return


  windowResizeHanlder: (e = null)=>
    @mainVisual.resize()
    if @mainVisual.manager.mode is 3
      @$body.addClass 'vr'
    else
      @$body.removeClass 'vr'
    return


module.exports = Index
