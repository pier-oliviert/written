HTMLHeadingElement::toString = ->
  @textContent

HTMLHeadingElement::toHTMLString = (parser) ->
  size = parser.match[1].length
  text = ''
  child = @firstChild
  while child
    if child.toHTMLString
      text += child.toHTMLString()
    else
      text += child.toString()
    child = child.nextSibling

  "<h#{size}>#{text.slice(parser.match[0].length)}</h#{size}>"


