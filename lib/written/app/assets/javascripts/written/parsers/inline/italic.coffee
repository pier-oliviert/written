class Italic
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    "<em>#{this.match[1]}</em>".toHTML()

  html: ->
    "<em>#{this.match[3]}</em>".toHTML()

Italic.rule = /((_{1})([^_]+)(_{1}))/gi

Written.Parsers.Inline.register Italic

