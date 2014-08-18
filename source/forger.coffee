module.exports = class Forger
  constructor: (dragoman, fn, variables) ->
    @dragoman = dragoman
    @fn = fn or ''
    @variables = variables or []
    @bytecode = undefined # I know it is not real bytecode :p

  # Compile this object into a function
  compile: ->
    # Create variable string eg: (buffer, v1, v2, v3) { ... }
    variablesString = 'buffer' + (', _v'+(i+1) for i in [0...@variables.length]).join ''
    try
      @bytecode ||=
        new Function variablesString, "return buffer#{@fn}.flush()"
    catch e
      throw new Error """
        Couldn\'t compile function: #{e.message}
        (#{variablesString}) -> \n  return buffer#{@fn}.flush()"
      """

    @bytecode._arguments = @variables
    @bytecode

  # Add another function to the chain
  add: (method, args) ->
    argNames = args.map(@compileArgument).map (arg) =>
      if ['string', 'number'].indexOf(typeof arg) isnt -1
        return JSON.stringify arg

      @variables.push arg
      '_v' + @variables.length
    @fn += ".#{method}(#{argNames.join(', ')})"
    return this

  compileArgument: (arg) ->
    if arg.compile? then arg.compile() else arg

  ### Comment out till you need them
  # Return a new forger with the two formula's concatted
  concat: (other) ->
    new Forger @fn+other.fn
  # Return a function that creates a copy of this
  blueprint: ->
    =>
      new this.constructor @fn, @variables
  ###

  # Build or extract the packet
  build: (vars...) ->
    writer = @dragoman.getWriter vars
    fn = @compile()
    writer.capture(fn)

  extract: (buffer) ->
    reader = @dragoman.getReader buffer
    fn = @compile()
    reader.scan(fn)


  @extend: (methods) ->
    # Extend the methods allowed to use on the forger
    class ExtendedForger extends this
    methods.forEach (method) ->
      if ExtendedForger::[method]?
        throw new Error "Trying to overwrite '#{method}', but it already exists!"
      ExtendedForger::[method] = (args...) ->
        @add method, args

    return ExtendedForger
