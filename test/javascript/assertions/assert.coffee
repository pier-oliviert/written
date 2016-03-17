Test.assertions.register 'assert', (result, message = "No message given") ->
  if result != true
    throw new AssertionException(message)
