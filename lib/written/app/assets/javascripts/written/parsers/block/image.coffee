class Image
  constructor: (match) ->
    @match = match
    @figure = "<figure><div contenteditable='false'><img/></div><figcaption /></figure>".toHTML()

  render: =>
    caption = @figure.querySelector('figcaption')
    caption.appendChild document.createTextNode(@match[1])
    caption.appendChild document.createTextNode(@match[3])
    if @match[4]?
      caption.setAttribute('name', @match[4])

    img = @figure.querySelector('img')
    img.src = @match[4]

    @figure

  toHTMLString: (node) ->
    "<figure><img src='#{this.match[4]}'/><figcaption>#{this.match[2]}</figcaption></figure>"

Written.Parsers.Block.register Image, /^(!{1}\[([^\]]+)\])(\(([^\s]+)?\))$/i
