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
    captions = [
      current.querySelector('figcaption'),
      rendered.querySelector('figcaption')
    ]

    container = [
      current.querySelector('div[contenteditable="false'),
      rendered.querySelector('div[contenteditable="false')
    ]

    current.nodeName == rendered.nodeName &&
    container[0]? && container[1]? &&
    captions[0]? && captions[1]?

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
    img.src = @match[4]

    if @configure?
      container.dataset.uploadable = true
      container.addEventListener 'click', (e) ->
        figure.querySelector('input').click()

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

Image.rule = /^(!{1}\[([^\]]+)\])(\(([^\s]*)?\))$/i

Image.uploader = (uploader) ->
  Image::configure = uploader.initialize

Written.Parsers.Block.register Image
