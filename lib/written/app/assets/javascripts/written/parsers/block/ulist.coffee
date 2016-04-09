class UList
  rule: /^(-\s)(.+)/i
  constructor: (match) ->
    @match = match
    @node = "<ul data-status='opened'></ul>".toHTML()

  valid: (text) ->
    valid = UList::rule.test(text)
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

      "<li>#{text.replace(/^-\s/i, '')}</li>"

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

    "<ul>#{text}</ul>"

Written.Parsers.Block.register UList, UList::rule
