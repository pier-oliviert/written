class Image
  multiline: false

  constructor: (match) ->
    @match = match

  raw: ->
    @match[0]

  text: ->
    @match[2]

  equals: (current, rendered) ->
    figcaption = current.querySelector('figcaption') || {}
    img = current.querySelector('img') || {}

    rendered.querySelector('figcaption').outerHTML == figcaption.outerHTML &&
    rendered.querySelector('img').src == img.src

  markdown: =>
    figure = "<figure><div contenteditable='false'><input type='file' /><img/></div><figcaption /></figure>".toHTML()
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
