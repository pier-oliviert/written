Written.History = class History
  constructor: (currentDocument) ->
    @documents = [currentDocument]

  current: =>
    @documents[0]

  push: (document) =>
    @documents.splice(0, 0, document)
    while @documents.length > 50
      @documents.pop()

  pop: =>
    documents.pop()


