#= require ../parsers/parsers

Written.Document = class
  constructor: (textContent) ->
    @texts = new Array()

    @head = Written.Parsers.Block.parse(textContent.split('\n').reverse())

    node = @head

    while node
      Written.Parsers.Inline.parse(node)
      text = node.toString()
      @texts.push(text)
      node = node.nextDocumentNode



  toHTMLString: =>
    text = ''
    node = @head

    while node
      text += node.toHTMLString()
      node = node.nextDocumentNode

    text

  toString: =>
    @texts.join('\n')
