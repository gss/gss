var Engine, GSS, compiler, key, styleTags, val, _ref;

compiler = require("gss-compiler");

Engine = require("gss-engine");

document.addEventListener("DOMContentLoaded", function(e) {
  return GSS.boot();
});

GSS = function(_arg) {
  var container, engine, rules, worker;
  worker = _arg.worker, container = _arg.container, rules = _arg.rules;
  if (!worker) {
    worker = GSS.worker;
  }
  container = (container ? container : document);
  engine = new Engine(worker, container);
  engine.compile = function(rules) {
    return engine.run(GSS.compile(rules));
  };
  if (rules) {
    engine.compile(rules);
  }
  return engine;
};

GSS.engines = [];

GSS.worker = '../browser/the-gss-engine/worker/gss-solver.js';

GSS.compile = function(rules) {
  var ast;
  ast = void 0;
  if (typeof rules === "string") {
    ast = compiler.compile(rules);
  } else if (typeof rules === "object") {
    ast = rules;
  } else {
    throw new Error("Unrecognized GSS rule format. Should be string or AST");
  }
  return ast;
};

GSS.boot = function() {
  var config, observer;
  GSS.spawn();
  observer = new MutationObserver(function(mutations) {
    return GSS.spawn();
  });
  config = {
    subtree: true,
    childList: true,
    attributes: false,
    characterData: false
  };
  return observer.observe(document, config);
};

GSS.processStyleTag = function(style, o) {
  var container, rules;
  if (o == null) {
    o = {};
  }
  if (style.getAttribute("type") === 'text/gss') {
    if (!style._gss_processed) {
      rules = style.innerHTML;
      container = style.parentElement;
      if (container.tagName === "HEAD") {
        container = document;
      }
      o.container = container;
      o.rules = rules;
      GSS(o);
      return style._gss_processed = true;
    }
  }
};

styleTags = GSS.styleTags = null;

GSS.spawn = function(o, from) {
  var style, _i, _len, _results;
  if (o == null) {
    o = {};
  }
  if (from == null) {
    from = document;
  }
  if (!styleTags) {
    GSS.styleTags = styleTags = from.getElementsByTagName("style");
  }
  _results = [];
  for (_i = 0, _len = styleTags.length; _i < _len; _i++) {
    style = styleTags[_i];
    _results.push(GSS.processStyleTag(style, o));
  }
  return _results;
};

GSS.stopAll = function() {
  return alert('not implemented');
};

if (window.GSS != null) {
  _ref = window.GSS;
  for (key in _ref) {
    val = _ref[key];
    GSS[key] = val;
  }
}

window.GSS = GSS;
