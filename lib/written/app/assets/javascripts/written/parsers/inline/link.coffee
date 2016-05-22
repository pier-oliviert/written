class Link extends Written.Parsers.Inline
  constructor: (match) ->
    @match = match

  index: =>
    @match.index 

  length: =>
    @match[0].length

  toEditor: =>
    Written.toHTML("<a><strong>#{@match[1]}</strong>#{@match[3]}</a>")

  toHTML: =>
    Written.toHTML("<a href='#{@match[4]}'>#{@match[2]}</a>")


Written.Parsers.register {
  parser: Link
  node: 'a'
  type: 'inline'
  rule: /!{0}(\[([^\]]+)\])(\(([^\)]+)\))/gi
}
