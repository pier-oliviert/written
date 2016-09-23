class @Written
  constructor: (el, options = {}) ->
    el.instance = this
    el.dataset.editor = "written"
    @element = ->
      return el

    @element().addEventListener 'dragover', @over
    @element().addEventListener('drop', @preventDefaults)

    @element().addEventListener('keypress', @linefeed)
    @element().addEventListener('keydown', @undo)
    @element().addEventListener('keydown', @redo)
    @element().addEventListener('keydown', @cursor)

    parsers = options.parsers
    if !parsers?
      parsers = new Written.Parsers()

    @parsers = parsers

    text = @toString()
    @element().textContent = ''

    if @element().contentEditable != 'true'
      @element().contentEditable = 'true'

    cursor = new Written.Cursor(@element(), window.getSelection(), @parsers)
    document = new Written.Document(text, @parsers, cursor)

    @render(document, false)

    if options.focus == true
      document.cursor.focus(document.toString().length)

    @history = new Written.History(document)
    @observer = new Written.Observer(@element(), @changed)
    @dispatch('written:initialized')


  preventDefaults: (e) ->
    e.preventDefault()

  dispatch: (name, data = {}) =>
    event = new CustomEvent(name, bubbles: true, detail: data)
    @element().dispatchEvent(event)

  changeTo: (text) =>
    document = new Written.Document(text, @parsers)
    @history.push(document)
    @render(document)

  changed: (e) =>
    oldDocument = @history.current
    cursor = new Written.Cursor(@element(), window.getSelection(), @parsers)
    newDocument = new Written.Document(@toString(), @parsers, cursor)
    if @element().children.length > 0 && oldDocument.toString().localeCompare(newDocument.toString()) == 0
      return

    @history.push(newDocument)
    @render(newDocument)

    @dispatch('written:changed', document: newDocument)

  cursor: =>
    @history.current.cursor = new Written.Cursor(@element(), window.getSelection(), @parsers)

  linefeed: (e) =>
    return unless e.which == 13
    e.preventDefault()
    e.stopPropagation()

    cursor = new Written.Cursor(@element(), window.getSelection(), @parsers)
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

      document = new Written.Document(lines.join('\n'), @parsers, cursor)
      if cursor.offset < document.toString().length
        cursor.offset += 1

      @render(document)
      @history.push(document)


  render: (document, focus = true) =>
    document.applyTo(@element())
    Written.Attachments.attach(this)
    if focus
      document.cursor.focus()

  undo: (e) =>
    if e.code == 'KeyZ' && e.metaKey && !e.shiftKey
      e.preventDefault()
      e.stopPropagation()
    else
      return

    if document = @history.previous()
      @history.current = document
      @render(document)

  redo: (e) =>
    if e.code == 'KeyZ' && e.metaKey && e.shiftKey
      e.preventDefault()
      e.stopPropagation()
    else
      return

    if document = @history.next()
      @history.current = document
      @render(@history.current)

  toString: =>
    texts = []
    for node in @element().childNodes
      content = @parsers.toString(node).split('\n')
      texts.push content.join('\n')

    texts.join '\n'

