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
require('../../../../lib/written/app/assets/javascripts/written/parsers/block/image')

describe('image', () => {
  it('detects a match', () => {
    let match = struct.rule.exec('![an](img)')
    expect(match).not.toBeNull()
  })

  it('returns the content for the editor', () => {
    let match = struct.rule.exec('![an](img)')
    let html = Written.toHTML('<figure><div contenteditable=false><img src="img" /></div><figcaption>![an](img)</figcaption></figure>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toEditor().outerHTML).toBe(html.outerHTML)
  })

  it('HTML content should not include the markdown syntax', () => {
    let match = struct.rule.exec('![an](img)')
    let html = Written.toHTML('<figure><img src="img" /><figcaption>an</figcaption></figure>')

    let parser = new struct.parser(match)
    parser.content = [parser.innerText()]
    expect(parser.toHTML().outerHTML).toBe(html.outerHTML)
  })
})

