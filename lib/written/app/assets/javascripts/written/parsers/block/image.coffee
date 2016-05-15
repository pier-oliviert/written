class Image
  multiline: false

  constructor: (match) ->
    @match = match

  raw: ->
    @match[0]

  text: ->
    @match[2]

  identical: (current, rendered) ->

    sameNode = (current, rendered) ->
      current.nodeName == rendered.nodeName

    sameImages = (current, rendered) ->
      (current? && current.dataset.image) == (rendered? && rendered.dataset.image)

    sameTexts = (current, rendered) ->
      (current? && current.innerHTML) == (rendered? && rendered.innerHTML)


    sameNode(current, rendered) &&
    sameImages(current.querySelector('img'), rendered.querySelector('img')) &&
    sameTexts(current.querySelector('figcaption'), rendered.querySelector('figcaption'))


  markdown: =>
    figure = "<figure is='written-figure'><div contenteditable='false'><div class='progress'></div><input type='file' /><img/></div><figcaption /></figure>".toHTML()
    caption = figure.querySelector('figcaption')
    container = figure.querySelector('div')

    for text in @content
      if text.markdown?
        caption.appendChild(text.markdown())
      else
        caption.appendChild(document.createTextNode(text))

    caption.insertAdjacentHTML('afterbegin', '![')
    caption.insertAdjacentHTML('beforeend', ']')
    caption.insertAdjacentHTML('beforeend', @match[3])

    img = figure.querySelector('img')
    if @match[4]?
      img.src = img.dataset.image = @match[4]
      img.onerror = @placeholder.bind(this, img, true)
    else
      img.src = '/assets/written/placeholder.png'

    if @configure?
      @configure(figure)

    figure

  html: ->
    figure = "<figure><div><img/></div><figcaption /></figure>".toHTML()
    img = figure.querySelector('img')
    caption = figure.querySelector('figcaption')

    img.src = @match[4]

    for text in @content
      if text.html?
        caption.appendChild(text.html())
      else
        caption.appendChild(document.createTextNode(text))

    figure

  placeholder: (img, event, onerror = false) =>
    img.src = '/assets/written/placeholder.png'
    img.onerror = undefined
    if onerror
      img.classList.add 'error'

Image.rule = /^(!{1}\[([^\]]*)\])(\(([^\s]*)?\))$/i

Image.uploader = (uploader) ->
  Image::configure = uploader.initialize


Written.Parsers.register {
  parser: Image
  node: 'figure'
  type: 'block'
  getRange: (node, offset, walker) ->
    range = document.createRange()

    if !node.firstChild?
      range.setStart(this, 0)
    else
      while walker.nextNode()
        if walker.currentNode.length < offset
          offset -= walker.currentNode.length
          continue

        range.setStart(walker.currentNode, offset)
        break

    range.collapse(true)
    range

  toString: (node) ->
    (node.querySelector('figcaption') || node).textContent
}
