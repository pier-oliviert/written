class Header
  multiline: false

  constructor: (match) ->
    @match = match

  equals: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  innerText: ->
    @match[3]

  outerText: ->
    @match[0]

  toEditor: =>
    node = Written.toHTML("<h#{@match[2].length}>")

    for text in @content
      if text.toEditor?
        node.appendChild(text.toEditor())
      else
        node.appendChild(document.createTextNode(text))

    node.insertAdjacentHTML('afterbegin', @match[1])
    node

  toHTML: =>
    node = Written.toHTML("<h#{@match[2].length}>")
    for text in @content
      if text.toHTML?
        node.appendChild(text.toHTML())
      else
        node.appendChild(document.createTextNode(text))
    node

[1,2,3,4,5,6].forEach (size) ->
  Written.Parsers.register {
    parser: Header
    node: "h#{size}"
    type: 'block'
    rule: /^((#{1,6})\s)(.*)$/i
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
