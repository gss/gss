idToGssId = (id) ->
  return document.getElementById(id).getAttribute("data-gss-id")

solvedValue = (id, dimension, solved) ->
  Math.floor(solved["$#{idToGssId(id)}[#{dimension}]"])

measure = (id, dimension) ->
  return Math.floor document.getElementById(id).getBoundingClientRect()[dimension]

verify = ({html, rules, expected}) ->
  describe "with rule #{rules.trim()}", ->
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
        if typeof expected is 'function'
          expected solved
        else
          for id of expected
            [prop, val] = expected[id]
            chai.expect(solvedValue(id,prop,solved)).to.equal val
            chai.expect(measure(id,prop)).to.equal val
        gss.stop()
        done()
      gss.run rules
    ###  
    it 'should reflect in the DOM', ->
      for key, expectation of expected
        [selector, measurement] = expectation.measure
        element = document.querySelector selector
        chai.expect(element).to.be.an 'object', "Element #{selector} should be found"
        rect  = element.getBoundingClientRect()
        if typeof expectation.to is 'function'
          expectation.to Math.floor(rect[measurement]), solvedValues
          continue
        chai.expect(Math.floor(rect[measurement])).to.equal Math.floor(expectation.to), "#{key} should be #{expectation.to}"
    ###
if typeof module is 'object'
  module.exports = verify
else
  window.verify = verify
