class @Written
  constructor: (el) ->
    el.instance = this
    el.dataset.editor = "written"
    @element = ->
      return el

    text = @toString()
    @element().textContent = ''

    @observer = new Written.Observer(@element(), @changed)
    @initialize = @initialize.bind(this, text)

    @element().addEventListener 'dragover', @over
    @element().addEventListener('drop', @preventDefaults)

    @element().addEventListener('keypress', @linefeed)
    @element().addEventListener('keydown', @undo)
    @element().addEventListener('keydown', @redo)


  preventDefaults: (e) ->
    e.preventDefault()

  initialize: (text, parsers) ->
    @observer.pause()
    if !parsers?
      parsers = Written.Parsers.default()

    @parsers = parsers

    if @element().contentEditable != 'true'
      @element().contentEditable = 'true'

    @parsers.freeze()

    document = new Written.Document(text, @parsers)
    cursor = new Written.Cursor(@element(), window.getSelection())
    document.cursor = cursor

    
    @update(document)
    document.cursor.focus(document.toString().length)

    @history = new Written.History(document)

    @dispatch('written:initialized')
    @observer.resume()


  dispatch: (name, data = {}) =>
    event = new CustomEvent(name, bubbles: true, detail: data)
    @element().dispatchEvent(event)

  changeTo: (text) =>
    @update(new Written.Document(text, @parsers))

  changed: (e) =>
    oldDocument = @history.current
    newDocument = new Written.Document(@toString(), @parsers)
    newDocument.cursor = new Written.Cursor(@element(), window.getSelection())
    if @element().children.length > 0 && oldDocument.toString().localeCompare(newDocument.toString()) == 0
      return

    @update(newDocument)
    @history.push(newDocument)
    @dispatch('written:changed', document: newDocument)

  update: (document) =>
    elements = Array.prototype.slice.call(@element().children)

    for block, index in document.blocks
      node = block.markdown()
      element = elements[index]

      if element?
        if !block.identical(element, node)
          @element().replaceChild(node, element)
          if block.configure?
            block.configure(node, @observer)
      else
        @element().appendChild(node)
        if block.configure?
          block.configure(node, @observer)

    if elements.length > index
      for i in [index..elements.length - 1]
        elements[i].remove()

    document.cursor.focus()


  linefeed: (e) =>
    return unless e.which == 13
    e.preventDefault()
    e.stopPropagation()

    cursor = new Written.Cursor(@element(), window.getSelection())
    @observer.pause =>

      offset = cursor.offset
      lines = @history.current.toString().split('\n').map (line) ->
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

      document = new Written.Document(lines.join('\n'), @parsers)
      document.cursor = cursor
      if cursor.offset < document.toString().length
        cursor.offset += 1

      @update(document)
      @history.push(document)


  undo: (e) =>
    if e.code == 'KeyZ' && e.metaKey && !e.shiftKey
      e.preventDefault()
      e.stopPropagation()
    else
      return

    if document = @history.previous()
      @history.current = document
      @update(@history.current)

  redo: (e) =>
    if e.code == 'KeyZ' && e.metaKey && e.shiftKey
      e.preventDefault()
      e.stopPropagation()
    else
      return

    if document = @history.next()
      @history.current = document
      @update(@history.current)

  toString: =>
    texts = []
    for node in @element().childNodes
      content = node.toString().split('\n')
      texts.push content.join('\n')

    texts.join '\n'


Written.Uploaders = {}
