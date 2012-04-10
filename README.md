HUWSettings
===========

HUWSettings is a library for loading settings files with a path-inspired system for overriding and extending settings, support for environment and state variables and conditional settings documents. The functionality is best explained by example.

    lib =
      huwsettings: require 'huwsettings'
    lib.huwsettings.load ['settings.default.yaml', 'settings.yaml', 'settings.env.yaml'], (error, settings)->
      console.log JSON.stringify settings, null, 2

That snippet loads the following files in sequence:

### settings.default.yaml ###

    data_dir: data
    value_turning_multiple: 10
    tmp_dir: tmp
    complex:
      - name: hello
        age: 12
      - name: world
        age: 20
    foo:
      bar: bar
      baz: baz
    some_dirs:
      - data/sample
    replace_this_list:
      - 12
      - 56

### settings.yaml ###

    # Simple attribute replacement
    data_dir: awesome_data
    foo/bar: hello world
    # Add new elements and mix and match flat & nested structure
    arbitrary/number: 56
    arbitrary/text: hello
    arbitrary/complex:
      some: info
      about: setting
    # The items in this array will be appended to the default
    # items.
    some_dirs/:
      - data/sample
    # The value in the default settings file is not an array
    # but will be wrapped in one to allow append.
    value_turning_multiple/:
      - 20
      - 5
    # Without a trailing slash the array will be replaced.
    replace_this_list:
      - 120
      - 560
    # Appending an object
    complex/:
      name: hugo
      age: 30
    # Add the attribute valid to all objects in complex
    complex//valid: you bet
    # Overwrites are possible within one file
    some:
      conf: foobar
    some/conf: necktie
    obj: 2
    # Add an attribute to all top level elements
    /valid: value

### settings.env.yaml ###

    ---
    # If we're using headers then every document needs a header.
    # If the first document doesn't actually have a header then
    # a leading document is needed, now it's just included as
    # an example
    state:
      some_value: foobar
      editor: $EDITOR
    ---
    shell: $SHELL
    editor: <editor
    foo/baz: $LC_CTYPE
    state_value: <some_value
    literal: $$literal string starting with a dollar sign
    another_literal: <<literal string starting with a less than sign
    your_shell:
      extra_comment: No comment
    ---
    conditions:
      - value: $SHELL
        contains: zsh
    state:
      known_shell: yes
    ---
    your_shell/comment: "You are running zsh, good for you!"
    ---
    conditions:
      - value: $SHELL
        is: /bin/bash
    state:
      known_shell: yes
    ---
    your_shell/comment: "You are running bash, good for you!"
    ---
    conditions:
      - is_set: <known_shell
        negate: yes
    ---
    your_shell/comment: "I don't know what shell you're running, but whatever works for you."
    ---
    conditions:
      - is_set: <known_shell
    ---
    your_shell/extra_comment: "I'm glad to see that you're running a shell that I know how to use."

### End result ###

---
    data_dir: "awesome_data"
    value_turning_multiple: 
      - 10
      - 20
      - 5
    tmp_dir: "tmp"
    complex: 
      - 
        name: "hello"
        age: 12
        valid: "you bet"
      - 
        name: "world"
        age: 20
        valid: "you bet"
      - 
        name: "hugo"
        age: 30
        valid: "you bet"
    foo: 
      bar: "hello world"
      baz: "sv_SE.UTF-8"
      valid: "value"
    some_dirs: 
      - "data/sample"
      - "data/sample"
    replace_this_list: 
      - 120
      - 560
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
    shell: "/bin/zsh"
    editor: "mate -w"
    literal: "$literal string starting with a dollar sign"
    another_literal: "<literal string starting with a less than sign"
    state_value: "foobar"
    your_shell: 
      extra_comment: "I'm glad to see that you're running a shell that I know how to use."
      comment: "You are running zsh, good for you!"
