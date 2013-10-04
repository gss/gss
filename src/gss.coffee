compiler = require("gss-compiler")

Engine = require("gss-engine")



Gss = ({worker, container}) ->
  if !worker then worker = Gss.worker
  @container = (if container then container else document)
  @engine = new Engine(worker, container)
  @

Gss.worker = '../browser/the-gss-engine/worker/gss-solver.js'

Gss.processStyleTag = (style, o) ->
  rules = style.innerHTML
  container = style.parentElement
  if container.tagName is "HEAD" then container = document
  o.container = container
  gss = new Gss o
  gss.run rules  

Gss.spawn = (o={}, from=document) ->
  styles = from.querySelectorAll("style[type='text/gss']")
  for style in styles
    Gss.processStyleTag style, o
    
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