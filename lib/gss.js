var compiler;

compiler = require("gss-compiler");

require("gss-engine");

GSS.worker = '../browser/the-gss-engine/worker/gss-solver.js';

GSS.compile = function(rules) {
  var ast;
  ast = {};
  if (typeof rules === "string") {
    ast = compiler.compile(rules);
  } else if (typeof rules === "object") {
    ast = rules;
  } else {
    throw new Error("Unrecognized GSS rule format. Should be string or AST");
  }
  return ast;
};

GSS.Engine.prototype['compile'] = function(source) {
  return this.run(GSS.compile(source));
};

GSS.Getter.prototype['readAST:text/gss'] = function(node) {
  var ast, source;
  source = node.innerHTML.trim();
  if (source.length === 0) {
    return {};
  }
  ast = GSS.compile(source);
  return ast;
};
