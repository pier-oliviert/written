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

    @normalize(struct)
    if struct.default
      type.default = struct
    else
      type.push struct

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

    for struct in parsers
      struct.rule.lastIndex = 0

      while match = struct.rule.exec(text)
        parser = new struct.parser(match)
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

  normalize: (struct) ->
    if !struct.getRange
      struct.getRange = (node, offset, walker) ->
        range = document.createRange()

        if !node.firstChild?
          range.setStart(node, 0)
        else
          while walker.nextNode()
            if walker.currentNode.length < offset
              offset -= walker.currentNode.length
              continue

            range.setStart(walker.currentNode, offset)
            break

        range.collapse(true)
        range

    if !struct.toString?
      struct.toString = (node) ->
        node.textContent

  find: (parsers, str) ->
    parser = undefined
    for struct in parsers
      if match = struct.rule.exec(str)
        parser = new struct.parser(match)
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

