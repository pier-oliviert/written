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
require('../../../../lib/written/app/assets/javascripts/written/parsers/block/quote')

describe('quote', () => {
  it('detects a match', () => {
    let match = struct.rule.exec('> a quote')
    expect(match).not.toBeNull()
  })

  it('returns the content for the editor', () => {
    let match = struct.rule.exec('> a quote')
    let html = Written.toHTML('<blockquote><p>> a quote</p></blockquote>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toEditor().outerHTML).toBe(html.outerHTML)
  })

  it('HTML content should not include the markdown syntax', () => {
    let match = struct.rule.exec('> a quote')
    let html = Written.toHTML('<blockquote><p>a quote</p></blockquote>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toHTML().outerHTML).toBe(html.outerHTML)
  })
})



