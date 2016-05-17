class Quote
  multiline: true

  constructor: (match) ->
    @matches = [match]
    @opened = true

  accepts: (text) ->
    @opened = Quote.rule.test(text)

  append: (text) ->
    @matches.push(Quote.rule.exec(text))

  raw: ->
    lines = @matches.map (match) ->
      match[0]

    lines.join('\n')

  text: =>
    lines = @matches.map (match) ->
      match[2]

    lines.join('\n')

  equals: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<blockquote></blockquote>".toHTML()
    for line, index in @content
      p = "<p>".toHTML()
      p.appendChild(document.createTextNode(@matches[index][1]))

      for text in line
        if text.markdown?
          p.appendChild(text.markdown())
        else
          p.appendChild(document.createTextNode(text.toString()))

      if index < @content.length - 1
        p.insertAdjacentHTML('beforeend', '\n')
      node.appendChild(p)

    node

  html: =>
    node = "<blockquote></blockquote>".toHTML()
    for line, index in @content
      p = "<p>".toHTML()

      for text in line
        if text.html?
          p.appendChild(text.html())
        else
          p.appendChild(document.createTextNode(text.toString()))

      if index < @content.length - 1
        p.insertAdjacentHTML('beforeend', '\n')
      node.appendChild(p)

    node


Quote.rule = /^(>\s)(.*)/i

Written.Parsers.register {
  parser: Quote
  node: 'blockquote'
  type: 'block'
  getRange: (node, offset, walker) ->
    range = document.createRange()

    if !node.firstChild?
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

  toString: (node) ->
    node.textContent

}
