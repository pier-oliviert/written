@Written.Parsers = new class
  constructor: ->
    @blocks = []
    @inlines = []
    @nodes = {}

    @blocks.parse = @parseBlocks.bind(this, @blocks)
    @inlines.parse = @parseInlines.bind(this, @inlines)

  register: (struct) ->
    type = undefined
    if struct.type == 'block'
      type = @blocks
    else if struct.type == 'inline'
      type = @inlines
    else
      raise 'error: Written.Parsers can either be "block" or "inline"'
      return

    if struct.default
      type.default = struct.parser
    else
      type.push struct.parser

    @nodes[struct.node] = struct

  parse: (parsers, text) ->
    parsers.parse(text)

  parseBlocks: (parsers, text) ->
    parsers = [parsers.default].concat(parsers).reverse()
    blocks = []
    lines = text.split('\n').reverse()
    while (line = lines.pop()) != undefined
      str = line
      block = blocks[blocks.length - 1]

      if block? && block.multiline && block.accepts(line)
        block.append(line)
        continue

      blocks.push(@find(parsers, str))

    blocks

  parseInlines: (parsers, text) ->
    buffer = ''
    content = []
    matches = []
    index = 0

    for p in parsers
      p.rule.lastIndex = 0

      while match = p.rule.exec(text)
        parser = new p(match)
        matches[parser.index()] = parser

    while text[index]?
      if parser = matches[index]
        content.push buffer.slice(0)
        content.push parser
        buffer = ''
        index += parser.length()
      else
        buffer += text[index]
        index += 1

    if buffer.length > 0
      content.push buffer

    content

  find: (parsers, str) ->
    parser = undefined
    for p in parsers
      if match = p.rule.exec(str)
        parser = new p(match)
        break

    return parser

  get: (name) ->
    @nodes[name]

  getRange: (node, offset, walker) ->
    @nodes[node.nodeName.toLowerCase()].getRange(node, offset, walker)

  toString: (node) ->
    struct = @nodes[node.nodeName.toLowerCase()]
    if struct?
      struct.toString(node)
    else
      node.textContent

