system = require('system')

class Runner
  tests: ->
    @page.evaluate ->
      Test.retrieveAll()

  start: =>
    success = 0
    failure = 0
    error = 0
    console.log("\n# Running:\n")
    for suite in @tests()
      console.log "#{suite.name}:"
      for test in suite.tests
        info = @page.evaluate @invoke, suite.name, test
        if info.result == 'success'
          success += 1
          console.log("✓ #{test}")
        else
          failure += 1
          console.log("✖ #{test}")
          console.log("  #{info.message}")
    total = success + failure + error
    console.log "\n#{total} runs, #{success} successful, #{failure} failure and #{error} errors"

  invoke: (suite, test) ->
      Test.invoke(suite, test)

returnValue = -1
try
  runner = new Runner()
  runner.page = require('webpage').create()
  runner.page.content = '<body><div id="Editor"></div></body>'
  runner.page.onConsoleMessage = (msg) ->
    console.log(msg)

  if runner.page.injectJs(system.args[1])
    runner.start()

  returnValue = 0
catch e
  console.log e
  console.log e.stack
finally
  phantom.exit(returnValue)
