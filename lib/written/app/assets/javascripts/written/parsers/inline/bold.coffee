class Bold extends Written.Parsers.Inline
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
  parser: Bold
  name: 'bold'
  nodes: ['strong']
  type: 'inline'
  rule: /((\*{1})([^\*]+)(\*{1}))/gi
}
