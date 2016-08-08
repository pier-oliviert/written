RULE = /^(>\s)(.*)/i
class Quote extends Written.Parsers.Block
  multiline: true

  constructor: (match) ->
    @matches = [match]
    @opened = true

  accepts: (text) ->
    @opened = RULE.test(text)

  append: (text) ->
    @matches.push(RULE.exec(text))

  outerText: ->
    lines = @matches.map (match) ->
      match[0]

    lines.join('\n')

  innerText: =>
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

      node.appendChild(p)

    node


Written.Parsers.register {
  parser: Quote
  name: 'quote'
  nodes: ['blockquote']
  type: 'block'
  rule: RULE
}
