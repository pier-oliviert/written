let struct = undefined;

window.Written = {
  Parsers: {
    Block: {},
    register: function(s) {
      struct = s
    }
  }
}

require('../../../../lib/written/app/assets/javascripts/written/core/html')
require('../../../../lib/written/app/assets/javascripts/written/parsers/block/ulist')

describe('ulist', () => {
  it('detects a match', () => {
    let match = struct.rule.exec('- a list')
    expect(match).not.toBeNull()
  })

  it('returns the content for the editor', () => {
    let match = struct.rule.exec('- a list')
    let html = Written.toHTML('<ul><li>- a list</li></ul>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toEditor().outerHTML).toBe(html.outerHTML)
  })

  it('HTML content should not include the markdown syntax', () => {
    let match = struct.rule.exec('- a list')
    let html = Written.toHTML('<ul><li>a list</li></ul>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toHTML().outerHTML).toBe(html.outerHTML)
  })
})


