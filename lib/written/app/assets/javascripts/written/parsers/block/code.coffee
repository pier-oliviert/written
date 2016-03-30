class Code
  constructor: (match) ->
    @match = match
    @node = "<pre data-status='opened' data-strict='true'><code as='Written.Code'></code></pre>".toHTML()


  valid: ->
    true

  render: (text) =>
    if @match[3]?
      @node.querySelector('code').classList.add("language-#{@match[3]}")

    code = @node.querySelector('code')
    code.appendChild(document.createTextNode(text + "\n"))

    if /(~{3})$/i.test(@text)
      @node.dataset.status = 'closed'

    Prism.highlightElement(code, false)

    @node


Written.Parsers.Block.register Code, /((~{3})([a-z]+)?)(.+)?/i
