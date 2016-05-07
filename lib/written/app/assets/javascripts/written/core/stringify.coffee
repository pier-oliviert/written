ElementString = (node) ->
  node.textContent

CustomElementString = (node) ->
  node.toString()

TextNodeString = (node) ->
  node.textContent

Written.Stringify = (node) ->
  switch
    when node.nodeType == Node.TEXT_NODE then TextNodeString(node)
    when node.hasAttribute('is') then CustomElementString(node)
    else ElementString(node)
  
