class Written.Cursor
  constructor: (element, selection, parsers) ->
    @element = ->
      element
    @selection = selection
    @parsers = parsers
    children = Array.prototype.slice.call(@element().children, 0)
    @offset = selection.focusOffset

    node = selection.focusNode

    while node && !children.includes(node)
      parent = node.parentElement

      if parent
        child = node.previousSibling

        while child
          @offset += @parsers.toString(child).length
          child = child.previousSibling

        if node instanceof HTMLLIElement
          this.offset += Array.prototype.indexOf.call(parent.children, node)

      node = parent


    for child in @element().children
      if child == node
        break
      @offset += @parsers.toString(child).length
      @offset += 1

    @currentNode = ->
      node


  offsetAt: (node) ->
    offset = @offset

    element = @element().firstElementChild
    while element && element != node
      offset -= @parsers.toString(element).length
      element = element.nextElementSibling

    offset

  focus: (offset, node) =>
    if offset is undefined
      offset = @offset
    else
      @offset = offset

    if node is undefined
      node = @element().firstElementChild

    while node.nextElementSibling && @parsers.toString(node).length < offset
      offset -= @parsers.toString(node).length + 1
      node = node.nextElementSibling


    range = @parsers.getRange(node, Math.min(offset, @parsers.toString(node).length), document.createTreeWalker(node, NodeFilter.SHOW_TEXT))

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

