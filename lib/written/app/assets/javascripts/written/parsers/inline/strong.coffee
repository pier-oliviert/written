class Strong
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  toEditor: =>
    Written.toHTML("<strong>#{@match[0]}</strong>")

  toHTML: =>
    Written.toHTML("<strong>#{@match[3]}</strong>")

Written.Parsers.register {
  parser: Strong
  node: 'strong'
  type: 'inline'
  rule: /((\*{1})([^\*]+)(\*{1}))/gi
}
