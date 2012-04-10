lib =
  fs: require 'fs'
  jsyaml: require 'js-yaml'

processValue = (buckets, value)->
  key = if value.length then value[0] else no
  if key and buckets[key]
    name = value.substring 1
    if name.length and name[0] is key
      value = name
    else if buckets[key][name]?
      value = buckets[key][name]
  value

hasValue = (buckets, value)->
  key = if value.length then value[0] else no
  exists = key isnt no
  if key and buckets[key]?
    exists = buckets[key][value.substring 1]?
  exists

operators =
  is: (buckets, a, b)->
    a = processValue buckets, a
    b = processValue buckets, b
    a is b
  contains: (buckets, a, b)->
    a = processValue buckets, a
    b = processValue buckets, b
    a.indexOf(b) >= 0
  greater: (buckets, a, b)->
    a = processValue buckets, a
    b = processValue buckets, b
    parseFloat(a) > parseFloat(b)
  greater_or_equal: (buckets, a, b)->
    a = processValue buckets, a
    b = processValue buckets, b
    parseFloat(a) >= parseFloat(b)
  is_set: (buckets, a, b)->
    hasValue buckets, b

evaluateConditions = (buckets, conditions)->
  result = true

  for condition in conditions
    value = null
    negate = no
    if condition.value?
      value = condition.value
      delete condition.value
    if condition.negate?
      negate = condition.negate
      delete condition.negate

    for opName, argument of condition
      if operators[opName]?
        result = operators[opName](buckets, value, argument)
        if negate
          result = not result
        if not result then break
  return result

# Read settings from yaml files
exports.load = (chain, callback)->
  buckets =
    '<': {}
    '$': process.env
  settings = {}
  load = (file)->
    lib.fs.readFile file, 'utf8', (error, yaml)->
      if error then return callback error

      try
        loaded = []
        # The loadAll function might look asynchronous, but it is
        # not. That's why it's safe to treat it as a loop.
        lib.jsyaml.loadAll yaml, (doc)->
          loaded.push doc

        if loaded.length is 1
          exports.extend settings, loaded[0], buckets
        else
          while loaded.length
            header = loaded.shift()
            doc = loaded.shift()

            exports.extendWithHeader settings, header, doc, buckets
        if chain.length
          load chain.shift()
        else
          callback null, settings
      catch error
        callback error

  # If a single file is provided we wrap it in an array
  if not Array.isArray chain
    chain = [chain]
  load chain.shift()

# Merges an array with settings objects
exports.merge = (chain, buckets)->
  settings = {}
  for object in chain
    exports.extend settings, object
  settings

exports.extendWithHeader = (settings, header, values, buckets)->
  # We only evaluate documents that either fulfills it's conditions
  # or lack conditions in the header
  if not (header and header.conditions?) or evaluateConditions buckets, header.conditions
    # If we have state information in the header we use that
    # to extend the state bucket.
    if header and header.state?
      exports.extend buckets['<'], header.state, buckets
    exports.extend settings, values, buckets

exports.extend = (settings, values, buckets)->
  merge = (key, value)->
    seg = key.split '/'
    ref = settings
    next = ()->
      current = seg.shift()
      append = seg.length and seg[0] is ''
      last = seg.length is 0 or (append and seg.length is 1)

      # Allow wildcarding by using empty path segments
      if current is ''
        seg_copy = seg[0...seg.length]
        fixed_ref = ref
        for k, v of ref
          seg.unshift k
          next()
          ref = fixed_ref
          seg = seg_copy[0...seg_copy.length]
        return

      if last
        if append
          if ref[current]?
            if not Array.isArray ref[current]
              ref[current] = [ref[current]]
            if Array.isArray value
              ref[current] = ref[current].concat value
            else
              ref[current].push value
          else
            ref[current] = [value]
        else
          if typeof ref is 'object' and not Array.isArray ref
            value = processValue buckets, value
            ref[current] = value
      else
        if not ref[current]?
          ref[current] = {}
        ref = ref[current]
        next()
    next()

  for k, v of values
    merge k, v
  