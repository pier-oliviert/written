# Written

Written is an easy to use, customizable WYSIWYG markdown editor. Built for evergreen browsers, it is a standalone editor with **zero dependency**. Based on the idea of [iA Writer](https://ia.net/writer/mac/), this editor uses HTML to render your text as it should look.

As you type, your text is parsed and the document take shapes. Making you look at your draft like you would on the final product. Because Markdown you *type* the style of your text, you can start your text on a different editor and copy/paste it into Written. The style will always carry over.

### Easy to style

Paragraphs are paragraphs, lists are lists and headers are... you got it, headers. This allows you to easily include Written in your project and style it very quickly to its surrounding. Ease of customization is one of the thing that drove the creation of Written.

The editor also allows you to cherry-pick the markdown feature you wish to support on your site. You can also create your own parser if you need something very specific that doesn't come out of the box.


### How to use

To start using Written, you just have to create a new editor.

~~~javascript
new Written(document.querySelector('#Editor'))
~~~

You can retrieve the document either as a markdown text, or a HTML string. For storage purposes, you might want to store the HTML string from the current document

~~~javascript
var html = document.querySelector('#Editor').instance.history.current.toHTMLString()
var markdown = document.querySelector('#Editor').instance.history.current.toString()
~~~

### Enable the parsers you need

Written allows you to enable the parsers you wish. The parsers are split into two categories: Inline and Block parsers. If you don't specify any parser during the initialization, Written, will enable all the feature by default.

The editor needs to be configured before it is initialized. Here's how you customize the parsers.

~~~javascript
var parsers = new Written.Parsers({
  blocks: ['header', 'code', 'ulist', 'olist']
})
var editor = new Written(document.querySelector('#Editor'), {parsers: parsers})
~~~

Not specifying parsers will enable *all parsers*.

### Document

Based on the document system described in [Trix](https://github.com/basecamp/trix), a document is created whenever the text is modified in the editor. Document's job is to store the cursor position as well as the HTML elements rendered by the parser.

This means that Written can render text from a document and also position the cursor at the right place.

Those documents are then stored in a history that Written then use to implement the undo/redo feature.

### On Change Events

Written dispatch an event whenever text changes on the Editor. To receive update when the editor change, just add an event listener to ```written:changed``` event.

~~~javascript
  document.addEventListener('written:changed', function(event) {
    let document = event.detail.document
    document.toHTMLString() // HTML version
    document.toString() // Markdown version
  })
~~~

## Test the editor locally

If you want to test the editor on your machine, the easiest way is with [Ruby](httsp://www.ruby-lang.org).

```ruby
$ bundle install
$ bundle exec rake server
```

This will launch a server that runs the Editor with on ```localhost:3000```.
