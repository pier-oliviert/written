#= require ../parsers/parsers

Written.Document = class
  constructor: (textContent, parsers) ->
    @texts = new Array()

    @head = parsers.block.parse(textContent.split('\n').reverse())

    node = @head

    while node
      parsers.inline.parse(node)
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
