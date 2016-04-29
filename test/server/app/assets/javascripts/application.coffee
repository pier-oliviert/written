#= require 'written'
#= require 'secrets'
#= require 'prism'

code = Written.Parsers.Block.get('Code').prototype
code.highlight = (element) ->
  Prism.highlightElement(element, false)

code = Written.Parsers.Inline.get('Code').prototype
code.highlight = (element) ->
  Prism.highlightElement(element, false)


if window.AWS?
  uploader = new Written.Uploaders.AWS({
    bucket: AWS.bucket,
    accessKey: AWS.accessKey,
    policy: AWS.policy,
    signature: AWS.signature
  })

  Written.Parsers.Block.get('Image').uploader(uploader)

editor = new Written(document.getElementById('Editor'))
editor.initialize()

