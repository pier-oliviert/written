class @Written
  constructor: (el) ->
    el.instance = this
    el.dataset.editor = "written"
    @element = ->
      return el

    @observer = new Written.Observer(@element(), @changed)
    @observer.pause @initialize

  initialize: =>
    if @parsers?
      return

    Written.Parsers.freeze()

    @history = new Written.History(new Written.Document(@toString(), Written.Parsers))
    
    node = @history.current().head

    @element().textContent = ''

    while node
      @element().appendChild(node.cloneNode(true))
      node = node.nextDocumentNode


  changed: (e) =>
    oldDocument = @history.current()
    newDocument = new Written.Document(@toString())
    if oldDocument.toString().localeCompare(newDocument.toString()) == 0
      return

    @observer.pause @update.bind(this, oldDocument, newDocument)
    @history.push(newDocument)

  update: (oldDocument, newDocument) =>
    cursor = new Written.Cursor(@element(), window.getSelection())
    node = @element().firstElementChild

    while node
      nextNode = node.nextElementSibling
      if oldDocument.texts.indexOf(node.toString()) == -1
        node.remove()
      node = nextNode


    node = newDocument.head
    index = 0

    while node 
      if oldDocument.texts.indexOf(node.toString()) == -1
        @element().insertBefore(node, @element().children[index])

      index += 1
      node = node.nextDocumentNode

    cursor.focus()



  toString: =>
    texts = []
    for node in @element().childNodes
      content = node.toString().split('\n').map (line) ->
        line.trim()

      texts.push content.join('\n')

    texts.join '\n'


