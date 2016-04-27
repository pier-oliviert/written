class Link
  constructor: (match) ->
    @match = match

  index: =>
    @match.index 

  length: =>
    @match[0].length

  markdown: =>
    "<a href='javascript:void(0)'><strong>#{@match[1]}</strong>#{@match[3]}</a>".toHTML()

  html: =>
    "<a href='#{@match[4]}'>#{@match[2]}</a>".toHTML()

Link.rule = /!{0}(\[([^\]]+)\])(\(([^\)]+)\))/gi

Written.Parsers.Inline.register Link
