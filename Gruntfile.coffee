module.exports = (grunt) ->

  my_files = ['app.coffee', 'conf/**/*.coffee',
          'service/**/*.coffee', 'controller/**/*.coffee',
          'model/**/*.coffee']
  my_test_files = ['test/**/*.coffee']

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    mochacli:
      all: my_test_files

    watch:
      files: my_files.concat(my_test_files)
      tasks: ['lint', 'test']
      options:
        interval: 5007

    coffeelint:
      app: my_files.concat(my_test_files)
      options:
        max_line_length:
          value: 120
        no_empty_param_list:
          value: true
          level: 'error'

  grunt.loadNpmTasks 'grunt-mocha-cli'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'

  grunt.registerTask 'test', ['mochacli']
  grunt.registerTask 'lint', ['coffeelint']
  grunt.registerTask 'default', ['lint', 'mochacli', 'watch']