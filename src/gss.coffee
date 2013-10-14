compiler = require("gss-compiler")

Engine = require("gss-engine")

# Polyfill
unless window.MutationObserver
  window.MutationObserver = window.JsMutationObserver

#$(function(){
#  // your code
#});

document.addEventListener "DOMContentLoaded", (e) ->
  # The event "DOMContentLoaded" will be fired when the document has been parsed completely, that is without stylesheets* and additional images. If you need to wait for images and stylesheets, use "load" instead.
  GSS.boot()


GSS = ({worker, container, rules}) ->
  if !worker then worker = GSS.worker
  container = (if container then container else document)
  
  # TODO:
  # cache engine to container?
  engine = new Engine(worker, container)
  
  # attach plugins to engine
  engine.compile = (rules) ->
    engine.run GSS.compile rules
  
  #
  if rules then engine.compile rules
  
  # return engine for chaining
  return engine
  
GSS.engines = []

GSS.worker = '../browser/the-gss-engine/worker/gss-solver.js'

GSS.compile = (rules) ->
  ast = undefined
  if typeof rules is "string"
    ast = compiler.compile(rules)
  # ruels are changed by reference!
  else if typeof rules is "object"
    ast = rules
  else
    throw new Error("Unrecognized GSS rule format. Should be string or AST")
  return ast

GSS.boot = () ->
  GSS.spawn()
  observer = new MutationObserver (mutations) ->
    #console.log "mutations: ", mutations
    GSS.spawn()
  config = subtree: true, childList: true, attributes: false, characterData: false
  observer.observe(document, config)
      
  #styles = window.styles = document.getElementsByTagName("style")
  #observer = new PathObserver styles, 'length', (newval, oldval) ->
  #  alert 'handle nodelist change'
  #Platform.performMicrotaskCheckpoint()

GSS.processStyleTag = (style, o={}) ->
  return unless style.getAttribute("type") is 'text/gss'
  return if style._gss_processed

  rules = style.innerHTML.trim()
  container = style.parentElement
  if container.tagName is "HEAD"
    container = document
  o.container = container
  o.rules = rules

  engine = GSS o
  engine.styleTag = style
  GSS.engines.push engine

  style._gss_processed = true

styleTags = GSS.styleTags = null

GSS.spawn = (o={}, from=document) ->
  if !styleTags
    GSS.styleTags = styleTags = from.getElementsByTagName("style")
  for style in styleTags
    GSS.processStyleTag style, o

GSS.stopAll = ->
  alert 'not implemented'

# marshal in plugin
if window.GSS?
  for key,val of window.GSS
    GSS[key] = val

window.GSS = GSS
