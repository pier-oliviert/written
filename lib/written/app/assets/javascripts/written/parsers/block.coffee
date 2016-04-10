class @Written.Parsers.Block
  constructor: ->
    @parsers = []

  freeze: ->
    if Written.Parsers.Block.parsers.default?
      @parsers.push Written.Parsers.Block.parsers.default

    Object.freeze(this)
    Object.freeze(@parsers)

  use: (names) ->
    if typeof names == 'string' && names == 'all'
      @parsers = Written.Parsers.Block.parsers.available.slice()
      return this

    if typeof names == 'string'
      names = names.split(',').map (name) ->
        name.trim()

    parser = Written.Parsers.Block.parsers.available.find (obj) ->
      names.contains(obj.parser.name)

    if !parser?
      throw "Couldn't find parser #{names}."
      return this

    @parsers.push(parser)
    return this

  parse: (lines) =>
    elements = []
    currentNode = undefined
    while (line = lines.pop()) != undefined
      str = line.toString()
      if !currentNode
        parser = @find(str)
        currentNode = parser.render(str)
        currentNode.toHTMLString = parser.toHTMLString.bind(parser, currentNode)
        elements.push(currentNode)
        continue

      if currentNode.dataset.status != 'opened'
        parser = @find(str)
        currentNode.nextDocumentNode = parser.render(str)
        currentNode = currentNode.nextDocumentNode
        currentNode.writtenNodeParser = parser
        currentNode.toHTMLString = parser.toHTMLString.bind(parser, currentNode)
        elements.push(currentNode)
        continue
      else if currentNode.writtenNodeParser.valid(str)
        currentNode.writtenNodeParser.render(str)
        continue
      else
        parser = @find(str)
        currentNode.nextDocumentNode = parser.render(str)
        currentNode = currentNode.nextDocumentNode
        currentNode.writtenNodeParser = parser
        currentNode.toHTMLString = parser.toHTMLString.bind(parser, currentNode)
        elements.push(currentNode)

    elements[0]

  find: (str) ->
    parser = undefined
    for p in @parsers
      if match = p.rule.exec(str)
        parser = new p.parser(match)
        break

    return parser


@Written.Parsers.Block.parsers = {
  available: []
  default: undefined
}

@Written.Parsers.Block.get = (name) ->
  parser = Written.Parsers.Block.parsers.available.find (p) ->
    p.parser.name.localeCompare(name) == 0

  if parser?
    parser.parser

@Written.Parsers.Block.register = (parser, rule, defaultParser = false) ->
  if defaultParser
    Written.Parsers.Block.parsers.default = {
      rule: rule,
      parser: parser
    }
  else
    Written.Parsers.Block.parsers.available.push {
      rule: rule,
      parser: parser
    }

