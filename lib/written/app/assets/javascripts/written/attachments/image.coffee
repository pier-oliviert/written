class Image extends Written.Attachments.Base
  constructor: (@node) ->
    @input = document.createElement('input')
    @input.type = 'file'
    @input.addEventListener 'change', @confirm.bind(this, @node)
    @node.querySelector('img').addEventListener 'click', @select.bind(this, @node)

  template: ->
    "<div id='WrittenOverlay' contenteditable=false>
        <div id='WrittenDialog'>
          <header>
            <div class='progress'></div>
            <button data-action='cancel'>Cancel</button>
            <h3>Use this image?</h3>
            <button data-action='upload'>Use</button>
          </header>
          <figure>
            <img />
          </figure>
        </div>
      </div>
      ".toHTML()

  select: (node) =>
    @selection = @getSelection()
    @input.click()

  confirm: (node, event) =>
    @pause()
    @overlay = @template()
    @editor().element().appendChild(@overlay)

    @image(event, @preview.bind(this, @overlay.querySelector('img')))
    @overlay.querySelector('button[data-action=cancel]').addEventListener('click', @cancel)

  preview: (node, event) ->
    node.src = event.target.result
    @overlay.querySelector('button[data-action=upload]').addEventListener('click', @upload)

  image: (event, callback) ->
    @file = event.target.files[0]

    reader = new FileReader()
    reader.addEventListener('load', callback)
    reader.addEventListener('error', @failed)
    reader.readAsDataURL(@file)

  cancel: =>
    @overlay.remove()
    @resume()

  complete: (name) ->
    figcaption = @node.querySelector('figcaption')
    url = figcaption.childNodes[figcaption.childNodes.length - 1]

    @overlay.addEventListener 'transitionend', =>
      @overlay.remove()
      @resume =>
        figcaption.replaceChild(document.createTextNode("(#{window.AWS.bucket}/#{name})"), url)

    @overlay.classList.add('fade')

  failed: (e) =>
    dialog = @overlay.querySelector('#WrittenDialog')
    dialog.classList.add 'failed'
    dialog.querySelector('h3').textContent = "Failed"
    dialog.querySelector('figure').remove()
    dialog.appendChild("
      <section>
        <p>An error occured while trying to process your image.</p>
        <button>Close</button>
      </section>
    ".toHTML())
    dialog.querySelector('button').addEventListener('click', @cancel)

  upload: (e) =>
    @overlay.querySelector('h3').textContent = "Uploading"
    Array.prototype.slice.call(@overlay.querySelectorAll('button')).forEach (button) ->
      button.remove()

    name = @name(@file.name)

    form = new FormData()
    form.append('key', name)
    form.append('acl', 'private')
    form.append("AWSAccessKeyId", window.AWS.accessKey)
    form.append('policy', window.AWS.policy)
    form.append('signature', window.AWS.signature)
    form.append('Content-Type', @file.type)
    form.append('file', @file, name)

    xhr = new XMLHttpRequest()
    xhr.addEventListener('load', @complete.bind(this, name))
    xhr.addEventListener('error', @failed)
    xhr.upload.addEventListener('progress', @progress)
    xhr.open('POST', window.AWS.bucket)
    xhr.send(form)
    xhr


  progress: (e) =>
    value = e.loaded / e.total * 100
    @overlay.querySelector('div.progress').style.width = "#{value}%"

  name: (filename) ->
    hash = 0
    for i in [0..filename.length - 1]
      hash += filename.charCodeAt(i) ^ hash

    hash.toString('16')


Written.Attachments.bind 'figure', Image
