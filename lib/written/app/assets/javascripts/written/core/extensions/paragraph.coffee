HTMLParagraphElement::toString = ->
  @textContent

HTMLParagraphElement::toHTMLString = (parser) ->
  text = ''
  child = @firstChild
  while child
    if child.toHTMLString
      text += child.toHTMLString()
    else
      text += child.toString()
    child = child.nextSibling

  "<p>#{text}</p>"

