var Gss, chai;

Gss = require('gss');

if (!chai) {
  chai = require('chai');
}

describe('GSS runtime', function() {
  var container, gss;
  container = document.createElement('div');
  container.style.marginLeft = '-1000px';
  container.innerHTML = "<button id=\"button1\">One</button>\n<button id=\"button2\">Second</button>";
  document.querySelector('body').appendChild(container);
  gss = new Gss('../browser/the-gss-engine/worker/gss-solver.js', container);
  describe('when initialized', function() {
    it('should be bound to the DOM container', function() {
      return chai.expect(gss.container).to.eql(container);
    });
    return it('should hold a GSS engine bound to the same container', function() {
      chai.expect(gss.engine).to.be.an('object');
      return chai.expect(gss.engine.container).to.eql(container);
    });
  });
  return describe('with rule #button1[width] == #button2[width]', function() {
    var button1, button2, rule;
    rule = '#button1[width] == #button2[width];';
    button1 = container.querySelector('#button1');
    button2 = container.querySelector('#button2');
    it('before solving the second button should be wider', function() {
      return chai.expect(button2.getBoundingClientRect().width).to.be.above(button1.getBoundingClientRect().width);
    });
    return it('after solving the buttons should be of equal width', function(done) {
      gss.engine.onSolved = function(values) {
        chai.expect(values).to.be.an('object');
        chai.expect(values['#button1[width]']).to.equal(values['#button2[width]']);
        chai.expect(button1.getBoundingClientRect().width).to.equal(values['#button1[width]']);
        chai.expect(button2.getBoundingClientRect().width).to.equal(values['#button2[width]']);
        return done();
      };
      return gss.run(rule);
    });
  });
});
