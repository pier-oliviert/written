RULE = /^(>\s)(.*)/i
class Quote
  multiline: true

  constructor: (match) ->
    @matches = [match]
    @opened = true

  accepts: (text) ->
    @opened = RULE.test(text)

  append: (text) ->
    @matches.push(RULE.exec(text))

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

  toEditor: =>
    node = Written.toHTML("<blockquote></blockquote>")
    for line, index in @content
      p = Written.toHTML("<p>")
      p.appendChild(document.createTextNode(@matches[index][1]))

      for text in line
        if text.toEditor?
          p.appendChild(text.toEditor())
        else
          p.appendChild(document.createTextNode(text.toString()))

      if index < @content.length - 1
        p.insertAdjacentHTML('beforeend', '\n')
      node.appendChild(p)

    node

  toHTML: =>
    node = Written.toHTML("<blockquote></blockquote>")
    for line, index in @content
      p = Written.toHTML("<p>")

      for text in line
        if text.toHTML?
          p.appendChild(text.toHTML())
        else
          p.appendChild(document.createTextNode(text.toString()))

      if index < @content.length - 1
        p.insertAdjacentHTML('beforeend', '\n')
      node.appendChild(p)

    node


Written.Parsers.register {
  parser: Quote
  node: 'blockquote'
  type: 'block'
  rule: RULE
}
