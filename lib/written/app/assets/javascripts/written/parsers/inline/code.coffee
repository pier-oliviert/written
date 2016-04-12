class Code
  constructor: (match) ->
    @match = match
    @node = "<code></code>".toHTML()

  render: (text) =>
    if @match[3]?
      @node.classList.add("language-#{@match[3]}")

    code = text.splitText(text.textContent.indexOf(@match[0]))
    code.splitText(@match[0].length)
    @node.appendChild(document.createTextNode(@match[0]))
    text.parentElement.replaceChild(@node, code)

    if Code.parseSyntax?
      Code.parseSyntax(@node)

    @node

  toHTMLString: (node) =>
    code = node.toString().split('\n').slice(1, -1).join('\n')
    "<code class='#{node.classList.toString().trim()}'>#{code}</code>"

Written.Parsers.Inline.register Code, /((~{3})([a-z]+)?)\s(.+)?(~{3})/gi

