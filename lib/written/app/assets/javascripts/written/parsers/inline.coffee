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

    parser = Written.Parsers.Inline.parsers.available.find (parser) ->
      names.contains(parser.name)

    if !parser?
      throw "Couldn't find parser #{name}."
      return this

    @parsers.push parser
    return this

  parse: (text) =>
    if Array.isArray(text)
      return text.map(@parse)

    parsers = []
    for p in @parsers
      if text.length is 0
        break

      p.rule.lastIndex = 0

      while match = p.rule.exec(text)
        parser = new p(match)
        parsers[parser.index()] = parser

    @merge(parsers, text)


  merge: (parsers, text) ->
    content = []
    buffer = ''
    index = 0

    while text[index]?
      if parser = parsers[index]
        content.push buffer.slice(0)
        content.push parser
        buffer = ''
        index += parser.length()
      else
        buffer += text[index]
        index += 1

    if buffer.length > 0
      content.push buffer

    content

  splice: (text, parser) ->
    start = parser.index()
    end = start + parser.length()
    text.slice(0, start) + text.slice(end, text.length)


@Written.Parsers.Inline.get = (name) ->
  Written.Parsers.Inline.parsers.available.find (p) ->
    p.parserName.localeCompare(name) == 0

@Written.Parsers.Inline.parsers = {
  available: []
}

@Written.Parsers.Inline.register = (parser) ->
  Written.Parsers.Inline.parsers.available.push(parser)
