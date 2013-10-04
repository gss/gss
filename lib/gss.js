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
    // ruels are changed by reference!
  } else if (typeof rules === 'object') {    
    ast = rules;
  } else {
    throw new Error('Unrecognized GSS rule format. Should be string or AST');
  }
  //console.log(ast);  
  this.engine.run(ast);
};

Gss.prototype.stop = function () {
  this.engine.stop();
};

module.exports = Gss;
