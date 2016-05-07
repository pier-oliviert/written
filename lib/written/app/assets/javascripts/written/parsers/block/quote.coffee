class Quote
  multiline: true

  constructor: (match) ->
    @matches = [match]
    @opened = true

  accepts: (text) ->
    @opened = Quote.rule.test(text)

  append: (text) ->
    @matches.push(Quote.rule.exec(text))

  processContent: (callback) =>
    if @content?
      throw "Content Error: The content was already processed"
      return

    lines = @matches.map (match) ->
      match[2]
    
    @content = callback(lines)

  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<blockquote is='written-blockquote'></blockquote>".toHTML()
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

Written.Parsers.Block.register Quote

prototype = Object.create(HTMLQuoteElement.prototype)

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

document.registerElement('written-blockquote', {
  prototype: prototype
  extends: 'blockquote'
})
