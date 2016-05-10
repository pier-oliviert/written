class Italic
  @parserName: 'Italic'
  constructor: (match) ->
    @match = match

  index: =>
    @match.index

  length: =>
    @match[0].length

  markdown: =>
    "<em is='written-em'>#{this.match[1]}</em>".toHTML()

  html: ->
    "<em>#{this.match[3]}</em>".toHTML()

Italic.rule = /((_{1})([^_]+)(_{1}))/gi

Written.Parsers.Inline.register Italic

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

document.registerElement('written-em', {
  prototype: prototype
  extends: 'em'
})
