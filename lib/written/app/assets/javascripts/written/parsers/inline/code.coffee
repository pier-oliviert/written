class Code
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    node = "<code>#{this.match[0]}</code>".toHTML()
    if @match[3]?
      node.classList.add("language-#{@match[3]}")

    if @highlight?
      @highlight(node)
    node

  html: =>
    node = "<code>#{this.match[4]}</code>".toHTML()
    if @match[3]?
      node.classList.add("language-#{@match[3]}")

    node


Code.rule = /((~{3})([a-z]+)?)\s(.+)?(~{3})/gi

Written.Parsers.Inline.register Code

