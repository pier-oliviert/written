HTMLOListElement::toString = HTMLUListElement::toString = ->
  texts = Array.prototype.slice.call(@children).map (li) ->
    li.toString()
  texts.join("\n")


HTMLOListElement::toHTMLString = (parser) ->
  child = @firstChild
  text = ''
  while child
    if child.toHTMLString?
      text += child.toHTMLString(child)
    else
      text += child.toString()
    child = child.nextSibling

  "<ol>#{text}</ol>"
  
HTMLUListElement::toHTMLString = (parser) ->
  child = @firstChild
  text = ''
  while child
    if child.toHTMLString?
      text += child.toHTMLString(child)
    else
      text += child.toString()
    child = child.nextSibling

  "<ul>#{text}</ul>"

HTMLLIElement::toHTMLString = (parser) ->
  text = ''
  child = @firstChild
  while child
    if child.toHTMLString?
      text += child.toHTMLString()
    else
      text += child.toString()

    child = child.nextSibling

  "<li>#{text.replace(/^(-\s|\d+\.\s)/i, '')}</li>"

HTMLOListElement::getRange = HTMLUListElement::getRange = (offset, walker) ->
  range = document.createRange()
  if !@firstChild?
    range.setStart(this, 0)
    return

  li = this.firstElementChild

  while walker.nextNode()
    if !li.contains(walker.currentNode)
      newList = walker.currentNode
      while newList? && !(newList instanceof HTMLLIElement)
        newList = newList.parentElement
      li = newList
      offset--

    if walker.currentNode.length < offset
      offset -= walker.currentNode.length
      continue
    range.setStart(walker.currentNode, offset)
    break

  range.collapse(true)
  range
