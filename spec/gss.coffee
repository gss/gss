Gss = require 'gss'

el = (id) ->
  if typeof id is "string" then return document.getElementById(id) else return id

gssId = (id) ->
  return el(id).getAttribute("data-gss-id")

solvedValue = (id, dimension, solved) ->
  Math.floor(solved["$#{gssId(id)}[#{dimension}]"])

measure = (id, dimension) ->
  return Math.floor el(id).getBoundingClientRect()[dimension]

run = ({html, rules, onSolved}) ->
  describe "#{rules.trim()}", ->
    container = null
    before (done) ->
      container = document.createElement 'div'
      container.style.marginLeft = '-1000px'
      document.querySelector('body').appendChild container
      container.innerHTML = html
      done()
    gss = new Gss '../browser/the-gss-engine/worker/gss-solver.js', container
    solvedValues = null
    it 'should produce correct values', (done) ->
      gss.engine.onSolved = (solved) ->
        if typeof onSolved is 'function'
          onSolved solved
        gss.stop()
        done()
      gss.run rules

describe 'GSS runtime', ->
  run
    html: """
      <button id="button1">One</button>
      <button id="button2">Second</button>
      """
    rules: """
      #button1[width] == #button2[width];
      #button2[width] == 100;
      """
    onSolved: (solved) ->
      chai.expect(solvedValue('button1','width',solved)).to.equal 100
      chai.expect(measure('button1','width')).to.equal 100

  run
    html: """
      <button id="button3">Hello, world</button>
      """
    rules: """
      #button3[height] == 100;
      #button3[width] == 150;
      """
    onSolved: (solved) ->
      chai.expect(solvedValue('button3','height',solved)).to.equal 100
      chai.expect(measure('button3','height')).to.equal 100
      chai.expect(solvedValue('button3','width',solved)).to.equal 150
      chai.expect(measure('button3','width')).to.equal 150

  ###
  verify
    html: """
      <button id="b1">One</button>
      <button id="b2">Second</button>
      <button id="b3">3</button>
      """
    rules: """
      @horizontal [#b1]-[#b2]-[#b3] chain-top;
      """
    expected: (solved) ->
      hgap = solved['[hgap]']
      left = solved['#b1[right]']
      right = Math.round val
      chai.expect(right).to.equal Math.floor left + hgap
      "#b2[top]":
        measure: ['#b2', 'top']
        to: (val, solved) ->
          target = Math.floor solved['#b1[top]']
          top = Math.floor val
          chai.expect(top).to.equal target
      "#b3[left]":
        measure: ['#b3', 'left']
        to: (val, solved) ->
          hgap = solved['[hgap]']
          left = solved['#b2[right]']
          right = Math.round val
          chai.expect(right).to.equal Math.floor left + hgap
      "#b3[top]":
        measure: ['#b3', 'top']
        to: (val, solved) ->
          target = Math.floor solved['#b1[top]']
          top = Math.floor val
          chai.expect(top).to.equal target
  ###

