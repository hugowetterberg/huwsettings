lib =
  huwsettings: require '../index'
  vows: require 'vows'
  assert: require 'assert'

loading_tests = lib.vows.describe('Testing file loading and all features')

batch =
  'when loading the sample files':
    topic: ()->
      process.chdir __dirname
      lib.huwsettings.load ['settings.default.yaml', 'settings.yaml', 'settings.env.yaml'], (error, settings)=>
        @callback error, settings
      return
    'we expect to get the correct structure back': (error, result)->
      lib.assert.deepEqual result, final_data

loading_tests.addBatch batch
loading_tests.export module

envOrKey = (key)->
  if process.env[key]?
    process.env[key]
  else
    "$#{key}"

final_data =
  data_dir: "awesome_data"
  value_turning_multiple: [ 10, 20, 5 ]
  tmp_dir: "tmp"
  complex: [
    name: "hello"
    age: 12
    valid: "you bet"
  ,
    name: "world"
    age: 20
    valid: "you bet"
  ,
    name: "hugo"
    age: 30
    valid: "you bet"
  ]
  foo:
    bar: "hello world"
    baz: envOrKey('LC_CTYPE')
    valid: "value"
  some_dirs: [ "data/sample", "data/sample" ]
  replace_this_list: [ 120, 560 ]
  arbitrary:
    number: 56
    text: "hello"
    complex:
      some: "info"
      about: "setting"
    valid: "value"
  some:
    conf: "necktie"
    valid: "value"
  obj: 2
  shell: envOrKey('SHELL')
  editor: envOrKey('EDITOR')
  literal: "$literal string starting with a dollar sign"
  another_literal: "<literal string starting with a less than sign"
  state_value: 'foobar'
  your_shell:
    extra_comment: "I'm glad to see that you're running a shell that I know how to use."

known_shell = no
if process.env['SHELL'] is '/bin/bash'
  known_shell = yes
  final_data.your_shell.comment = "You are running bash, good for you!"
else if process.env['SHELL'].indexOf('zsh') >= 0
  known_shell = yes
  final_data.your_shell.comment = "You are running zsh, good for you!"
else
  final_data.your_shell =
    comment: "I don't know what shell you're running, but whatever works for you."
    extra_comment: 'No comment'

console.log JSON.stringify final_data
