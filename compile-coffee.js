var coffee = require('coffee-script')
var babelJest = require("babel-jest");

module.exports = {
  process: function(src, path) {
    if (coffee.helpers.isCoffee(path)) {
      return coffee.compile(src, {
        'bare': true
      });
    } else {
      return babelJest.process(src, path);
    }
  }
};
