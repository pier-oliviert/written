let struct = undefined;

window.Written = {
  Parsers: {
    Inline: {},
    register: function(s) {
      struct = s
    }
  }
}

require('../../../../lib/written/app/assets/javascripts/written/core/html')
require('../../../../lib/written/app/assets/javascripts/written/parsers/inline/italic')

describe('italic', () => {
  it('detects a match', () => {
    let match = struct.rule.exec('_test_')
    expect(match).not.toBeNull()
  })

  it('ignores text that do not match', () => {
    let match = struct.rule.exec('test_')
    expect(match).toBeNull()
  })

  it('returns the content for the editor', () => {
    struct.rule.lastIndex = 0
    let match = struct.rule.exec('_test_')
    expect(match).toBeTruthy()
    let parser = new struct.parser(match)
    expect(parser.toEditor().outerHTML).toBe(Written.toHTML('<em>_test_</em>').outerHTML)
  })

  it('HTML content should not include the markdown syntax', () => {
    struct.rule.lastIndex = 0
    let match = struct.rule.exec('_test_')
    expect(match).toBeTruthy()
    let parser = new struct.parser(match)
    expect(parser.toHTML().outerHTML).toBe(Written.toHTML('<em>test</em>').outerHTML)
  })
})

