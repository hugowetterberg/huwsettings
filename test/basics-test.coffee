lib =
  huwsettings: require '../index'
  vows: require 'vows'
  assert: require 'assert'

tests = lib.vows.describe('Testing features atomically')

batch =
  'when using environment variables':
    topic: ()->
      buckets =
        '$':
          VAR: 'foobar'
      settings = {}
      values =
        setting: '$VAR'
      lib.huwsettings.extend settings, values, buckets
      settings
    'we expect to get the correct value back': (error, result)->
      lib.assert.equal result.setting, 'foobar'

tests.addBatch batch
tests.export module
