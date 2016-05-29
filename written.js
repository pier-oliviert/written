(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Written = (function() {
    function Written(el, options) {
      var cursor, document, parsers, text;
      if (options == null) {
        options = {};
      }
      this.toString = bind(this.toString, this);
      this.redo = bind(this.redo, this);
      this.undo = bind(this.undo, this);
      this.render = bind(this.render, this);
      this.linefeed = bind(this.linefeed, this);
      this.cursor = bind(this.cursor, this);
      this.changed = bind(this.changed, this);
      this.changeTo = bind(this.changeTo, this);
      this.dispatch = bind(this.dispatch, this);
      el.instance = this;
      el.dataset.editor = "written";
      this.element = function() {
        return el;
      };
      this.element().addEventListener('dragover', this.over);
      this.element().addEventListener('drop', this.preventDefaults);
      this.element().addEventListener('keypress', this.linefeed);
      this.element().addEventListener('keydown', this.undo);
      this.element().addEventListener('keydown', this.redo);
      this.element().addEventListener('keydown', this.cursor);
      parsers = options.parsers;
      if (parsers == null) {
        parsers = new Written.Parsers();
      }
      this.parsers = parsers;
      text = this.toString();
      this.element().textContent = '';
      if (this.element().contentEditable !== 'true') {
        this.element().contentEditable = 'true';
      }
      cursor = new Written.Cursor(this.element(), window.getSelection(), this.parsers);
      document = new Written.Document(text, this.parsers, cursor);
      this.render(document);
      document.cursor.focus(document.toString().length);
      this.history = new Written.History(document);
      this.observer = new Written.Observer(this.element(), this.changed);
      this.dispatch('written:initialized');
    }

    Written.prototype.preventDefaults = function(e) {
      return e.preventDefault();
    };

    Written.prototype.dispatch = function(name, data) {
      var event;
      if (data == null) {
        data = {};
      }
      event = new CustomEvent(name, {
        bubbles: true,
        detail: data
      });
      return this.element().dispatchEvent(event);
    };

    Written.prototype.changeTo = function(text) {
      var document;
      document = new Written.Document(text, this.parsers);
      this.history.push(document);
      return this.render(document);
    };

    Written.prototype.changed = function(e) {
      var cursor, newDocument, oldDocument;
      oldDocument = this.history.current;
      cursor = new Written.Cursor(this.element(), window.getSelection(), this.parsers);
      newDocument = new Written.Document(this.toString(), this.parsers, cursor);
      if (this.element().children.length > 0 && oldDocument.toString().localeCompare(newDocument.toString()) === 0) {
        return;
      }
      this.history.push(newDocument);
      this.render(newDocument);
      return this.dispatch('written:changed', {
        document: newDocument
      });
    };

    Written.prototype.cursor = function() {
      return this.history.current.cursor = new Written.Cursor(this.element(), window.getSelection(), this.parsers);
    };

    Written.prototype.linefeed = function(e) {
      var cursor;
      if (e.which !== 13) {
        return;
      }
      e.preventDefault();
      e.stopPropagation();
      cursor = new Written.Cursor(this.element(), window.getSelection(), this.parsers);
      return this.observer.pause((function(_this) {
        return function() {
          var document, lines, offset;
          offset = cursor.offset;
          lines = _this.history.current.toString().split('\n').map(function(line) {
            if (line.length < offset) {
              offset -= line.length;
            } else if (offset >= 0) {
              line = [line.slice(0, offset), '\n', line.slice(offset)].join('');
              offset -= line.length;
            }
            offset -= 1;
            return line;
          });
          if (offset === 0) {
            lines.push('');
            cursor.offset += 1;
          }
          document = new Written.Document(lines.join('\n'), _this.parsers, cursor);
          if (cursor.offset < document.toString().length) {
            cursor.offset += 1;
          }
          _this.render(document);
          return _this.history.push(document);
        };
      })(this));
    };

    Written.prototype.render = function(document) {
      document.applyTo(this.element());
      return Written.Attachments.attach(this);
    };

    Written.prototype.undo = function(e) {
      var document;
      if (e.code === 'KeyZ' && e.metaKey && !e.shiftKey) {
        e.preventDefault();
        e.stopPropagation();
      } else {
        return;
      }
      if (document = this.history.previous()) {
        this.history.current = document;
        return this.render(document);
      }
    };

    Written.prototype.redo = function(e) {
      var document;
      if (e.code === 'KeyZ' && e.metaKey && e.shiftKey) {
        e.preventDefault();
        e.stopPropagation();
      } else {
        return;
      }
      if (document = this.history.next()) {
        this.history.current = document;
        return this.render(this.history.current);
      }
    };

    Written.prototype.toString = function() {
      var content, i, len, node, ref, texts;
      texts = [];
      ref = this.element().childNodes;
      for (i = 0, len = ref.length; i < len; i++) {
        node = ref[i];
        content = this.parsers.toString(node).split('\n');
        texts.push(content.join('\n'));
      }
      return texts.join('\n');
    };

    return Written;

  })();

}).call(this);
(function() {
  var Attachment, Attachments,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Written.Attachments = new (Attachments = (function() {
    function Attachments() {
      this.attach = bind(this.attach, this);
      this.attachments = {};
      this.nodes = [];
    }

    Attachments.prototype.bind = function(nodeName, attachment) {
      return this.attachments[nodeName] = attachment;
    };

    Attachments.prototype.attach = function(editor) {
      var attachment, name, node, nodes, ref, results;
      ref = this.attachments;
      results = [];
      for (name in ref) {
        attachment = ref[name];
        nodes = editor.element().querySelectorAll(name);
        results.push((function() {
          var i, len, results1;
          results1 = [];
          for (i = 0, len = nodes.length; i < len; i++) {
            node = nodes[i];
            if (this.nodes.includes(node)) {
              continue;
            }
            attachment = new attachment(node);
            attachment.editor(editor);
            results1.push(this.nodes.push(node));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    return Attachments;

  })());

  this.Written.Attachments.Base = Attachment = (function() {
    function Attachment() {
      this.resume = bind(this.resume, this);
      this.pause = bind(this.pause, this);
    }

    Attachment.prototype.editor = function(editor) {
      this.editor = function() {
        return editor;
      };
      return this.editor();
    };

    Attachment.prototype.pause = function() {
      return this.editor().observer.pause();
    };

    Attachment.prototype.resume = function(callback) {
      this.editor().observer.resume();
      if (callback != null) {
        return callback();
      }
    };

    Attachment.prototype.getSelection = function() {
      return window.getSelection();
    };

    return Attachment;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Written.Cursor = (function() {
    function Cursor(element, selection, parsers) {
      this.focus = bind(this.focus, this);
      var child, children, i, len, node, parent, ref;
      this.element = function() {
        return element;
      };
      this.selection = selection;
      this.parsers = parsers;
      children = Array.prototype.slice.call(this.element().children, 0);
      this.offset = selection.focusOffset;
      node = selection.focusNode;
      while (node && !children.includes(node)) {
        parent = node.parentElement;
        if (parent) {
          child = node.previousSibling;
          while (child) {
            this.offset += this.parsers.toString(child).length;
            child = child.previousSibling;
          }
          if (node instanceof HTMLLIElement) {
            this.offset += Array.prototype.indexOf.call(parent.children, node);
          }
        }
        node = parent;
      }
      ref = this.element().children;
      for (i = 0, len = ref.length; i < len; i++) {
        child = ref[i];
        if (child === node) {
          break;
        }
        this.offset += this.parsers.toString(child).length;
        this.offset += 1;
      }
      this.currentNode = function() {
        return node;
      };
    }

    Cursor.prototype.offsetAt = function(node) {
      var element, offset;
      offset = this.offset;
      element = this.element().firstElementChild;
      while (element && element !== node) {
        offset -= this.parsers.toString(element).length;
        element = element.nextElementSibling;
      }
      return offset;
    };

    Cursor.prototype.focus = function(offset, node) {
      var range;
      if (offset === void 0) {
        offset = this.offset;
      } else {
        this.offset = offset;
      }
      if (node === void 0) {
        node = this.element().firstElementChild;
      }
      while (node.nextElementSibling && this.parsers.toString(node).length < offset) {
        offset -= this.parsers.toString(node).length + 1;
        node = node.nextElementSibling;
      }
      range = this.parsers.getRange(node, Math.min(offset, this.parsers.toString(node).length), document.createTreeWalker(node, NodeFilter.SHOW_TEXT));
      if (this.offsetDiffersBetween(this.selection, range)) {
        this.selection.removeAllRanges();
        this.selection.addRange(range);
        if (!this.inViewport(node)) {
          return node.scrollIntoView();
        }
      }
    };

    Cursor.prototype.offsetDiffersBetween = function(selection, range) {
      return selection.focusNode !== range.startContainer || selection.focusOffset !== range.startOffset;
    };

    Cursor.prototype.inViewport = function(node) {
      var bounding;
      bounding = node.getBoundingClientRect();
      return bounding.top >= 0 && bounding.left >= 0 && bounding.bottom <= (window.innerHeight || document.documentElement.clientHeight) && bounding.right <= (window.innerWidth || document.documentElement.clientWidth);
    };

    return Cursor;

  })();

}).call(this);
(function() {
  this.Written.Parsers = (function() {
    function Parsers(parsers) {
      var i, j, len, len1, node, ref, ref1, struct;
      if (parsers == null) {
        parsers = {};
      }
      if (parsers.blocks != null) {
        this.blocks = Written.Parsers.Blocks.select(parsers.blocks);
      } else {
        this.blocks = [Written.Parsers.Blocks["default"]].concat(Written.Parsers.Blocks);
      }
      if (parsers.inlines != null) {
        this.inlines = Written.Parsers.Inlines.select(parsers.inlines);
      } else {
        this.inlines = Written.Parsers.Inlines;
      }
      this.nodes = {};
      ref = this.blocks.concat(this.inlines);
      for (i = 0, len = ref.length; i < len; i++) {
        struct = ref[i];
        ref1 = struct.nodes;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          node = ref1[j];
          this.nodes[node] = struct;
        }
      }
      this.blocks.parse = this.parseBlocks.bind(this, this.blocks);
      this.inlines.parse = this.parseInlines.bind(this, this.inlines);
    }

    Parsers.prototype.parse = function(parsers, text) {
      return parsers.parse(text);
    };

    Parsers.prototype.parseBlocks = function(parsers, text) {
      var block, blocks, line, lines, str;
      parsers = [parsers["default"]].concat(parsers).reverse();
      blocks = [];
      lines = text.split('\n').reverse();
      while ((line = lines.pop()) !== void 0) {
        str = line;
        block = blocks[blocks.length - 1];
        if ((block != null) && block.multiline && block.accepts(line)) {
          block.append(line);
          continue;
        }
        blocks.push(this.find(parsers, str));
      }
      return blocks;
    };

    Parsers.prototype.parseInlines = function(parsers, text) {
      var buffer, content, i, index, len, match, matches, parser, struct;
      buffer = '';
      content = [];
      matches = [];
      index = 0;
      for (i = 0, len = parsers.length; i < len; i++) {
        struct = parsers[i];
        struct.rule.lastIndex = 0;
        while (match = struct.rule.exec(text)) {
          parser = new struct.parser(match);
          matches[parser.index()] = parser;
        }
      }
      while (text[index] != null) {
        if (parser = matches[index]) {
          content.push(buffer.slice(0));
          content.push(parser);
          buffer = '';
          index += parser.length();
        } else {
          buffer += text[index];
          index += 1;
        }
      }
      if (buffer.length > 0) {
        content.push(buffer);
      }
      return content;
    };

    Parsers.prototype.find = function(parsers, str) {
      var i, len, match, parser, struct;
      parser = void 0;
      for (i = 0, len = parsers.length; i < len; i++) {
        struct = parsers[i];
        if (match = struct.rule.exec(str)) {
          parser = new struct.parser(match);
          break;
        }
      }
      return parser;
    };

    Parsers.prototype.get = function(name) {
      return this.nodes[name];
    };

    Parsers.prototype.getRange = function(node, offset, walker) {
      return this.nodes[node.nodeName.toLowerCase()].getRange(node, offset, walker);
    };

    Parsers.prototype.toString = function(node) {
      var struct;
      struct = this.nodes[node.nodeName.toLowerCase()];
      if (struct != null) {
        return struct.toString(node);
      } else {
        return node.textContent;
      }
    };

    return Parsers;

  })();

  Written.Parsers.Blocks = [];

  Written.Parsers.Inlines = [];

  Written.Parsers.Blocks.select = function(nodes) {
    var selected;
    selected = [];
    nodes.map(function(name) {
      var struct;
      struct = Written.Parsers.Blocks.find(function(struct) {
        return struct.name === name;
      });
      if (struct != null) {
        return selected.push(struct);
      }
    });
    return [Written.Parsers.Blocks["default"]].concat(selected);
  };

  Written.Parsers.Inlines.select = function(nodes) {
    var selected;
    selected = [];
    nodes.map(function(name) {
      var struct;
      struct = Written.Parsers.Inlines.find(function(struct) {
        return struct.name === name;
      });
      if (struct != null) {
        return selected.push(struct);
      }
    });
    return selected;
  };

  Written.Parsers.register = function(struct) {
    var type;
    type = void 0;
    if (struct.type === 'block') {
      type = Written.Parsers.Blocks;
    } else if (struct.type === 'inline') {
      type = Written.Parsers.Inlines;
    } else {
      raise('error: Written.Parsers can either be "block" or "inline"');
      return;
    }
    Written.Parsers.normalize(struct);
    if (struct["default"]) {
      return type["default"] = struct;
    } else {
      return type.push(struct);
    }
  };

  Written.Parsers.normalize = function(struct) {
    if (!struct.getRange) {
      struct.getRange = function(node, offset, walker) {
        var range;
        range = document.createRange();
        if (node.firstChild == null) {
          range.setStart(node, 0);
        } else {
          while (walker.nextNode()) {
            if (walker.currentNode.length < offset) {
              offset -= walker.currentNode.length;
              continue;
            }
            range.setStart(walker.currentNode, offset);
            break;
          }
        }
        range.collapse(true);
        return range;
      };
    }
    if (Object.prototype.toString === struct.toString) {
      return struct.toString = function(node) {
        return node.textContent;
      };
    }
  };

  Written.Parsers.Block = (function() {
    function Block() {}

    Block.prototype.outerText = function() {
      throw "method implementation: " + this.name + ".outerText() is missing.";
    };

    Block.prototype.equals = function() {
      throw "method implementation: " + this.name + ".equals(current, rendered) is missing.";
    };

    Block.prototype.toEditor = function() {
      throw "method implementation: " + this.name + ".toEditor() is missing.";
    };

    Block.prototype.toHTML = function() {
      throw "method implementation: " + this.name + ".toHTML() is missing.";
    };

    return Block;

  })();

  Written.Parsers.Inline = (function() {
    function Inline() {}

    Inline.prototype.index = function() {
      throw "method implementation: " + this.name + ".index() is missing.";
    };

    Inline.prototype.length = function() {
      throw "method implementation: " + this.name + ".length() is missing.";
    };

    Inline.prototype.toEditor = function() {
      throw "method implementation: " + this.name + ".toEditor() is missing.";
    };

    Inline.prototype.toHTML = function() {
      throw "method implementation: " + this.name + ".toHTML() is missing.";
    };

    return Inline;

  })();

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Written.Document = (function() {
    function Document(text, parsers, cursor) {
      this.toString = bind(this.toString, this);
      this.applyTo = bind(this.applyTo, this);
      this.toHTMLString = bind(this.toHTMLString, this);
      this.freeze = bind(this.freeze, this);
      this.cursor = cursor;
      this.blocks = parsers.parse(parsers.blocks, text);
      this.blocks.forEach((function(_this) {
        return function(block) {
          if (block.innerText != null) {
            if (block.multiline) {
              return block.content = block.innerText().split('\n').map(function(text) {
                return parsers.parse(parsers.inlines, text);
              });
            } else {
              return block.content = parsers.parse(parsers.inlines, block.innerText());
            }
          }
        };
      })(this));
    }

    Document.prototype.freeze = function() {
      Object.freeze(this.blocks);
      return Object.freeze(this.cursor);
    };

    Document.prototype.toHTMLString = function() {
      var text;
      text = '';
      this.blocks.forEach(function(node) {
        return text += node.toHTML().outerHTML + "\n";
      });
      return text;
    };

    Document.prototype.applyTo = function(content) {
      var block, element, elements, i, index, j, len, len1, node, ref, remaining;
      ref = this.blocks;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        block = ref[index];
        remaining = Array.prototype.slice.call(content.children, index);
        element = remaining[0];
        node = this.findNodeFor(block, remaining);
        content.insertBefore(node, element);
      }
      elements = Array.prototype.slice.call(content.children, index);
      for (j = 0, len1 = elements.length; j < len1; j++) {
        element = elements[j];
        element.remove();
      }
      return this.cursor.focus();
    };

    Document.prototype.findNodeFor = function(block, remaining) {
      var found, node;
      node = block.toEditor();
      found = remaining.find(function(existing) {
        return block.equals(existing, node);
      });
      return found || node;
    };

    Document.prototype.toString = function() {
      var texts;
      if (this.toString.cache != null) {
        return this.toString.cache;
      }
      texts = this.blocks.map(function(block) {
        return block.outerText();
      });
      return texts.join('\n');
    };

    return Document;

  })();

}).call(this);
(function() {
  var History,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Written.History = History = (function() {
    function History(document) {
      this.limit = bind(this.limit, this);
      this.next = bind(this.next, this);
      this.previous = bind(this.previous, this);
      this.push = bind(this.push, this);
      document.freeze();
      this.current = document;
    }

    History.prototype.push = function(document) {
      var previousDocument;
      previousDocument = this.current;
      this.current = document;
      previousDocument.nextDocument = document;
      document.previousDocument = previousDocument;
      document.freeze();
      return this.limit();
    };

    History.prototype.previous = function() {
      return this.current.previousDocument;
    };

    History.prototype.next = function() {
      return this.current.nextDocument;
    };

    History.prototype.limit = function() {
      var document, i, j;
      document = this.current;
      for (i = j = 0; j < 1000; i = ++j) {
        if (document.previousDocument != null) {
          document = document.previousDocument;
        } else {
          break;
        }
      }
      return document.previousDocument = void 0;
    };

    return History;

  })();

}).call(this);
(function() {
  Written.toHTML = function(text) {
    var el;
    el = document.createElement('div');
    el.innerHTML = text;
    if (el.children.length > 1) {
      return el.children;
    } else {
      return el.children[0];
    }
  };

}).call(this);
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Written.Observer = (function() {
    function Observer(element, callback) {
      this.pause = bind(this.pause, this);
      this.resume = bind(this.resume, this);
      this.normalize = bind(this.normalize, this);
      this.element = function() {
        return element;
      };
      this.settings = function() {
        return {
          childList: true,
          subtree: true,
          characterData: true
        };
      };
      this.mutations = new MutationObserver(this.normalize.bind(this, callback));
      this.mutations.observe(this.element(), this.settings());
    }

    Observer.prototype.normalize = function(callback, events) {
      this.pause((function(_this) {
        return function() {
          var br, event, i, len, results;
          results = [];
          for (i = 0, len = events.length; i < len; i++) {
            event = events[i];
            if (event.target instanceof HTMLElement) {
              results.push((function() {
                var j, len1, ref, results1;
                ref = event.target.querySelectorAll('br');
                results1 = [];
                for (j = 0, len1 = ref.length; j < len1; j++) {
                  br = ref[j];
                  results1.push(br.remove());
                }
                return results1;
              })());
            } else {
              results.push(void 0);
            }
          }
          return results;
        };
      })(this));
      return this.pause(callback);
    };

    Observer.prototype.resume = function() {
      return this.mutations.observe(this.element(), this.settings());
    };

    Observer.prototype.pause = function(callback) {
      this.mutations.disconnect();
      if (callback != null) {
        callback();
        return this.resume();
      }
    };

    return Observer;

  })();

}).call(this);
(function() {
  var Code,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Code = (function(superClass) {
    extend(Code, superClass);

    Code.prototype.multiline = true;

    function Code(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.matches = [match];
      this.content = "\n";
      this.opened = true;
    }

    Code.prototype.outerText = function() {
      var texts;
      texts = this.matches.map(function(m) {
        return m[0];
      });
      return texts.join('\n');
    };

    Code.prototype.accepts = function(text) {
      return this.opened;
    };

    Code.prototype.append = function(text) {
      var match;
      match = /^(~{3})$/i.exec(text);
      if (match != null) {
        this.matches.push(match);
        this.opened = false;
      } else {
        this.matches.push([text]);
        this.content += text + "\n";
      }
      return this.content;
    };

    Code.prototype.equals = function(current, rendered) {
      return current.outerHTML === rendered.outerHTML;
    };

    Code.prototype.toEditor = function() {
      var code, node;
      node = Written.toHTML("<pre><code></code></pre>");
      code = node.querySelector('code');
      if (this.matches[0][3] != null) {
        code.classList.add("language-" + this.matches[0][3]);
      }
      code.appendChild(document.createTextNode(this.content));
      if (this.highlight != null) {
        this.highlight(code);
      }
      code.insertAdjacentHTML('afterbegin', this.matches[0][0]);
      if (!this.opened) {
        code.insertAdjacentHTML('beforeend', this.matches[this.matches.length - 1][0]);
      }
      return node;
    };

    Code.prototype.toHTML = function() {
      var code, node;
      node = Written.toHTML("<pre><code></code></pre>");
      code = node.querySelector('code');
      if (this.matches[0][3] != null) {
        code.classList.add("language-" + this.matches[0][3]);
      }
      if (this.matches[0][4] != null) {
        code.insertAdjacentHTML('beforebegin', "<header>" + this.matches[0][4] + "</header>");
      }
      code.appendChild(document.createTextNode(this.content.slice(1, -1)));
      return node;
    };

    return Code;

  })(Written.Parsers.Block);

  Written.Parsers.register({
    parser: Code,
    name: 'code',
    nodes: ['pre'],
    type: 'block',
    rule: /^((~{3})([a-z]+)?)(?:\s(.*))?/i,
    toString: function(node) {
      if (node.textContent[node.textContent.length - 1] === '\n') {
        return node.textContent.substr(0, node.textContent.length - 1);
      } else {
        return node.textContent;
      }
    },
    highlightWith: function(callback) {
      return Code.prototype.highlight = callback;
    }
  });

}).call(this);
(function() {
  var Header,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Header = (function(superClass) {
    extend(Header, superClass);

    Header.prototype.multiline = false;

    function Header(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.match = match;
    }

    Header.prototype.equals = function(current, rendered) {
      return current.outerHTML === rendered.outerHTML;
    };

    Header.prototype.innerText = function() {
      return this.match[3];
    };

    Header.prototype.outerText = function() {
      return this.match[0];
    };

    Header.prototype.toEditor = function() {
      var i, len, node, ref, text;
      node = Written.toHTML("<h" + this.match[2].length + ">");
      ref = this.content;
      for (i = 0, len = ref.length; i < len; i++) {
        text = ref[i];
        if (text.toEditor != null) {
          node.appendChild(text.toEditor());
        } else {
          node.appendChild(document.createTextNode(text));
        }
      }
      node.insertAdjacentHTML('afterbegin', this.match[1]);
      return node;
    };

    Header.prototype.toHTML = function() {
      var i, len, node, ref, text;
      node = Written.toHTML("<h" + this.match[2].length + ">");
      ref = this.content;
      for (i = 0, len = ref.length; i < len; i++) {
        text = ref[i];
        if (text.toHTML != null) {
          node.appendChild(text.toHTML());
        } else {
          node.appendChild(document.createTextNode(text));
        }
      }
      return node;
    };

    return Header;

  })(Written.Parsers.Block);

  Written.Parsers.register({
    parser: Header,
    name: 'header',
    nodes: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
    type: 'block',
    rule: /^((#{1,6})\s)(.*)$/i,
    getRange: function(node, offset, walker) {
      var range;
      range = document.createRange();
      if (node.firstChild == null) {
        range.setStart(node, 0);
      } else {
        while (walker.nextNode()) {
          if (walker.currentNode.length < offset) {
            offset -= walker.currentNode.length;
            continue;
          }
          range.setStart(walker.currentNode, offset);
          break;
        }
      }
      range.collapse(true);
      return range;
    },
    toString: function(node) {
      return node.textContent;
    }
  });

}).call(this);
(function() {
  var Image,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Image = (function(superClass) {
    extend(Image, superClass);

    Image.prototype.multiline = false;

    function Image(match) {
      this.placeholder = bind(this.placeholder, this);
      this.toEditor = bind(this.toEditor, this);
      this.match = match;
    }

    Image.prototype.outerText = function() {
      return this.match[0];
    };

    Image.prototype.innerText = function() {
      return this.match[2];
    };

    Image.prototype.equals = function(current, rendered) {
      var figcaption, img;
      figcaption = current.querySelector('figcaption') || {};
      img = current.querySelector('img') || {};
      return rendered.querySelector('figcaption').outerHTML === figcaption.outerHTML && rendered.querySelector('img').src === img.src;
    };

    Image.prototype.toEditor = function() {
      var caption, container, figure, i, img, len, ref, text;
      figure = Written.toHTML("<figure><div contenteditable='false'><img/></div><figcaption /></figure>");
      caption = figure.querySelector('figcaption');
      container = figure.querySelector('div');
      ref = this.content;
      for (i = 0, len = ref.length; i < len; i++) {
        text = ref[i];
        if (text.toEditor != null) {
          caption.appendChild(text.toEditor());
        } else {
          caption.appendChild(document.createTextNode(text));
        }
      }
      caption.insertAdjacentHTML('afterbegin', '![');
      caption.insertAdjacentHTML('beforeend', ']');
      caption.insertAdjacentHTML('beforeend', this.match[3]);
      img = figure.querySelector('img');
      if (this.match[4] != null) {
        img.src = this.match[4];
      } else {
        img.src = '/assets/written/placeholder.png';
      }
      return figure;
    };

    Image.prototype.toHTML = function() {
      var caption, figure, i, img, len, ref, text;
      figure = Written.toHTML("<figure><img/><figcaption /></figure>");
      img = figure.querySelector('img');
      caption = figure.querySelector('figcaption');
      img.src = this.match[4];
      ref = this.content;
      for (i = 0, len = ref.length; i < len; i++) {
        text = ref[i];
        if (text.toHTML != null) {
          caption.appendChild(text.toHTML());
        } else {
          caption.appendChild(document.createTextNode(text));
        }
      }
      return figure;
    };

    Image.prototype.placeholder = function(img, event, onerror) {
      if (onerror == null) {
        onerror = false;
      }
      img.src = '/assets/written/placeholder.png';
      return img.onerror = void 0;
    };

    return Image;

  })(Written.Parsers.Block);

  Written.Parsers.register({
    parser: Image,
    name: 'image',
    nodes: ['figure'],
    type: 'block',
    rule: /^(!{1}\[([^\]]*)\])(\(([^\s]*)?\))$/i,
    toString: function(node) {
      return (node.querySelector('figcaption') || node).textContent;
    }
  });

}).call(this);
(function() {
  var OList, RULE,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  RULE = /^(\d+\.\s)(.*)/i;

  OList = (function(superClass) {
    extend(OList, superClass);

    OList.prototype.multiline = true;

    function OList(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.matches = [match];
      this.opened = true;
    }

    OList.prototype.accepts = function(text) {
      this.opened = RULE.test(text);
      return this.opened;
    };

    OList.prototype.append = function(text) {
      return this.matches.push(RULE.exec(text));
    };

    OList.prototype.equals = function(current, rendered) {
      return current.outerHTML === rendered.outerHTML;
    };

    OList.prototype.innerText = function() {
      var texts;
      texts = this.matches.map(function(match) {
        return match[2];
      });
      return texts.join('\n');
    };

    OList.prototype.outerText = function() {
      var texts;
      texts = this.matches.map(function(match) {
        return match[0];
      });
      return texts.join('\n');
    };

    OList.prototype.toEditor = function() {
      var i, index, j, len, len1, li, line, node, ref, text;
      node = Written.toHTML("<ol></ol>");
      ref = this.content;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        line = ref[index];
        li = Written.toHTML("<li>");
        li.appendChild(document.createTextNode(this.matches[index][1]));
        for (j = 0, len1 = line.length; j < len1; j++) {
          text = line[j];
          if (text.toEditor != null) {
            li.appendChild(text.toEditor());
          } else {
            li.appendChild(document.createTextNode(text.toString()));
          }
        }
        node.appendChild(li);
      }
      return node;
    };

    OList.prototype.toHTML = function() {
      var i, index, j, len, len1, li, line, node, ref, text;
      node = Written.toHTML("<ol></ol>");
      ref = this.content;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        line = ref[index];
        li = Written.toHTML("<li>");
        for (j = 0, len1 = line.length; j < len1; j++) {
          text = line[j];
          if (text.toHTML != null) {
            li.appendChild(text.toHTML());
          } else {
            li.appendChild(document.createTextNode(text.toString()));
          }
        }
        node.appendChild(li);
      }
      return node;
    };

    return OList;

  })(Written.Parsers.Block);

  Written.Parsers.register({
    parser: OList,
    name: 'olist',
    nodes: ['ol'],
    type: 'block',
    rule: RULE,
    getRange: function(node, offset, walker) {
      var li, newList, range;
      range = document.createRange();
      if (node.firstChild == null) {
        range.setStart(node, 0);
        return;
      }
      li = node.firstElementChild;
      while (walker.nextNode()) {
        if (!li.contains(walker.currentNode)) {
          newList = walker.currentNode;
          while ((newList != null) && !(newList instanceof HTMLLIElement)) {
            newList = newList.parentElement;
          }
          li = newList;
          offset--;
        }
        if (walker.currentNode.length < offset) {
          offset -= walker.currentNode.length;
          continue;
        }
        range.setStart(walker.currentNode, offset);
        break;
      }
      range.collapse(true);
      return range;
    },
    toString: function(node) {
      var texts;
      texts = Array.prototype.slice.call(node.children).map(function(li) {
        return li.textContent;
      });
      return texts.join("\n");
    }
  });

}).call(this);
(function() {
  var Paragraph,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Paragraph = (function(superClass) {
    extend(Paragraph, superClass);

    Paragraph.prototype.multiline = false;

    function Paragraph(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.outerText = bind(this.outerText, this);
      this.innerText = bind(this.innerText, this);
      this.match = match;
    }

    Paragraph.prototype.equals = function(current, rendered) {
      return current.outerHTML === rendered.outerHTML;
    };

    Paragraph.prototype.innerText = function() {
      return this.match[0];
    };

    Paragraph.prototype.outerText = function() {
      return this.match[0];
    };

    Paragraph.prototype.toEditor = function() {
      var i, len, node, ref, text;
      node = Written.toHTML("<p>");
      ref = this.content;
      for (i = 0, len = ref.length; i < len; i++) {
        text = ref[i];
        if (text.toEditor != null) {
          node.appendChild(text.toEditor());
        } else {
          node.appendChild(document.createTextNode(text));
        }
      }
      return node;
    };

    Paragraph.prototype.toHTML = function() {
      var i, len, node, ref, text;
      node = Written.toHTML("<p>");
      ref = this.content;
      for (i = 0, len = ref.length; i < len; i++) {
        text = ref[i];
        if (text.toHTML != null) {
          node.appendChild(text.toHTML());
        } else {
          node.appendChild(document.createTextNode(text));
        }
      }
      return node;
    };

    return Paragraph;

  })(Written.Parsers.Block);

  Written.Parsers.register({
    parser: Paragraph,
    name: 'paragraph',
    nodes: ['p'],
    type: 'block',
    rule: /.*/i,
    "default": true
  });

}).call(this);
(function() {
  var Quote, RULE,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  RULE = /^(>\s)(.*)/i;

  Quote = (function(superClass) {
    extend(Quote, superClass);

    Quote.prototype.multiline = true;

    function Quote(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.innerText = bind(this.innerText, this);
      this.matches = [match];
      this.opened = true;
    }

    Quote.prototype.accepts = function(text) {
      return this.opened = RULE.test(text);
    };

    Quote.prototype.append = function(text) {
      return this.matches.push(RULE.exec(text));
    };

    Quote.prototype.outerText = function() {
      var lines;
      lines = this.matches.map(function(match) {
        return match[0];
      });
      return lines.join('\n');
    };

    Quote.prototype.innerText = function() {
      var lines;
      lines = this.matches.map(function(match) {
        return match[2];
      });
      return lines.join('\n');
    };

    Quote.prototype.equals = function(current, rendered) {
      return current.outerHTML === rendered.outerHTML;
    };

    Quote.prototype.toEditor = function() {
      var i, index, j, len, len1, line, node, p, ref, text;
      node = Written.toHTML("<blockquote></blockquote>");
      ref = this.content;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        line = ref[index];
        p = Written.toHTML("<p>");
        p.appendChild(document.createTextNode(this.matches[index][1]));
        for (j = 0, len1 = line.length; j < len1; j++) {
          text = line[j];
          if (text.toEditor != null) {
            p.appendChild(text.toEditor());
          } else {
            p.appendChild(document.createTextNode(text.toString()));
          }
        }
        if (index < this.content.length - 1) {
          p.insertAdjacentHTML('beforeend', '\n');
        }
        node.appendChild(p);
      }
      return node;
    };

    Quote.prototype.toHTML = function() {
      var i, index, j, len, len1, line, node, p, ref, text;
      node = Written.toHTML("<blockquote></blockquote>");
      ref = this.content;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        line = ref[index];
        p = Written.toHTML("<p>");
        for (j = 0, len1 = line.length; j < len1; j++) {
          text = line[j];
          if (text.toHTML != null) {
            p.appendChild(text.toHTML());
          } else {
            p.appendChild(document.createTextNode(text.toString()));
          }
        }
        if (index < this.content.length - 1) {
          p.insertAdjacentHTML('beforeend', '\n');
        }
        node.appendChild(p);
      }
      return node;
    };

    return Quote;

  })(Written.Parsers.Block);

  Written.Parsers.register({
    parser: Quote,
    name: 'quote',
    nodes: ['blockquote'],
    type: 'block',
    rule: RULE
  });

}).call(this);
(function() {
  var RULE, UList,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  RULE = /^(-\s)(.*)/i;

  UList = (function(superClass) {
    extend(UList, superClass);

    UList.prototype.multiline = true;

    function UList(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.matches = [match];
    }

    UList.prototype.accepts = function(text) {
      this.opened = RULE.test(text);
      return this.opened;
    };

    UList.prototype.outerText = function() {
      var texts;
      texts = this.matches.map(function(match) {
        return match[0];
      });
      return texts.join('\n');
    };

    UList.prototype.innerText = function() {
      var texts;
      texts = this.matches.map(function(match) {
        return match[2];
      });
      return texts.join('\n');
    };

    UList.prototype.append = function(text) {
      return this.matches.push(RULE.exec(text));
    };

    UList.prototype.equals = function(current, rendered) {
      return current.outerHTML === rendered.outerHTML;
    };

    UList.prototype.toEditor = function() {
      var i, index, j, len, len1, li, line, node, ref, text;
      node = Written.toHTML("<ul></ul>");
      ref = this.content;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        line = ref[index];
        li = Written.toHTML("<li>");
        li.appendChild(document.createTextNode(this.matches[index][1]));
        for (j = 0, len1 = line.length; j < len1; j++) {
          text = line[j];
          if (text.toEditor != null) {
            li.appendChild(text.toEditor());
          } else {
            li.appendChild(document.createTextNode(text.toString()));
          }
        }
        node.appendChild(li);
      }
      return node;
    };

    UList.prototype.toHTML = function() {
      var i, index, j, len, len1, li, line, node, ref, text;
      node = Written.toHTML("<ul></ul>");
      ref = this.content;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        line = ref[index];
        li = Written.toHTML("<li>");
        for (j = 0, len1 = line.length; j < len1; j++) {
          text = line[j];
          if (text.toHTML != null) {
            li.appendChild(text.toHTML());
          } else {
            li.appendChild(document.createTextNode(text.toString()));
          }
        }
        node.appendChild(li);
      }
      return node;
    };

    return UList;

  })(Written.Parsers.Block);

  Written.Parsers.register({
    parser: UList,
    name: 'ulist',
    nodes: ['ul'],
    type: 'block',
    rule: RULE,
    getRange: function(node, offset, walker) {
      var li, newList, range;
      range = document.createRange();
      if (node.firstChild == null) {
        range.setStart(node, 0);
        return;
      }
      li = node.firstElementChild;
      while (walker.nextNode()) {
        if (!li.contains(walker.currentNode)) {
          newList = walker.currentNode;
          while ((newList != null) && !(newList instanceof HTMLLIElement)) {
            newList = newList.parentElement;
          }
          li = newList;
          offset--;
        }
        if (walker.currentNode.length < offset) {
          offset -= walker.currentNode.length;
          continue;
        }
        range.setStart(walker.currentNode, offset);
        break;
      }
      range.collapse(true);
      return range;
    },
    toString: function(node) {
      var texts;
      texts = Array.prototype.slice.call(node.children).map(function(li) {
        return li.textContent;
      });
      return texts.join("\n");
    }
  });

}).call(this);
(function() {
  var Code,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Code = (function(superClass) {
    extend(Code, superClass);

    function Code(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.length = bind(this.length, this);
      this.index = bind(this.index, this);
      this.match = match;
    }

    Code.prototype.index = function() {
      return this.match.index;
    };

    Code.prototype.length = function() {
      return this.match[0].length;
    };

    Code.prototype.toEditor = function() {
      var node;
      node = Written.toHTML("<code>" + this.match[0] + "</code>");
      if (this.match[3] != null) {
        node.classList.add("language-" + this.match[3]);
      }
      if (this.highlight != null) {
        this.highlight(node);
      }
      return node;
    };

    Code.prototype.toHTML = function() {
      var node;
      node = Written.toHTML("<code>" + this.match[4] + "</code>");
      if (this.match[3] != null) {
        node.classList.add("language-" + this.match[3]);
      }
      return node;
    };

    return Code;

  })(Written.Parsers.Inline);

  Written.Parsers.register({
    parser: Code,
    name: 'code',
    nodes: ['code'],
    type: 'inline',
    rule: /((~{3})([a-z]+)?)\s(.+)?(~{3})/gi,
    highlightWith: function(callback) {
      return Code.prototype.highlight = callback;
    }
  });

}).call(this);
(function() {
  var Italic,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Italic = (function(superClass) {
    extend(Italic, superClass);

    function Italic(match) {
      this.toEditor = bind(this.toEditor, this);
      this.length = bind(this.length, this);
      this.index = bind(this.index, this);
      this.match = match;
    }

    Italic.prototype.index = function() {
      return this.match.index;
    };

    Italic.prototype.length = function() {
      return this.match[0].length;
    };

    Italic.prototype.toEditor = function() {
      return Written.toHTML("<em>" + this.match[1] + "</em>");
    };

    Italic.prototype.toHTML = function() {
      return Written.toHTML("<em>" + this.match[3] + "</em>");
    };

    return Italic;

  })(Written.Parsers.Inline);

  Written.Parsers.register({
    parser: Italic,
    name: 'italic',
    nodes: ['em'],
    type: 'inline',
    rule: /((_{1})([^_]+)(_{1}))/gi
  });

}).call(this);
(function() {
  var Link,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Link = (function(superClass) {
    extend(Link, superClass);

    function Link(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.length = bind(this.length, this);
      this.index = bind(this.index, this);
      this.match = match;
    }

    Link.prototype.index = function() {
      return this.match.index;
    };

    Link.prototype.length = function() {
      return this.match[0].length;
    };

    Link.prototype.toEditor = function() {
      return Written.toHTML("<a><strong>" + this.match[1] + "</strong>" + this.match[3] + "</a>");
    };

    Link.prototype.toHTML = function() {
      return Written.toHTML("<a href='" + this.match[4] + "'>" + this.match[2] + "</a>");
    };

    return Link;

  })(Written.Parsers.Inline);

  Written.Parsers.register({
    parser: Link,
    name: 'link',
    nodes: ['a'],
    type: 'inline',
    rule: /!{0}(\[([^\]]+)\])(\(([^\)]+)\))/gi
  });

}).call(this);
(function() {
  var Strong,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Strong = (function(superClass) {
    extend(Strong, superClass);

    function Strong(match) {
      this.toHTML = bind(this.toHTML, this);
      this.toEditor = bind(this.toEditor, this);
      this.length = bind(this.length, this);
      this.index = bind(this.index, this);
      this.match = match;
    }

    Strong.prototype.index = function() {
      return this.match.index;
    };

    Strong.prototype.length = function() {
      return this.match[0].length;
    };

    Strong.prototype.toEditor = function() {
      return Written.toHTML("<strong>" + this.match[0] + "</strong>");
    };

    Strong.prototype.toHTML = function() {
      return Written.toHTML("<strong>" + this.match[3] + "</strong>");
    };

    return Strong;

  })(Written.Parsers.Inline);

  Written.Parsers.register({
    parser: Strong,
    name: 'strong',
    nodes: ['strong'],
    type: 'inline',
    rule: /((\*{1})([^\*]+)(\*{1}))/gi
  });

}).call(this);
(function() {


}).call(this);
