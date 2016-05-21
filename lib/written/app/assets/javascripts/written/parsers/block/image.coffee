class Image
  multiline: false

  constructor: (match) ->
    @match = match

  outerText: ->
    @match[0]

  innerText: ->
    @match[2]

  equals: (current, rendered) ->
    figcaption = current.querySelector('figcaption') || {}
    img = current.querySelector('img') || {}

    rendered.querySelector('figcaption').outerHTML == figcaption.outerHTML &&
    rendered.querySelector('img').src == img.src

  toEditor: =>
    figure = Written.toHTML("<figure><div contenteditable='false'><img/></div><figcaption /></figure>")
    caption = figure.querySelector('figcaption')
    container = figure.querySelector('div')

    for text in @content
      if text.toEditor?
        caption.appendChild(text.toEditor())
      else
        caption.appendChild(document.createTextNode(text))

    caption.insertAdjacentHTML('afterbegin', '![')
    caption.insertAdjacentHTML('beforeend', ']')
    caption.insertAdjacentHTML('beforeend', @match[3])

    img = figure.querySelector('img')
    if @match[4]?
      img.src = @match[4]
    else
      img.src = '/assets/written/placeholder.png'

    figure

  toHTML: ->
    figure = Written.toHTML("<figure><img/><figcaption /></figure>")
    img = figure.querySelector('img')
    caption = figure.querySelector('figcaption')

    img.src = @match[4]

    for text in @content
      if text.toHTML?
        caption.appendChild(text.toHTML())
      else
        caption.appendChild(document.createTextNode(text))

    figure

  placeholder: (img, event, onerror = false) =>
    img.src = '/assets/written/placeholder.png'
    img.onerror = undefined

Written.Parsers.register {
  parser: Image
  node: 'figure'
  type: 'block'
  rule: /^(!{1}\[([^\]]*)\])(\(([^\s]*)?\))$/i
  toString: (node) ->
    (node.querySelector('figcaption') || node).textContent
}
