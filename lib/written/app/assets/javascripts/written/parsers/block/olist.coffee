class OList
  multiline: true

  constructor: (match) ->
    @matches = [match]
    @opened = true

  accepts: (text) ->
    @opened = OList.rule.test(text)

    @opened

  append: (text) ->
    @matches.push(OList.rule.exec(text))

  equals: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  raw: ->
    texts = @matches.map (match) ->
      match[0]

    texts.join('\n')

  text: ->
    texts = @matches.map (match) ->
      match[2]

    texts.join('\n')

  markdown: =>
    node = "<ol></ol>".toHTML()
    for line, index in @content
      li = "<li>".toHTML()
      li.appendChild(document.createTextNode(@matches[index][1]))

      for text in line
        if text.markdown?
          li.appendChild(text.markdown())
        else
          li.appendChild(document.createTextNode(text.toString()))

      node.appendChild(li)

    node

  html: =>
    node = "<ol></ol>".toHTML()
    for line, index in @content
      li = "<li>".toHTML()

      for text in line
        if text.html?
          li.appendChild(text.html())
        else
          li.appendChild(document.createTextNode(text.toString()))

      node.appendChild(li)

    node


OList.rule = /^(\d+\.\s)(.*)/i

Written.Parsers.register {
  parser: OList
  node: 'ol'
  type: 'block'
  getRange: (node, offset, walker) ->
    range = document.createRange()
    if !node.firstChild?
      range.setStart(node, 0)
      return

    li = node.firstElementChild

    while walker.nextNode()
      if !li.contains(walker.currentNode)
        newList = walker.currentNode
        while newList? && !(newList instanceof HTMLLIElement)
          newList = newList.parentElement
        li = newList
        offset--

      if walker.currentNode.length < offset
        offset -= walker.currentNode.length
        continue
      range.setStart(walker.currentNode, offset)
      break

    range.collapse(true)
    range

  toString: (node) ->
    texts = Array.prototype.slice.call(node.children).map (li) ->
      li.textContent
    texts.join("\n")
}
