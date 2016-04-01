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


    @mutations = new MutationObserver(@normalize.bind(this, callback))
    @mutations.observe @element(), @settings()

  normalize: (callback, events) =>
    @pause =>
      for event in events
        if event.target instanceof HTMLElement
          for br in event.target.querySelectorAll('br')
            br.remove()

    @pause(callback)

  pause: (callback) =>
    @mutations.disconnect()
    callback()
    @mutations.observe @element(), @settings()
