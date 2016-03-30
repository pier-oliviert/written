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

  focus: (offset, node) =>
    offset ||= @offset
    node ||= @element().firstElementChild

    while node && (node.textContent.length) < offset
      offset -= (node.textContent.length)
      node = node.nextElementSibling


    range = node.getRange(offset, document.createTreeWalker(node, NodeFilter.SHOW_TEXT))
    @selection.removeAllRanges()
    @selection.addRange(range)

