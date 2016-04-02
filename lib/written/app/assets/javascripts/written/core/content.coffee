class @Written
  constructor: (el) ->
    el.instance = this
    el.dataset.editor = "written"
    @element = ->
      return el

    @observer = new Written.Observer(@element(), @changed)
    @observer.pause @initialize

    @element().addEventListener('keypress', @linefeed)

    cursor = new Written.Cursor(@element(), window.getSelection())
    cursor.focus(0, @element())

  initialize: =>
    if @parsers?
      return

    Written.Parsers.freeze()

    @history = new Written.History(new Written.Document(@toString(), Written.Parsers))
    
    node = @history.current().head

    @element().textContent = ''

    while node
      @element().appendChild(node)
      node = node.nextDocumentNode


  changed: (e) =>
    oldDocument = @history.current()
    newDocument = new Written.Document(@toString())
    if @element().children.length > 0 && oldDocument.toString().localeCompare(newDocument.toString()) == 0
      return

    @update(newDocument, new Written.Cursor(@element(), window.getSelection()))
    @history.push(newDocument)

  update: (document, cursor) =>
    node = document.head
    current = @element().firstElementChild

    while node 
      if !current?
        @element().appendChild(node.cloneNode(true))
      else if node.outerHTML.localeCompare(current.outerHTML) != 0
        clonedNodeDocument = node.cloneNode(true)
        @element().replaceChild(clonedNodeDocument, current)
        current = clonedNodeDocument

      node = node.nextDocumentNode
      if current?
        current = current.nextElementSibling

    if current?
      node = current.nextElementSibling
      while node
        nextNode = node.nextElementSibling
        node.remove()
        node = nextNode

    cursor.focus()


  linefeed: (e) =>
    return unless e.which == 13
    e.preventDefault()
    e.stopPropagation()

    cursor = new Written.Cursor(@element(), window.getSelection())
    @observer.pause =>

      offset = cursor.offset
      lines = @history.current().toString().split('\n').map (line) ->
        if line.length < offset
          offset -= line.length
        else if offset >= 0
          line = [line.slice(0, offset), '\n', line.slice(offset)].join('')
          offset -= line.length
        offset -= 1
        line

      if offset == 0
        lines.push('')
        cursor.offset += 1

      document = new Written.Document(lines.join('\n'))
      if cursor.offset < document.toString().length
        cursor.offset += 1

      @update(document, cursor)
      @history.push(document)


  toString: =>
    texts = []
    for node in @element().childNodes
      content = node.toString().split('\n')
      texts.push content.join('\n')

    texts.join '\n'


