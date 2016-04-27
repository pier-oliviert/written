class Written.Uploaders.AWS
  constructor: (settings) ->
    Images.settings = settings

  initialize: (node, observer) =>
    node.addEventListener 'written:uploader', @progress.bind(this, observer), true
    node.addEventListener 'change', @input.bind(this, node, observer), true
    node.addEventListener 'dragover', @over.bind(this, node), true
    node.addEventListener 'dragleave', @cancel.bind(this, node), true
    node.addEventListener 'drop', @drop.bind(this, node, observer), true

  progress: (observer, e) ->
    img = e.target.querySelector('img')
    caption = e.target.querySelector('figcaption')
    progress = e.target.querySelector('div.progress')
    progress.style.width = "#{e.image.progress}%"
    e.target.dataset.status = e.image.status

    if e.image.status == 'completed'
      text = caption.childNodes[caption.childNodes.length - 1]
      text.textContent = "(#{e.image.url})"
      img.src = e.image.url
      selection = window.getSelection()
      selection.removeAllRanges()
      range = document.createRange()
      range.setEnd(text, text.textContent.length - 1)
      selection.addRange(range)
    else
      img.src = e.image.placeholder

  input: (node, history, e) =>
    file = e.target.files[0]
    @process(file, node, history)

  process: (file, node, history) =>
    caption = node.querySelector('figcaption')
    progress = node.querySelector('div.progress')
    filename = @hash(file.name)

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

  over: (node, e) =>
    e.preventDefault()
    node.classList.add 'dropping'

  cancel: (node, e) =>
    e.preventDefault()
    node.classList.remove 'dropping'

  drop: (node, history, e) =>
    e.preventDefault()
    node.classList.remove 'dropping'
    file = e.dataTransfer.files[0]
    @process(file, node, history)

  hash: (filename) ->
    hash = 0
    for i in [0..filename.length - 1]
      hash += filename.charCodeAt(i) ^ hash

    hash.toString('16')

Images = new class
  constructor: ->
    @cache = {}

  update: (image, event) ->
    image.status = 'completed'

    if image.node?
      event = new CustomEvent('written:uploader', {bubbles: true})
      event.image = image
      image.node.dispatchEvent(event)

  upload: (name, file) =>
    image = {
      url: "#{@settings.bucket}/#{name}"
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


    image.xhr = @send(form, @settings.bucket)
    image.xhr.addEventListener('load', @update.bind(this, image))

    @cache[image.name] = image


  get: (name) ->
    @cache[name]

  send: (form, url) =>
    xhr = new XMLHttpRequest()
    xhr.open('POST', url)
    xhr.send(form)
    xhr


