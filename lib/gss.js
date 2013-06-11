var compiler = require('gss-compiler');
var Engine = require('gss-engine');

var Gss = function (workerPath, container) {
  this.container = container ? container : document;
  this.engine = new Engine(workerPath, container);
};

Gss.prototype.run = function (rules) {
  var ast;
  if (typeof rules === 'string') {
    ast = compiler.compile(rules);
  } else if (typeof rules === 'object') {
    ast = rules;
  } else {
    throw new Error('Unrecognized GSS rule format. Should be string or AST');
  }
  this.engine.run(ast);
};

module.exports = Gss;
