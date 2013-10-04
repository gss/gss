var Engine, Gss, compiler;

compiler = require("gss-compiler");

Engine = require("gss-engine");

Gss = function(_arg) {
  var container, worker;
  worker = _arg.worker, container = _arg.container;
  if (!worker) {
    worker = Gss.worker;
  }
  this.container = (container ? container : document);
  this.engine = new Engine(worker, container);
  return this;
};

Gss.worker = '../browser/the-gss-engine/worker/gss-solver.js';

Gss.processStyleTag = function(style, o) {
  var container, gss, rules;
  rules = style.innerHTML;
  container = style.parentElement;
  if (container.tagName === "HEAD") {
    container = document;
  }
  o.container = container;
  gss = new Gss(o);
  return gss.run(rules);
};

Gss.spawn = function(o, from) {
  var style, styles, _i, _len, _results;
  if (o == null) {
    o = {};
  }
  if (from == null) {
    from = document;
  }
  styles = from.querySelectorAll("style[type='text/gss']");
  _results = [];
  for (_i = 0, _len = styles.length; _i < _len; _i++) {
    style = styles[_i];
    _results.push(Gss.processStyleTag(style, o));
  }
  return _results;
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
