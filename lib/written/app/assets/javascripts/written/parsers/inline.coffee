class @Written.Parsers.Inline
  constructor: ->
    @parsers = []

  freeze: ->
    Object.freeze(this)
    Object.freeze(@parsers)

  use: (names) ->
    if typeof names == 'string' && names == 'all'
      @parsers = Written.Parsers.Inline.parsers.available.slice()
      return this

    if typeof names == 'string'
      names = names.split(',').map (name) ->
        name.trim()

    parser = Written.Parsers.Inline.parsers.available.find (obj) ->
      names.contains(obj.parser.name)

    if !parser?
      throw "Couldn't find parser #{name}."
      return this

    @parsers.push parser
    return this

  parse: (block) =>
    walker = document.createTreeWalker(block, NodeFilter.SHOW_TEXT)
    for p in @parsers
      walker.currentNode = walker.root

      while walker.nextNode()
        if match = p.rule.exec(walker.currentNode.textContent)
          parser = new p.parser(match)
          node = parser.render(walker.currentNode)
          node.toHTMLString = parser.toHTMLString.bind(parser, node)


  isLeafNode: (node) ->
    if node.children.length == 0
      return NodeFilter.FILTER_ACCEPT


@Written.Parsers.Inline.get = (name) ->
  parser = Written.Parsers.Inline.parsers.available.find (p) ->
    p.parser.name.localeCompare(name) == 0

  if parser?
    parser.parser

@Written.Parsers.Inline.parsers = {
  available: []
}

@Written.Parsers.Inline.register = (parser, rule) ->
  Written.Parsers.Inline.parsers.available.push {
    rule: rule,
    parser: parser
  }

