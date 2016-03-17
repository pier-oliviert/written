subject = new Test.Subject('parsing')

subject.test 'parsing', (test) ->
  el = document.querySelector('#Editor')
  new Blank(el)
  el.innerHTML = '# Hello World!'
  console.log(el.innerHTML)


