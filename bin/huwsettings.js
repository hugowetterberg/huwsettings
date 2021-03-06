// Generated by CoffeeScript 1.7.1
(function() {
  var count, files, lib;

  lib = {
    huwsettings: require('../index')
  };

  count = process.argv.length - 2;

  if (count > 0) {
    files = process.argv.slice(2, process.argv.length);
    lib.huwsettings.load(files, function(error, settings) {
      return console.log(JSON.stringify(settings, null, 2));
    });
  } else {
    console.error('Please supply one or more settings paths');
  }

}).call(this);
