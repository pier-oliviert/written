class OList
  rule: /^(\d\.\s)(.+)/i
  constructor: (match) ->
    @match = match
    @node = "<ol data-status='opened'></ol>".toHTML()

  valid: (text) ->
    valid = OList::rule.test(text)
    if !valid
      @node.dataset.status = false
    valid

  render: (text) =>
    @node.appendChild("<li>#{text}</li>".toHTML())
    @node

Written.Parsers.Block.register OList, OList::rule

