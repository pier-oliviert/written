class Written.Cursor
  constructor: (element, selection) ->
    @element = ->
      element
    @selection = selection
    children = Array.prototype.slice.call(@element().children, 0)
    @offset = selection.focusOffset

    node = selection.focusNode

    while node && !children.includes(node)
      parent = node.parentElement

      if parent
        for child in (parent.childNodes || [])
          if child == node
            break
          else
            @offset += child.textContent.length

      node = parent


    for child in @element().children
      if child == node
        break
      @offset += child.textContent.length

    @currentNode = ->
      node


  offsetAt: (node) ->
    offset = @offset

    element = @element().firstElementChild
    while element && element != node
      offset -= Math.max(element.textContent.length, 1)
      element = element.nextElementSibling

    offset

  focus: (offset, node) =>
    if offset is undefined
      offset = @offset

    if node is undefined
      node = @element().firstElementChild

    while node && Math.max(node.textContent.length, 1) < offset
      offset -= Math.max(node.textContent.length, 1)
      node = node.nextElementSibling


    range = node.getRange(offset, document.createTreeWalker(node, NodeFilter.SHOW_TEXT))
    @selection.removeAllRanges()
    @selection.addRange(range)

