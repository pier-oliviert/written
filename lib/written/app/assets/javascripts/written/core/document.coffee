#= require ../parsers/parsers

Written.Document = class
  constructor: (textContent, parsers) ->
    @texts = new Array()

    @head = Written.Parsers.Block.parse(textContent.split('\n').reverse())

    node = @head

    while node
      Written.Parsers.Inline.parse(node)
      text = node.toString()
      @texts.push(text)
      node = node.nextDocumentNode


  toString: =>
    @texts.join('\n')
