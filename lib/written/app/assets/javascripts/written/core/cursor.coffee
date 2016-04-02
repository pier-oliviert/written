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
      @offset += 1

    @currentNode = ->
      node


  offsetAt: (node) ->
    offset = @offset

    element = @element().firstElementChild
    while element && element != node
      offset -= element.textContent.length
      element = element.nextElementSibling

    offset

  focus: (offset, node) =>
    if offset is undefined
      offset = @offset

    if node is undefined
      node = @element().firstElementChild

    while node.nextElementSibling && node.toString().length < offset
      offset -= node.textContent.length + 1
      node = node.nextElementSibling


    range = node.getRange(Math.min(offset, node.textContent.length), document.createTreeWalker(node, NodeFilter.SHOW_TEXT))
    @selection.removeAllRanges()
    @selection.addRange(range)

