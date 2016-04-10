class OList
  rule: /^(\d\.\s)(.*)/i
  constructor: (match) ->
    @match = match
    @node = "<ol data-status='opened'></ol>".toHTML()

  valid: (text) ->
    valid = OList::rule.test(text)
    if !valid
      @node.dataset.status = false
    valid

  render: (text) =>
    li = "<li>#{text}</li>".toHTML()

    li.toHTMLString = (node) ->
      text = ''
      child = node.firstChild
      while child
        if child.toHTMLString?
          text += child.toHTMLString()
        else
          text += child.toString()

        child = child.nextSibling

      "<li>#{text.replace(/^\d+\.\s/i, '')}</li>"

    @node.appendChild(li)
    @node

  toHTMLString: (node) ->
    child = node.firstChild
    text = ''
    while child
      if child.toHTMLString?
        text += child.toHTMLString(child)
      else
        text += child.toString()
      child = child.nextSibling

    "<ol>#{text}</ol>"

Written.Parsers.Block.register OList, OList::rule

