RULE = /^<.*/i
class HTML extends Written.Parsers.Block
  multiline: false

  constructor: (match) ->
    @matches = [match]
    @content = match[0]

  accepts: (text) ->
    @opened = RULE.test(text)

  append: (text) ->
    @content += text

  outerText: ->
    @content

  equals: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  toEditor: =>
    node = Written.toHTML("<div></div>")
    node.appendChild(document.createTextNode(@content))
    node

  toHTML: =>
    Written.toHTML(@content)

Written.Parsers.register {
  parser: HTML
  name: 'html'
  nodes: ['div']
  type: 'block'
  rule: RULE
  toString: (node) ->
    node.textContent
}
