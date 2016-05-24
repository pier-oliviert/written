let struct = undefined;

window.Written = {
  Parsers: {
    Block: {},
    register: function(s) {
      if (struct == undefined) {
        struct = s
      }
    }
  }
}

require('../../../../lib/written/app/assets/javascripts/written/core/html')
require('../../../../lib/written/app/assets/javascripts/written/parsers/block/heading')

describe('header', () => {
  it('detects a match', () => {
    let match = struct.rule.exec('# Hello World')
    expect(match).not.toBeNull()
  })

  it('returns the content for the editor', () => {
    let match = struct.rule.exec('# Hello World!')
    let html = Written.toHTML('<h1># Hello World!</h1>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toEditor().outerHTML).toBe(html.outerHTML)
  })

  it('HTML content should not include the markdown syntax', () => {
    let match = struct.rule.exec('# Hello World!')
    let html = Written.toHTML('<h1>Hello World!</h1>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toHTML().outerHTML).toBe(html.outerHTML)
  })
})
