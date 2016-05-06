class Strong
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    "<strong>#{@match[0]}</strong>".toHTML()

  html: =>
    "<strong>#{@match[3]}</strong>".toHTML()

Strong.rule = /((\*{1})([^\*]+)(\*{1}))/gi

Written.Parsers.Inline.register Strong
