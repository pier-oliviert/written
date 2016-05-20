class Italic
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  toEditor: =>
    Written.toHTML("<em>#{this.match[1]}</em>")

  toHTML: ->
    Written.toHTML("<em>#{this.match[3]}</em>")

Written.Parsers.register {
  parser: Italic
  node: 'em'
  type: 'inline'
  rule: /((_{1})([^_]+)(_{1}))/gi
}
