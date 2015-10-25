class @Blank.Mutations
  constructor: (mutations, editor) ->
    @removed = []
    @appended = []
    @updated = []

    for mutation in mutations
      @setTarget(mutation.target, editor)
      if mutation.addedNodes.length > 0
        @appended.push mutation.target
      else if mutation.type == 'characterData'
        @updated.push mutation.target
      else
        @removed.push mutation.target

  setTarget: (target, editor) ->
    return unless target.parentElement? && target != editor
    if @target? && @target.compareDocumentPosition(target) & Node.DOCUMENT_POSITION_FOLLOWING
      @target = target
    else
      @target = target

  status: =>
    if @appended.length > 0
      "appended"
    else if @updated.length > 0
      'updated'
    else if @removed.length > 0
      'removed'
    else
      'none'


