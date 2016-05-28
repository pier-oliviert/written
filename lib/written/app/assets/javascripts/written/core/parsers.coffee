class @Written.Parsers
  constructor: (blocks, inlines) ->
    @blocks = blocks || [Written.Parsers.Blocks.default].concat(Written.Parsers.Blocks)
    @inlines = inlines || Written.Parsers.Inlines
    @nodes = {}

    for struct in @blocks.concat(@inlines)
      @nodes[struct.node] = struct

    @blocks.parse = @parseBlocks.bind(this, @blocks)
    @inlines.parse = @parseInlines.bind(this, @inlines)

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

Written.Parsers.Blocks = []
Written.Parsers.Inlines = []

Written.Parsers.Blocks.select = ->
  selected = []
  Array.prototype.slice.call(arguments).map (name) ->
    struct = Written.Parsers.Blocks.find (struct) ->
      struct.node == name
    if struct?
      selected.push struct

  [Written.Parsers.Blocks.default].concat(selected)

Written.Parsers.Inlines.select = ->
  selected = []
  Array.prototype.slice.call(arguments).map (name) ->
    struct = Written.Parsers.Inlines.find (struct) ->
      struct.node == name
    if struct?
      selected.push struct

  selected

Written.Parsers.register = (struct) ->
  type = undefined
  if struct.type == 'block'
    type = Written.Parsers.Blocks
  else if struct.type == 'inline'
    type = Written.Parsers.Inlines
  else
    raise 'error: Written.Parsers can either be "block" or "inline"'
    return

  Written.Parsers.normalize(struct)
  if struct.default
    type.default = struct
  else
    type.push struct


Written.Parsers.normalize = (struct) ->
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

  if Object.prototype.toString == struct.toString
    struct.toString = (node) ->
      node.textContent

class Written.Parsers.Block
  outerText: ->
    throw "method implementation: #{this.name}.outerText() is missing."

  equals: ->
    throw "method implementation: #{this.name}.equals(current, rendered) is missing."

  toEditor: ->
    throw "method implementation: #{this.name}.toEditor() is missing."

  toHTML: ->
    throw "method implementation: #{this.name}.toHTML() is missing."

class Written.Parsers.Inline
  index: ->
    throw "method implementation: #{this.name}.index() is missing."

  length: ->
    throw "method implementation: #{this.name}.length() is missing."

  toEditor: ->
    throw "method implementation: #{this.name}.toEditor() is missing."

  toHTML: ->
    throw "method implementation: #{this.name}.toHTML() is missing."
