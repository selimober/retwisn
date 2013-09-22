module.exports = (grunt) ->

  TARGET_DIR = 'target'
  DIST_DIR = 'target/dist'
  APP_DIR = 'src/app'
  my_files = ['app.coffee', 'conf/**/*.coffee',
          'service/**/*.coffee', 'controller/**/*.coffee',
          'model/**/*.coffee', 'public/scripts/**/*.coffee']
  my_test_files = ['test/**/*.coffee']

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    copy:
      main:
        files: [{
          expand: true
          cwd: APP_DIR
          src: ["**/*", "!**/*.coffee"]
          dest: "#{TARGET_DIR}/app"
          filter: 'isFile'
        }]

    coffee:
      options:
        sourceMap: true

      compile:
        expand: true
        cwd: APP_DIR
        src: ["**/*.coffee"]
        dest: "#{TARGET_DIR}/app"
        ext: '.js'

    mochacli:
      all: my_test_files

    watch:
      files: my_files.concat(my_test_files)
      tasks: ['lint', 'coffee']
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

    nodemon:
      dev:
        options:
          file: 'app.coffee'

          ignoredFiles: ['*.jade', '*.js', 'public/**/*.coffee', '*.css', 'node_modules/**', '.git/**/*']

    concurrent:
      target:
        tasks: ['nodemon', 'watch']
        options:
          logConcurrentOutput: true


  grunt.loadNpmTasks 'grunt-mocha-cli'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-nodemon'
  grunt.loadNpmTasks 'grunt-concurrent'
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask 'test', ['mochacli']
  grunt.registerTask 'compile', ['copy' ,'coffee']
  grunt.registerTask 'lint', ['coffeelint']
  grunt.registerTask 'default', ['lint', 'concurrent']