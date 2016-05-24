let struct = undefined;

window.Written = {
  Parsers: {
    Block: {},
    register: function(s) {
      struct = s
    }
  }
}

require('../../../lib/written/app/assets/javascripts/written/core/html')
require('../../../lib/written/app/assets/javascripts/written/parsers/block/code')

describe('code', () => {
  it('detects a match', () => {
    let match = struct.rule.exec('~~~')
    expect(match).not.toBeNull()
  })

  it('can add lines until it finds the closing tag', () => {
    let match = struct.rule.exec('~~~')
    let parser = new struct.parser(match)

    expect(match).not.toBeNull()
    expect(parser.accepts('let var = true')).toBeTruthy()
    parser.append('let var = true')

    expect(parser.accepts('~~~')).toBeTruthy()
    parser.append('~~~')

    expect(parser.opened).toBeFalsy()
  })

  it('returns the content for the editor', () => {
    let match = struct.rule.exec('~~~')
    let html = Written.toHTML('<pre><code>~~~\nlet var = true\n~~~</code></pre>')

    let parser = new struct.parser(match)
    parser.append('let var = true')
    parser.append('~~~')

    expect(parser.opened).toBeFalsy()
    expect(parser.toEditor().outerHTML).toBe(html.outerHTML)
  })

  it('HTML content should not include the markdown syntax', () => {
    let match = struct.rule.exec('~~~')
    let html = Written.toHTML('<pre><code>\nlet var = true\n</code></pre>')

    let parser = new struct.parser(match)
    parser.append('let var = true')
    parser.append('~~~')

    expect(parser.opened).toBeFalsy()
    expect(parser.toHTML().outerHTML).toBe(html.outerHTML)
  })
})
