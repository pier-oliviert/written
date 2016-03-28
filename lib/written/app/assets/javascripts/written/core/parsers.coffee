class Parsers
  constructor: ->
    @store = {}

  add: (name, kls) =>
    @store[name] = kls

  sort: =>
    [
      @store.lists
      @store.code
      @store.image
      @store.headers
      @store.link
      @store.word
    ]

parsers = new Parsers()
@Blank.Parsers = ->
  parsers

