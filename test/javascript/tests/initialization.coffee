subject = new Test.Subject('initialization')

subject.test "editor is bound to the element", (test) ->
  el = document.querySelector('#Editor')
  blank = new Blank(el)
  test.assert blank.element() == el, "No element was set"

subject.test "editor should be loaded", (test) ->
  el = document.querySelector('#Editor')
  blank = new Blank(el)
  test.assert blank.element().dataset.status == 'loaded', JSON.stringify(blank.element().dataset)

subject.test 'editor should load with default parser', (test) ->
  el = document.querySelector('#Editor')
  blank = new Blank(el)
  test.assert blank.parsers.length == Blank.Parsers().sort().length
