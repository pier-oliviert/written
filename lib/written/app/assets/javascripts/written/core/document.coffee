#= require ../parsers/parsers

class Written.Document
  constructor: (text, parsers) ->
    @blocks = parsers.parse(parsers.blocks, text)

    @blocks.forEach (block) =>
      if block.text?
        if block.multiline
          block.content = block.text().split('\n').map (text) ->
            parsers.parse(parsers.inlines, text)
        else
          block.content = parsers.parse(parsers.inlines, block.text())

  freeze: =>
    Object.freeze(@blocks)
    Object.freeze(@cursor)

  toHTMLString: =>
    text = ''

    @blocks.forEach (node) ->
      text += node.html().outerHTML + "\n"

    text

  toString: =>
    if @toString.cache?
      return @toString.cache

    texts = @blocks.map (block) ->
      block.raw()

    texts.join('\n')

