class Code
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  toEditor: =>
    node = Written.toHTML("<code>#{this.match[0]}</code>")
    if @match[3]?
      node.classList.add("language-#{@match[3]}")

    if @highlight?
      @highlight(node)
    node

  toHTML: =>
    node = Written.toHTML("<code>#{this.match[4]}</code>")
    if @match[3]?
      node.classList.add("language-#{@match[3]}")

    node



Written.Parsers.register {
  parser: Code
  node: 'code'
  type: 'inline'
  rule: /((~{3})([a-z]+)?)\s(.+)?(~{3})/gi
  highlightWith: (callback) ->
    Code.prototype.highlight = callback
}
