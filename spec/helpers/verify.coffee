verify = ({html, rules, expected}) ->
  describe "with rule #{rules}", ->
    container = document.querySelector '#fixture'
    unless container
      container = document.createElement 'div'
      container.id = '#fixture'
      container.style.marginLeft = '-1000px'
    container.innerHTML = html
    document.querySelector('body').appendChild container
    gss = new Gss '../browser/the-gss-engine/worker/gss-solver.js', container
    solvedValues = null
    it 'should produce correct values', (done) ->
      gss.engine.onSolved = (solved) ->
        solvedValues = solved
        chai.expect(solved).to.be.an 'object'
        for key, expectation of expected
          if typeof expectation.to is 'function'
            expectation.to solved[key], solved
            continue
          chai.expect(solved[key]).to.equal expectation.to, "#{key} should be #{expectation.to}"
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
          expectation.to rect[measurement], solvedValues
          continue
        chai.expect(rect[measurement]).to.equal expectation.to, "#{key} should be #{expectation.to}"

if typeof module is 'object'
  module.exports = verify
else
  window.verify = verify
