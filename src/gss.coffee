compiler = require("gss-compiler")

Engine = require("gss-engine")

Gss = (workerPath, container) ->
  @container = (if container then container else document)
  @engine = new Engine(workerPath, container)
  @

Gss::run = (rules) ->
  ast = undefined
  if typeof rules is "string"
    ast = compiler.compile(rules)

  # ruels are changed by reference!
  else if typeof rules is "object"
    ast = rules
  else
    throw new Error("Unrecognized GSS rule format. Should be string or AST")

  #console.log(ast);
  @engine.run ast
  @

Gss::stop = ->
  @engine.stop()
  @

module.exports = Gss