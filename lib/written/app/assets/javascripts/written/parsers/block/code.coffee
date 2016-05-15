class Code
  multiline: true

  constructor: (match) ->
    @matches = [match]
    @content = "\n"
    @opened = true


  raw: ->
    texts = @matches.map (m) ->
      m[0]
    texts.join('\n')

  accepts: (text) ->
    @opened

  append: (text) ->
    match = /(~{3})$/i.exec(text)
    if match?
      @matches.push(match)
      @opened = false
    else
      @matches.push([text])
      @content += text + "\n"

    @content


  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<pre><code></code></pre>".toHTML()
    code = node.querySelector('code')

    if @matches[0][3]?
      code.classList.add("language-#{@matches[0][3]}")

    code.appendChild(document.createTextNode(@content))
    if @highlight?
      @highlight(code)

    code.insertAdjacentHTML('afterbegin', @matches[0][0])
    if !@opened
      code.insertAdjacentHTML('beforeend', @matches[@matches.length - 1][0])

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

Written.Parsers.register {
  parser: Code
  node: 'pre'
  type: 'block'
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
    if node.textContent[node.textContent.length - 1] == '\n'
      node.textContent.substr(0, node.textContent.length - 1)
    else
      node.textContent

  highlightWith: (callback) ->
    Code.prototype.highlight = callback
}
