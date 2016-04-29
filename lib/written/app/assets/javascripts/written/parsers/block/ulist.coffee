class UList
  multiline: true

  constructor: (match) ->
    @matches = [match]

  accepts: (text) ->
    @opened = UList.rule.test(text)

    @opened

  append: (text) ->
    @matches.push(UList.rule.exec(text))

  processContent: (callback) =>
    if @content?
      throw "Content Error: The content was already processed"
      return

    lines = @matches.map (match) ->
      match[2]
    
    @content = callback(lines)

  identical: (current, rendered) ->
    current.outerHTML == rendered.outerHTML

  markdown: =>
    node = "<ul></ul>".toHTML()
    for line, index in @content
      li = "<li>".toHTML()
      li.appendChild(document.createTextNode(@matches[index][1]))

      for text in line
        if text.markdown?
          li.appendChild(text.markdown())
        else
          li.appendChild(document.createTextNode(text.toString()))

      node.appendChild(li)

    node

  html: =>
    node = "<ul></ul>".toHTML()
    for line, index in @content
      li = "<li>".toHTML()

      for text in line
        if text.html?
          li.appendChild(text.html())
        else
          li.appendChild(document.createTextNode(text.toString()))

      node.appendChild(li)

    node

UList.rule = /^(-\s)(.*)/i

Written.Parsers.Block.register UList
