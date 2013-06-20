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
        solvedValues = solved
        chai.expect(solved).to.be.an 'object'
        for key, expectation of expected
          if typeof expectation.to is 'function'
            expectation.to Math.floor(solved[key]), solved
            continue
          chai.expect(Math.floor(solved[key])).to.equal Math.floor(expectation.to), "#{key} should be #{expectation.to}"
        gss.stop()
        done()
      gss.run rules
    it 'should reflect in the DOM', ->
      for key, expectation of expected
        [selector, measurement] = expectation.measure
        element = document.querySelector selector
        chai.expect(element).to.be.an 'object', "Element #{selector} should be found"
        rect = element.getBoundingClientRect()
        if typeof expectation.to is 'function'
          expectation.to Math.floor(rect[measurement]), solvedValues
          continue
        chai.expect(Math.floor(rect[measurement])).to.equal Math.floor(expectation.to), "#{key} should be #{expectation.to}"

if typeof module is 'object'
  module.exports = verify
else
  window.verify = verify
