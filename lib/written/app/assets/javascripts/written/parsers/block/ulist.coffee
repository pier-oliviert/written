class UList
  multiline: true

  constructor: (match) ->
    @matches = [match]

  accepts: (text) ->
    @opened = UList.rule.test(text)

    @opened

  raw: ->
    texts = @matches.map (match) ->
      match[0]

    texts.join('\n')

  text: ->
    texts = @matches.map (match) ->
      match[2]

    texts.join('\n')

  append: (text) ->
    @matches.push(UList.rule.exec(text))

  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<ul></ul>".toHTML()
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
    node = "<ul></ul>".toHTML()
    for line, index in @content
      li = "<li>".toHTML()

      for text in line
        if text.html?
          li.appendChild(text.html())
        else
          li.appendChild(document.createTextNode(text.toString()))

      node.appendChild(li)

    node

UList.rule = /^(-\s)(.*)/i

Written.Parsers.register {
  parser: UList
  node: 'ul'
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
