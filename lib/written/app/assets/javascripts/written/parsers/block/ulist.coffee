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
    node = "<ul is='written-ul'></ul>".toHTML()
    for line, index in @content
      li = "<li is='written-li'>".toHTML()
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

prototype = Object.create(HTMLUListElement.prototype)

prototype.toString = ->
  texts = Array.prototype.slice.call(@children).map (li) ->
    li.toString()
  texts.join("\n")

prototype.getRange = (offset, walker) ->
  range = document.createRange()
  if !@firstChild?
    range.setStart(this, 0)
    return

  li = this.firstElementChild

  while walker.nextNode()
    if !li.contains(walker.currentNode)
      newList = walker.currentNode
      while newList? && !(newList instanceof HTMLLIElement)
        newList = newList.parentElement
      li = newList
      offset--

    if walker.currentNode.length < offset
      offset -= walker.currentNode.length
      continue
    range.setStart(walker.currentNode, offset)
    break

  range.collapse(true)
  range

document.registerElement('written-ul', {
  prototype: prototype
  extends: 'ul'
})
