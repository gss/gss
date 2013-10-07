el = (id) ->
  if typeof id is "string" then return document.getElementById(id) else return id

gssId = (id) ->
  return el(id).getAttribute("data-gss-id")

solvedValue = (id, dimension, solved) ->
  Math.floor(solved["$#{gssId(id)}[#{dimension}]"])

measure = (id, dimension) ->
  return Math.floor el(id).getBoundingClientRect()[dimension]

run = ({html, rules, after}) ->
  name = rules?.trim?()
  describe "#{(if name then name else "//")}", ->
    container = null
    before (done) ->
      container = document.createElement 'div'
      container.style.marginLeft = '-1000px'      
      container.innerHTML = html
      done()
    engine = null
    solvedValues = null
    
    it 'should produce correct values', (done) ->      
      container.addEventListener 'solved', (e) ->
        values = e.detail.values
        engine = e.detail.engine
        if typeof after is 'function'
          after values
        else
          throw new Error "after needed to test something"        
        engine.stop()
        done()
      document.querySelector('body').appendChild container
      if rules
        engine = GSS({container:container, rules:rules})
      #else
      #  GSS.spawn()     

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
    after: (solved) ->
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
    after: (solved) ->
      chai.expect(solvedValue('button3','height',solved)).to.equal 100
      chai.expect(measure('button3','height')).to.equal 100
      chai.expect(solvedValue('button3','width',solved)).to.equal 150
      chai.expect(measure('button3','width')).to.equal 150
  
  run
    html: """
      <button style="width:72px;" id="button4">Hello, world</button>
      """
    rules: """
      #button4[height] == #button4[intrinsic-width];
      """
    after: (solved) ->
      chai.expect(solvedValue('button4','height',solved)).to.equal 72
      chai.expect(measure('button4','height')).to.equal 72
      chai.expect(measure('button4','width')).to.equal 72
  
  # 
  #
  #
  describe "VFL", ->
    run
      html: """
        <div id="b1"></div>
        <div id="b2"></div>
        <div id="b3"></div>
        """
      rules: """
        @horizontal [#b1(==11)][#b2(==9)]-100-[#b3(==10)];
        #b1[x] == 10;
        """
      after: (solved) ->
        # solver
        chai.expect(solvedValue('b1','x',solved)).to.equal 10
        chai.expect(solvedValue('b1','width',solved)).to.equal 11
        # dom
        chai.expect(measure('b1','left')).to.equal 10
        chai.expect(measure('b1','width')).to.equal 11
        chai.expect(measure('b2','left')).to.equal 21
        chai.expect(measure('b2','width')).to.equal 9
        chai.expect(measure('b3','left')).to.equal 130
        chai.expect(measure('b3','width')).to.equal 10
  
  # 
  #
  #
  describe "<style>", ->
    run
      html: """
        <style type="text/gss">
          @horizontal [#s1(==11)][#s2(==9)]-100-[#s3(==10)];
          #s1[x] == 10;
        </style>
        <div id="s1"></div>
        <div id="s2"></div>
        <div id="s3"></div>
        """
      after: (solved) ->
        # solver
        chai.expect(solvedValue('s1','x',solved)).to.equal 10
        chai.expect(solvedValue('s1','width',solved)).to.equal 11
        # dom
        chai.expect(measure('s1','left')).to.equal 10
        chai.expect(measure('s1','width')).to.equal 11
        chai.expect(measure('s2','left')).to.equal 21
        chai.expect(measure('s2','width')).to.equal 9
        chai.expect(measure('s3','left')).to.equal 130
        chai.expect(measure('s3','width')).to.equal 10
  
  describe "<style>", ->
    run
      html: """
        <style type="text/gss">
          @horizontal [#s1(==11)][#s2(==9)]-100-[#s3(==10)];
          #s1[x] == 10;
        </style>
        <div id="s1"></div>
        <div id="s2"></div>
        <div id="s3"></div>
        """
      after: (solved) ->
        # solver
        chai.expect(solvedValue('s1','x',solved)).to.equal 10
        chai.expect(solvedValue('s1','width',solved)).to.equal 11
        # dom
        chai.expect(measure('s1','left')).to.equal 10
        chai.expect(measure('s1','width')).to.equal 11
        chai.expect(measure('s2','left')).to.equal 21
        chai.expect(measure('s2','width')).to.equal 9
        chai.expect(measure('s3','left')).to.equal 130
        chai.expect(measure('s3','width')).to.equal 10

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

