class Written.Observer
  constructor: (element, callback) ->
    @element = ->
      element

    @settings = ->
      {
        childList: true
        subtree: true
        characterData: true
      }


    @mutations = new MutationObserver(callback)
    @mutations.observe @element(), @settings()

  pause: (callback) =>
    @mutations.disconnect()
    callback()
    @mutations.observe @element(), @settings()
