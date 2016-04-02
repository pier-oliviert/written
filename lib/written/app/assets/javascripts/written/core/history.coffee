Written.History = class History
  constructor: (document) ->
    @current = document

  push: (document) =>
    previousDocument = @current
    @current = document
    previousDocument.nextDocument = document
    document.previousDocument = previousDocument

    @limit()

  previous: =>
    @current.previousDocument

  next: =>
    @current.nextDocument

  limit: =>
    document = @current
    for i in [0...1000]
      if document.previousDocument?
        document = document.previousDocument
      else
        break

    document.previousDocument = undefined


