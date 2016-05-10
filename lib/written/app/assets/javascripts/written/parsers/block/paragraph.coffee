class Paragraph
  @parserName: 'Paragraph'
  multiline: false

  constructor: (match) ->
    @match = match

  processContent: (callback) =>
    if @content?
      throw "Content Error: The content was already processed"
      return

    @content = callback(@match[0])

  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<p is='written-p'>".toHTML()
    for text in @content
      if text.markdown?
        node.appendChild(text.markdown())
      else
        node.appendChild(document.createTextNode(text))

    node

  html: =>
    node = "<p>".toHTML()
    for text in @content
      if text.html?
        node.appendChild(text.html())
      else
        node.appendChild(document.createTextNode(text))

    node



Paragraph.rule = /.*/i

Written.Parsers.Block.register Paragraph, true

prototype = Object.create(HTMLParagraphElement.prototype)

prototype.getRange = (offset, walker) ->
  range = document.createRange()

  if !@firstChild?
    range.setStart(this, 0)
  else
    while walker.nextNode()
      if walker.currentNode.length < offset
        offset -= walker.currentNode.length
        continue

      range.setStart(walker.currentNode, offset)
      break

  range.collapse(true)
  range

prototype.toString = ->
  @textContent

document.registerElement('written-p', {
  prototype: prototype
  extends: 'p'
})
