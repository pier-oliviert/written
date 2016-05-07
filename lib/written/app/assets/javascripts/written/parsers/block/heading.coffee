class Header
  multiline: false

  constructor: (match) ->
    @match = match

  processContent: (callback) =>
    if @content?
      throw "Content Error: The content was already processed"
      return

    @content = callback(@match[3])

  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<h#{@match[2].length} is='written-h#{@match[2].length}'>".toHTML()
    for text in @content
      if text.markdown?
        node.appendChild(text.markdown())
      else
        node.appendChild(document.createTextNode(text))

    node.insertAdjacentHTML('afterbegin', @match[1])
    node

  html: =>
    node = "<h#{@match[2].length}>".toHTML()
    for text in @content
      if text.html?
        node.appendChild(text.html())
      else
        node.appendChild(document.createTextNode(text))
    node

Header.rule = /^((#{1,6})\s)(.*)$/i

Written.Parsers.Block.register Header

[1,2,3,4,5,6].forEach (size) ->
  prototype = Object.create(HTMLHeadingElement.prototype)
  prototype.getRange = (offset, walker) ->
    range = document.createRange()

    if !@firstChild?
      range.setStart(this, 0)
    else
      while walker.nextNode()
        if walker.currentNode.length < offset
          offset -= walker.currentNode.length
          continue

        range.setStart(walker.currentNode, offset)
        break

    range.collapse(true)
    range
  prototype.toString = ->
    @textContent

  document.registerElement("written-h#{size}", {
    prototype: prototype
    extends: "h#{size}"
  })
