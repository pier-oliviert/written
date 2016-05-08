class Written.Uploaders.AWS
  constructor: (settings) ->
    Images.settings = settings

  initialize: (node, observer) =>
    img = node.querySelector('img')
    container = node.querySelector('div')

    node.dataset.uploadable = true
    node.addEventListener 'written:uploader:error', @error, true
    node.addEventListener 'written:uploader:uploading', @progress, true
    node.addEventListener 'written:uploader:completed', @uploaded, true
    node.addEventListener 'change', @input.bind(this, node, observer), true

    container.addEventListener 'click', @open.bind(this, node), true
    image = Images.get(img.dataset.image)
    if image
      image.node = node

  open: (node, e) =>
    node.querySelector('input')?.click()

  uploaded: (e) =>
    caption = e.target.querySelector('figcaption')
    img = e.target.querySelector('img')

    text = caption.childNodes[caption.childNodes.length - 1]
    text.textContent = "(#{e.image.url})"
    img.src = e.image.url
    selection = window.getSelection()
    selection.removeAllRanges()
    range = document.createRange()
    range.setEnd(text, text.textContent.length - 1)
    selection.addRange(range)

  error: (e) =>
    console.log(e)

  input: (node, history, e) =>
    file = e.target.files[0]
    @process(file, node, history)

  process: (file, node) =>
    caption = node.querySelector('figcaption')
    progress = node.querySelector('div.progress')
    filename = [Images.settings.namespace, @hash(file.name)].join('/')

    image = Images.get(filename)
    if !image
      image = Images.upload(filename, file)

    image.node = node
    progress.style.width = image.progress
    node.dataset.status = image.status

    text = caption.childNodes[caption.childNodes.length - 1]
    text.textContent = "(#{filename})"
    selection = window.getSelection()
    selection.removeAllRanges()
    range = document.createRange()
    range.setEnd(text, text.textContent.length - 1)
    selection.addRange(range)

  hash: (filename) ->
    hash = 0
    for i in [0..filename.length - 1]
      hash += filename.charCodeAt(i) ^ hash

    hash.toString('16')

Images = new class
  constructor: ->
    @cache = {}

  failed: (image, event) ->
    image.status = 'failed'
    
    if image.node?
      event = new CustomEvent('written:uploader:error', {bubbles: true})
      event.image = image
      image.node.dispatchEvent(event)

  update: (image, event) ->
    image.status = 'completed'

    if image.node?
      event = new CustomEvent('written:uploader:completed', {bubbles: true})
      event.image = image
      image.node.dispatchEvent(event)

  upload: (name, file) =>
    image = {
      url: "#{@settings.url}/#{name}"
      name: name
      status: 'uploading'
      progress: 0
    }

    form = new FormData()
    form.append('key', name)
    form.append('acl', 'private')
    form.append("AWSAccessKeyId", @settings.accessKey)
    form.append('policy', @settings.policy)
    form.append('signature', @settings.signature)
    form.append('Content-Type', file.type)
    form.append('file', file, name)


    image.xhr = @send(form, @settings.url)
    image.xhr.addEventListener('load', @update.bind(this, image))
    image.xhr.addEventListener('error', @failed.bind(this, image))

    @cache[image.name] = image


  get: (name) ->
    @cache[name]

  send: (form, url) =>
    xhr = new XMLHttpRequest()
    xhr.open('POST', url)
    xhr.send(form)
    xhr


