HTMLAnchorElement::toString = ->
  @textContent

HTMLAnchorElement::toHTMLString = (parser) ->
  "<a href='#{@href}'>#{parser.match[2]}</a>"
