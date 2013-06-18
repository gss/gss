Gss = require 'gss'

describe 'GSS runtime', ->
  verify
    html: """
      <button id="button1">One</button>
      <button id="button2">Second</button>
      """
    rules: """
      #button1[width] == #button2[width];
      """
    expected:
      '#button1[width]':
        measure: ['#button1', 'width']
        to: (val, solved) ->
          chai.expect(Math.floor(solved['#button2[width]'])).to.equal val

  verify
    html: """
      <button id="button3">Hello, world</button>
      """
    rules: """
      #button3[h] == 100;
      #button3[w] == 150;
      """
    expected:
      '#button3[h]':
        measure: ['#button3', 'height']
        to: 100
      '#button3[w]':
        measure: ['#button3', 'width']
        to: 150

  verify
    html: """
      <button style="margin: 0px;" id="button4">One</button>
      <button id="button5">Second</button>
      """
    rules: """
      #button4[left] == #button5[right];
      """
    expected:
      '#button4[left]':
        measure: ['#button4', 'left']
        to: (val, solved) ->
          chai.expect(Math.floor(solved['#button5[right]'])).to.equal val
