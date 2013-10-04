var Engine, Gss, compiler;

compiler = require("gss-compiler");

Engine = require("gss-engine");

Gss = function(workerPath, container) {
  this.container = (container ? container : document);
  this.engine = new Engine(workerPath, container);
  return this;
};

Gss.prototype.run = function(rules) {
  var ast;
  ast = void 0;
  if (typeof rules === "string") {
    ast = compiler.compile(rules);
  } else if (typeof rules === "object") {
    ast = rules;
  } else {
    throw new Error("Unrecognized GSS rule format. Should be string or AST");
  }
  this.engine.run(ast);
  return this;
};

Gss.prototype.stop = function() {
  this.engine.stop();
  return this;
};

module.exports = Gss;
