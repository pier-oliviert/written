class Code
  @parserName: 'Code'
  multiline: true

  constructor: (match) ->
    @matches = [match]
    @content = "\n"
    @opened = true


  accepts: (text) ->
    @opened

  append: (text) ->
    match = /(~{3})$/i.exec(text)
    if match?
      @matches.push(match)
      @opened = false
    else
      @content += text + "\n"

    @content

  processContent: (callback) =>

  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<pre is='written-pre'><code></code></pre>".toHTML()
    code = node.querySelector('code')

    if @matches[0][3]?
      code.classList.add("language-#{@matches[0][3]}")

    code.appendChild(document.createTextNode(@content))
    if @highlight?
      @highlight(code)

    code.insertAdjacentHTML('afterbegin', @matches[0][0])
    if !@opened
      code.insertAdjacentHTML('beforeend', @matches[1][0])

    node

  html: =>
    node = "<pre><code></code></pre>".toHTML()
    code = node.querySelector('code')

    if @matches[0][3]?
      code.classList.add("language-#{@matches[0][3]}")

    if @matches[0][4]?
      code.insertAdjacentHTML('beforebegin', "<header>#{@matches[0][4]}</header>")

    code.appendChild(document.createTextNode(@content))

    node

Code.rule = /^((~{3})([a-z]+)?)(?:\s(.*))?/i

Written.Parsers.Block.register Code

prototype = Object.create(HTMLPreElement.prototype)

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
  if @textContent[@textContent.length - 1] == '\n'
    @textContent.substr(0, @textContent.length - 1)
  else
    @textContent

document.registerElement('written-pre', {
  prototype: prototype
  extends: 'pre'
})
