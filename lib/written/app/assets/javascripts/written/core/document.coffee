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

  applyTo: (content) =>

    for block, index in @blocks
      remaining = Array.prototype.slice.call(content.children, index)
      element = remaining[0]
      node = @findNodeFor(block, remaining)

      content.insertBefore(node, element)

    elements = Array.prototype.slice.call(content.children, index)
    for element in elements
      element.remove()

    @cursor.focus()

  findNodeFor: (block, remaining) ->
    node = block.markdown()

    found = remaining.find (existing) ->
      block.equals(existing, node)

    found || node

  toString: =>
    if @toString.cache?
      return @toString.cache

    texts = @blocks.map (block) ->
      block.raw()

    texts.join('\n')

