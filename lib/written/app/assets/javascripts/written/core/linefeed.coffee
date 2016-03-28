class @Blank.LineFeed
  constructor: (@fragment) ->

  injectAt: (offset) ->
    node = @fragment.firstChild
    while node && offset > 0
      length = node.textContent.length
      if offset > length
        offset -= length  + 1
        node = node.nextSibling
      else
        break

    if !node?
      @append(@fragment.lastChild)
    else
      @insert(node, offset)

  append: (lastChild) ->
    node = lastChild.cloneNode(true)
    node.textContent = ''
    @fragment.appendChild(node)

  insert: (root, offset) ->
    node = root.cloneNode(true)

    root.textContent = root.textContent.substr(0, offset)
    node.textContent = node.textContent.substr(offset)

    if root.nextSibling?
      @fragment.insertBefore(node, root.nextSibling)
    else
      @fragment.appendChild(node)



