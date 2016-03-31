Written.Parsers = {
  freeze: ->
    Written.Parsers.Block.freeze()
    Written.Parsers.Inline.freeze()
}

Written.Parsers.Block = new class
  constructor: ->
    @parsers = []

  freeze: ->
    @parsers.push this.defaultParser

    Object.freeze(this)
    Object.freeze(@parsers)


  register: (parser, rule, defaultParser = false) ->
    if defaultParser
      this.defaultParser = {
        rule: rule,
        parser: parser
      }
    else
      @parsers.push {
        rule: rule,
        parser: parser
      }

  parse: (lines) =>
    elements = []
    currentNode = undefined
    while (line = lines.pop()) != undefined
      str = line.toString()
      if !currentNode
        parser = @find(str)
        currentNode = parser.render(str)
        elements.push(currentNode)
        continue

      if currentNode.dataset.status != 'opened'
        parser = @find(str)
        currentNode.nextDocumentNode = parser.render(str)
        currentNode = currentNode.nextDocumentNode
        currentNode.writtenNodeParser = parser
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
        elements.push(currentNode)

    elements[0]

  find: (str) ->
    parser = undefined
    for p in @parsers
      if match = p.rule.exec(str)
        parser = new p.parser(match)
        break

    return parser


Written.Parsers.Inline = new class
  constructor: ->
    @parsers = []

  freeze: ->
    Object.freeze(this)
    Object.freeze(@parsers)


  register: (parser, rule) ->
    @parsers.push {
      rule: rule,
      parser: parser
    }

  parse: (block) =>
    walker = document.createTreeWalker(block, NodeFilter.SHOW_TEXT)
    for p in @parsers
      walker.currentNode = walker.root

      while walker.nextNode()
        if match = p.rule.exec(walker.currentNode.textContent)
          new p.parser(match).render(walker.currentNode)


  isLeafNode: (node) ->
    if node.children.length == 0
      return NodeFilter.FILTER_ACCEPT

