class Strong
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    "<strong is='written-strong'>#{@match[0]}</strong>".toHTML()

  html: =>
    "<strong>#{@match[3]}</strong>".toHTML()

Strong.rule = /((\*{1})([^\*]+)(\*{1}))/gi

Written.Parsers.Inline.register Strong

prototype = Object.create(HTMLElement.prototype)

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

document.registerElement('written-strong', {
  prototype: prototype
  extends: 'strong'
})
