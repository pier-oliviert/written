class Paragraph
  constructor: (match) ->
    @match = match
    @node = "<p>".toHTML()

  render: (str) =>
    @node.textContent = str
    @node

Written.Parsers.Block.register Paragraph, /.*/i, true
