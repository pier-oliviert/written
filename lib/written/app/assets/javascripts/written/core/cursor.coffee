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
        child = node.previousSibling

        while child
          @offset += Written.Stringify(child).length
          child = child.previousSibling

        if node instanceof HTMLLIElement
          this.offset += Array.prototype.indexOf.call(parent.children, node)

      node = parent


    for child in @element().children
      if child == node
        break
      @offset += Written.Stringify(child).length
      @offset += 1

    @currentNode = ->
      node


  offsetAt: (node) ->
    offset = @offset

    element = @element().firstElementChild
    while element && element != node
      offset -= Written.Stringify(element).length
      element = element.nextElementSibling

    offset

  focus: (offset, node) =>
    if offset is undefined
      offset = @offset
    else
      @offset = offset

    if node is undefined
      node = @element().firstElementChild

    while node.nextElementSibling && Written.Stringify(node).length < offset
      offset -= Written.Stringify(node).length + 1
      node = node.nextElementSibling


    range = node.getRange(Math.min(offset, Written.Stringify(node).length), document.createTreeWalker(node, NodeFilter.SHOW_TEXT))

    if @offsetDiffersBetween(@selection, range)
      @selection.removeAllRanges()
      @selection.addRange(range)
      if !@inViewport(node)
        node.scrollIntoView()

  offsetDiffersBetween: (selection, range) ->
    selection.focusNode != range.startContainer ||
    selection.focusOffset != range.startOffset

  inViewport: (node) ->
    bounding = node.getBoundingClientRect()

    bounding.top >= 0 &&
    bounding.left >= 0 &&
    bounding.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
    bounding.right <= (window.innerWidth || document.documentElement.clientWidth)

