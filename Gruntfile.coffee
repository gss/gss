module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Build the browser Component
    component:
      install:
        options:
          action: 'install'
    component_build:
      'gss':
        output: './browser/'
        config: './component.json'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      engine:
        files:
          './browser/gss.min.js': ['./browser/gss.js']
      worker:
        files:
          './browser/gss-solver.min.js': ['./browser/the-gss-engine/worker/gss-solver.js']

    # Automated recompilation and testing when developing
    watch:
      test:
        files: ['spec/*.coffee', 'lib/*.js']
        tasks: ['test']

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      all: ['spec/runner.html']

    # Syntax checking
    jshint:
      src: ['lib/*.js']

    # Cross-browser testing
    connect:
      server:
        options:
          base: ''
          port: 9999

    'saucelabs-mocha':
      all:
        options:
          urls: ['http://127.0.0.1:9999/spec/runner.html']
          browsers: [
            browserName: 'chrome'
          ,
            browserName: 'firefox'
          ,
            browserName: 'internet explorer'
            platform: 'WIN8'
            version: '10'
          ]
          build: process.env.TRAVIS_JOB_ID
          testname: 'GSS browser tests'
          tunnelTimeout: 5
          concurrency: 3
          detailedError: true

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-component'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-jshint'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-contrib-watch'

  # Cross-browser testing in the cloud
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-saucelabs'

  @registerTask 'build', ['component', 'component_build', 'uglify']
  @registerTask 'test', ['jshint', 'coffee', 'build',  'mocha_phantomjs']
  @registerTask 'crossbrowser', ['jshint', 'coffee', 'build', 'mocha_phantomjs', 'connect', 'saucelabs-mocha']
  @registerTask 'default', ['build']
