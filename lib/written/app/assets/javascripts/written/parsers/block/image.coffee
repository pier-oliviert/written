class Image
  multiline: false

  constructor: (match) ->
    @match = match

  processContent: (callback) =>
    if @content?
      throw "Content Error: The content was already processed"
      return

    @content = callback(@match[2])

  identical: (current, rendered) ->

    sameNode = (current, rendered) ->
      current.nodeName == rendered.nodeName

    sameImages = (current, rendered) ->
      (current? && current.dataset.image) == (rendered? && rendered.dataset.image)

    sameTexts = (current, rendered) ->
      (current? && current.textContent) == (rendered? && rendered.textContent)


    sameNode(current, rendered) &&
    sameImages(current.querySelector('img'), rendered.querySelector('img')) &&
    sameTexts(current.querySelector('figcaption'), rendered.querySelector('figcaption'))


  markdown: =>
    figure = "<figure><div contenteditable='false'><div class='progress'></div><input type='file' /><img/></div><figcaption /></figure>".toHTML()
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

Written.Parsers.Block.register Image
