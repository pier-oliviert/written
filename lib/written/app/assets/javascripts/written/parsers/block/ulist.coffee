RULE = /^(-\s)(.*)/i

class UList extends Written.Parsers.Block
  multiline: true

  constructor: (match) ->
    @matches = [match]

  accepts: (text) ->
    @opened = RULE.test(text)

    @opened

  outerText: ->
    texts = @matches.map (match) ->
      match[0]

    texts.join('\n')

  innerText: ->
    texts = @matches.map (match) ->
      match[2]

    texts.join('\n')

  append: (text) ->
    @matches.push(RULE.exec(text))

  equals: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  toEditor: =>
    node = Written.toHTML("<ul></ul>")
    for line, index in @content
      li = Written.toHTML("<li>")
      li.appendChild(document.createTextNode(@matches[index][1]))

      for text in line
        if text.toEditor?
          li.appendChild(text.toEditor())
        else
          li.appendChild(document.createTextNode(text.toString()))

      node.appendChild(li)

    node

  toHTML: =>
    node = Written.toHTML("<ul></ul>")
    for line, index in @content
      li = Written.toHTML("<li>")

      for text in line
        if text.toHTML?
          li.appendChild(text.toHTML())
        else
          li.appendChild(document.createTextNode(text.toString()))

      node.appendChild(li)

    node

Written.Parsers.register {
  parser: UList
  node: 'ul'
  type: 'block'
  rule: RULE
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
