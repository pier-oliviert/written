HTMLPreElement::toString = ->
  if @textContent[@textContent.length - 1] == '\n'
    @textContent.substr(0, @textContent.length - 1)
  else
    @textContent


