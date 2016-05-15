class Header
  multiline: false

  constructor: (match) ->
    @match = match

  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  text: ->
    @match[3]

  raw: ->
    @match[0]

  markdown: =>
    node = "<h#{@match[2].length}>".toHTML()

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


[1,2,3,4,5,6].forEach (size) ->
  Written.Parsers.register {
    parser: Header
    node: "h#{size}"
    type: 'block'
    getRange: (node, offset, walker) ->
      range = document.createRange()

      if !node.firstChild?
        range.setStart(node, 0)
      else
        while walker.nextNode()
          if walker.currentNode.length < offset
            offset -= walker.currentNode.length
            continue

          range.setStart(walker.currentNode, offset)
          break

      range.collapse(true)
      range

    toString: (node) ->
      node.textContent
  }
