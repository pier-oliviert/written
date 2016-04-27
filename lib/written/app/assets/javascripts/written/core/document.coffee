#= require ../parsers/parsers

class Written.Document
  constructor: (textContent, parsers) ->
    @markdown = textContent

    @blocks = parsers.block.parse(textContent.split('\n').reverse())

    @blocks.forEach (block) =>
      block.processContent(parsers.inline.parse.bind(parsers.inline))

  freeze: =>
    Object.freeze(@blocks)
    Object.freeze(@cursor)

  toHTMLString: =>
    text = ''

    @blocks.forEach (node) ->
      text += node.html().outerHTML + "\n"

    text

  toString: =>
    @markdown
