class Italic
  constructor: (match) ->
    @match = match

  index: =>
    @match.index + 1

  length: =>
    @match[2].length

  markdown: =>
    "<em>#{this.match[2]}</em>".toHTML()

  html: ->
    "<em>#{this.match[3]}</em>".toHTML()

Italic.rule = /([^*]|^)(\*{1}([^\*]+)\*{1})/gi

Written.Parsers.Inline.register Italic

