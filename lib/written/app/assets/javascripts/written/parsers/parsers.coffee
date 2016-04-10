class @Written.Parsers
  constructor: ->
    @block = new Written.Parsers.Block()
    @inline = new Written.Parsers.Inline()

  use: (type, name) ->
    if type != 'block' && type != 'inline'
      raise 'error: Written.Parsers can either be "block" or "inline"'
      return

    @[type].use(name)

  available: ->
    {
      block: Written.Parsers.Block.parsers.available,
      inline: Written.Parsers.Inline.parsers.available
    }

  freeze: ->
    @block.freeze()
    @inline.freeze()

@Written.Parsers.default = ->
  parsers = new Written.Parsers()
  parsers.use('inline', 'all')
  parsers.use('block', 'all')
  parsers
