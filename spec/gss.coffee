Gss = require 'gss'
chai = require 'chai' unless chai

describe 'GSS runtime', ->
  container = document.createElement 'div'
  container.style.marginLeft = '-1000px'
  container.innerHTML = """
      <button id="button1">One</button>
      <button id="button2">Second</button>
  """
  document.querySelector('body').appendChild container

  gss = new Gss '../browser/the-gss-engine/worker/gss-solver.js', container
  describe 'when initialized', ->
    it 'should be bound to the DOM container', ->
      chai.expect(gss.container).to.eql container
    it 'should hold a GSS engine bound to the same container', ->
      chai.expect(gss.engine).to.be.an 'object'
      chai.expect(gss.engine.container).to.eql container
  describe 'with rule #button1[width] == #button2[width]', ->
    rule = '#button1[width] == #button2[width];'
    button1 = container.querySelector '#button1'
    button2 = container.querySelector '#button2'
    it 'before solving the second button should be wider', ->
      chai.expect(button2.getBoundingClientRect().width).to.be.above button1.getBoundingClientRect().width
    it 'after solving the buttons should be of equal width', (done) ->
      gss.engine.onSolved = (values) ->
        chai.expect(values).to.be.an 'object'
        chai.expect(values['#button1[width]']).to.equal values['#button2[width]']
        chai.expect(button1.getBoundingClientRect().width).to.equal values['#button1[width]']
        chai.expect(button2.getBoundingClientRect().width).to.equal values['#button2[width]']
        done()
      gss.run rule
