@Written.Attachments = new class Attachments
  constructor: ->
    @attachments = {}
    @nodes = []
    
  bind: (nodeName, attachment) ->
    @attachments[nodeName] = attachment

  attach: (editor) =>
    for name, attachment of @attachments
      nodes = editor.element().querySelectorAll(name)
      for node in nodes
        if @nodes.includes(node)
          continue
        
        attachment = new attachment(node)
        attachment.editor(editor)
        @nodes.push(node)
      
      
@Written.Attachments.Base = class Attachment
  editor: (editor) ->
    @editor = ->
      editor

    @editor()

  pause: =>
    @editor().observer.pause()

  resume: (callback) =>
    @editor().observer.resume()
    if callback?
      callback()
    
  getSelection: ->
    window.getSelection()
