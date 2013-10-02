module.exports = (grunt) ->

  TARGET_DIR = 'target'
  DIST_DIR = 'dist'
  APP_DIR = 'src/app'
  my_test_files = ['test/**/*.coffee']

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean:
      dev: [TARGET_DIR]
      dist:
        files: [
          {src: ["#{DIST_DIR}/app/**/*", "#{DIST_DIR}/web/**/*"]}
          {src: ["#{DIST_DIR}/*"], filter: 'isFile'}
        ]

    coffeelint:
      app: ["src/**/*.coffee", "test/**/*.coffee"]
      options:
        max_line_length:
          value: 120
        no_empty_param_list:
          value: true
          level: 'error'

    copy:
      single:
        expand: true, cwd: "src", src: ["**/*"], dest: TARGET_DIR

      dev:
        files: [
          {expand: true, cwd: "src", src: ["**/*"], dest: TARGET_DIR}
          {expand: true, cwd: "vendor", src: ["**/*"], dest: "#{TARGET_DIR}/web"}
        ]
      dist:
        files: [
          {expand: true, cwd: "src", src: ["**/*", "!**/*.coffee"], dest: DIST_DIR}
          {expand: true, cwd: "vendor", src: ["**/*"], dest: "#{DIST_DIR}/web"}
          {expand: true, src: "package.json", dest: DIST_DIR}
          {expand: true, src: "Procfile", dest: DIST_DIR}
        ]

    coffee:
      options:
        sourceMap: true
        sourceRoot: ""
        bare: true

      single:
        expand: true, cwd: "src", src: ["**/*.coffee"], dest: TARGET_DIR, ext: '.js'

      compile:
        files: [
          {expand: true, cwd: "src", src: ["**/*.coffee"], dest: TARGET_DIR, ext: '.js'}
        ]

      dist:
        options:
          sourceMap: false
        files: [
          {expand: true, cwd: "src", src: ["**/*.coffee"], dest: DIST_DIR, ext: '.js'}
        ]

    mochacli:
      all: my_test_files

    watch:
      options:
        interval: 5007
        spawn: false

      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffeelint','coffee:single']
        options:
          livereload: true

      other:
        files: ['src/**/*', '!src/**/*.coffee']
        tasks: ['copy:single']
        options:
          livereload: true

    nodemon:
      dev:
        options:
          cwd: "#{TARGET_DIR}"
          file: "app/app.js"
          ignoredFiles: ["*.jade", 'web/*']

    concurrent:
      target:
        tasks: ['nodemon', 'watch']
        options:
          logConcurrentOutput: true

  grunt.event.on 'watch', (action, filepath) ->
    target = filepath.replace 'src/', ''
    if /coffee$/.test target
      grunt.config ['coffee', 'single', 'src'], [target]
      grunt.config ['coffeelint', 'app'], [filepath]
    else
      grunt.config ['copy', 'single', 'src'], [target]


  grunt.loadNpmTasks 'grunt-mocha-cli'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-nodemon'
  grunt.loadNpmTasks 'grunt-concurrent'
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask 'dist', ['clean:dist', 'coffeelint', 'coffee:dist', 'copy:dist']
  grunt.registerTask 'default', ['clean:dev', 'coffeelint', 'coffee:compile', 'copy:dev', 'concurrent']
