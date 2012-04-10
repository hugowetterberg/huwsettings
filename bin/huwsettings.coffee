lib =
  huwsettings: require '../index'
count = process.argv.length - 2

if count > 0
  files = process.argv[2...process.argv.length]
  lib.huwsettings.load files, (error, settings)->
    console.log JSON.stringify settings, null, 2
else
  console.error 'Please supply one or more settings paths'