class Written.Linefeed
  constructor: (element, observer) ->
    @element = ->
      element

    @observer = ->
      observer

  document: =>

    document = undefined

    @cursor = ->
      new Written.Cursor(@element(), window.getSelection())

    @observer().pause =>

      cursor = @cursor()

      node = cursor.currentNode()

      if node.dataset.multiline == "true"
        text = node.textContent
        offset = cursor.offsetAt(node)
        node.textContent = [text.slice(0, offset), '\n', text.slice(offset)].join('')
      else
        node.insertAdjacentHTML('afterend', "<p></p>")
        if node.textContent.length == 0
          cursor.offset += 1

      cursor.offset += 1

      doc = new Written.Document(@element().toString())
    document

