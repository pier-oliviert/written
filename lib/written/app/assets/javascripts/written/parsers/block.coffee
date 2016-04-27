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
    blocks = []
    while (line = lines.pop()) != undefined
      str = line.toString()
      block = blocks[blocks.length - 1]

      if block? && block.multiline && block.accepts(line)
        block.append(line)
        continue

      blocks.push(@find(str))

    blocks

  find: (str) ->
    parser = undefined
    for p in @parsers
      if match = p.rule.exec(str)
        parser = new p(match)
        break

    return parser


@Written.Parsers.Block.parsers = {
  available: []
  default: undefined
}

@Written.Parsers.Block.get = (name) ->
  Written.Parsers.Block.parsers.available.find (p) ->
    p.name.localeCompare(name) == 0

@Written.Parsers.Block.register = (parser, defaultParser = false) ->
  if defaultParser
    Written.Parsers.Block.parsers.default = parser
  else
    Written.Parsers.Block.parsers.available.push parser

