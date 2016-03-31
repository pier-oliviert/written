class @Written
  constructor: (el) ->
    el.instance = this
    el.dataset.editor = "written"
    @element = ->
      return el

    @observer = new Written.Observer(@element(), @changed)
    @observer.pause @initialize

    @element().addEventListener('keypress', @linefeed)

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
    if oldDocument.toString().localeCompare(newDocument.toString()) == 0
      return

    @observer.pause @update.bind(this, newDocument)
    @history.push(newDocument)

  update: (document) =>
    cursor = new Written.Cursor(@element(), window.getSelection())

    node = document.head
    current = @element().firstElementChild

    while node 
      if node.innerHTML.localeCompare(current.innerHTML) != 0
        clonedNodeDocument = node.cloneNode(true)
        @element().replaceChild(clonedNodeDocument, current)
        current = clonedNodeDocument

      node = node.nextDocumentNode
      current = current.nextElementSibling

    cursor.focus()


  linefeed: (e) =>
    return unless e.which == 13

    @observer.pause =>
      e.preventDefault()
      e.stopPropagation()

      cursor = new Written.Cursor(@element(), window.getSelection())
      cursor.currentNode.insertAdjacentHTML('afterend', "<p></p>")
      cursor.focus(0, cursor.currentNode.nextElementSibling)



  toString: =>
    texts = []
    for node in @element().childNodes
      content = node.toString().split('\n').map (line) ->
        line.trimLeft()

      texts.push content.join('\n')

    texts.join '\n'


