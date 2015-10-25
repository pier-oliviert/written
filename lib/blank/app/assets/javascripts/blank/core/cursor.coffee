class @Blank.Cursor
  constructor: (offset) ->
    @selection = window.getSelection()
    @origin = @selection.focusNode

    @offset = offset

  focus: (line) ->
    while true
      length = line.toString().length
      if length >= @offset
        break
      @offset -= Math.max(length + 1, 1)

      if line.nextSibling?
        line = line.nextSibling
        continue
      break

    @focus = ->
      line

    @focus()

  update: (walker, force = false) ->
    line = walker.root

    if !force && @selection.focusNode == @origin && line.contains(@origin)
      return

    range = line.getRange(@offset, walker)

    @selection.removeAllRanges()
    @selection.addRange(range)


