HTMLElement::toString = ->
  if @nodeName == 'FIGURE'
    (@querySelector('figcaption') || this).textContent
  else
    @textContent

HTMLElement::toHTMLString = (parser) ->
  if parser?
    parser.toHTMLString(this)
  else
    text = ''
    child = @firstChild
    while child
      if child.toHTMLString
        text += child.toHTMLString()
      else
        text += child.toString()
      child = child.nextSibling

    "<#{this.nodeName}>#{text}</#{this.nodeName}>"



origCloneNode = HTMLElement::cloneNode
HTMLElement::cloneNode = (deep) ->
  el = origCloneNode.bind(this, deep).call()
  el.toHTMLString = this.toHTMLString
  el

HTMLElement::compare = (node) ->
  @toHTMLString().localeCompare(node.toHTMLString())

HTMLElement::getRange = (offset, walker) ->
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
