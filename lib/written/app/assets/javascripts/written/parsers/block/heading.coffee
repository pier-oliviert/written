class Header
  constructor: (match) ->
    @match = match

  render: (text) =>
    size = @match[1].length
    return "<h#{size}>#{text}</h#{size}>".toHTML()
    

Written.Parsers.Block.register Header, /^(#{1,6}) /i
