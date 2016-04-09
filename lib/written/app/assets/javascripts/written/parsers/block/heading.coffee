class Header
  constructor: (match) ->
    @match = match

  render: (text) =>
    size = @match[1].length
    return "<h#{size}>#{text}</h#{size}>".toHTML()
    
  toHTMLString: (node) =>
    size = @match[1].length
    text = ''
    child = node.firstChild
    while child
      if child.toHTMLString
        text += child.toHTMLString()
      else
        text += child.toString()
      child = child.nextSibling


    "<h#{size}>#{text.slice(this.match[0].length)}</h#{size}>"

Written.Parsers.Block.register Header, /^(#{1,6}) /i
