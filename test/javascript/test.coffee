#= require blank
#= require_self
#= require_tree ./assertions
#= require_tree ./tests

class @AssertionException
  constructor: (@message) ->
    @name = 'AssertionException'

class @Test
  constructor: (@name, @cb) ->
    @assertions = 0
  execute: ->
    try
      @cb.call(this, Test.assertions.asserts(this))
      {
        result: 'success',
        assertions: @assertions
      }
    catch error
      if error.name == 'AssertionException'
        {
          result: 'failure',
          assertions: @assertions,
          message: error.message
        }
      else
        {
          result: 'error',
          assertions: @assertions,
          message: error.message
        }

Test.Subject = class
  constructor: (@name) ->
    Test.Subject.instances.push this
    @tests = []

  test: (name, cb) ->
    @tests.push(new Test(name, cb))

Test.Subject.instances = []

class Assertions
  constructor: ->
    @assertions = []
  register: (name, fn) ->
    @assertions.push {name: name, fn: fn}
  asserts: (test) =>
    methods = {}
    @assertions.forEach (obj) ->
      methods[obj.name] = ->
        obj.fn.apply(test, arguments)
        test.assertions += 1
    methods

Test.assertions = new Assertions()

Test.retrieveAll = ->
  subjects = []
  for subject in Test.Subject.instances
    names = []

    for test in subject.tests
      names.push test.name

    subjects.push {
      name: subject.name,
      tests: names
    }

  subjects

Test.invoke = (subjectName, testName) ->
  subject = undefined
  for s in Test.Subject.instances
    if s.name == subjectName
      subject = s

  if !subject?
    return {
      assertions: 0,
      errors: [
        "Couldn't find subject named #{subjectName}"
      ]
    }

  test = undefined
  for t in subject.tests
    if t.name == testName
      test = t

  if !test?
    return {
      assertions: 0,
      errors: [
        "Couldn't find test named #{testName}"
      ]
    }

  test.execute()
