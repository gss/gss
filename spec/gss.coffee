Gss = require 'gss'

describe 'GSS runtime', ->
  verify
    html: """
      <button id="button1">One</button>
      <button id="button2">Second</button>
      """
    rules: """
      #button1[width] == #button2[width];      
      #button2[width] == 100;
      """
    expected: 
      'button1': ['width',100]


  verify
    html: """
      <button id="button3">Hello, world</button>
      """
    rules: """
      #button3[height] == 100;
      #button3[width] == 150;
      """
    expected:
      'button3': ['height',100]
      'button3': ['width', 150]
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

