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
    @node.appendChild("<li>#{text}</li>".toHTML())
    @node

Written.Parsers.Block.register UList, UList::rule
