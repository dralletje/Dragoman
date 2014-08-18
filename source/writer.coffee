Symbol = require 'symbol'

# Symbol to access the methods
_methods = new Symbol 'Methods to alter the buffer.'
_alter = new Symbol 'Internal alter method.'

module.exports = class Writer
  constructor: (variables) ->
    @boxes = []
    # Root box
    @boxes.push
      buffer: []
      vars: variables

  # Use a variable from the variables
  getVar: ->
    @box().vars.shift()
  shift: @::getVar


  # Sanboxing of data
  box: ->
    @boxes[@boxes.length - 1]
  newBox: (vars) ->
    @boxes.push
      buffer: []
      vars: vars or @box().vars
  delBox: ->
    Buffer.concat @boxes.pop().buffer
  capture: (fn, vars) ->
    @newBox(vars)
    args = fn._arguments or []
    fn this, args...
    @delBox()

  @::[_alter] = (method, args) ->
    buf = @[_methods][method].write this, args...
    if buf instanceof Buffer
      @box().buffer.push buf
    this # Chaining

  flush: ->
    # No idea why I made this.. ^^
    return this

  @extend: (methods) ->
    # Extend the methods allowed to use on the writer
    class ExtendedWriter extends this

    Object.keys(methods).forEach (method) ->
      if ExtendedWriter::[method]?
        throw new Error "Trying to overwrite '#{method}', but it already exists!"
      ExtendedWriter::[method] = (args...) ->
        @[_alter] method, args
    ExtendedWriter::[_methods] = methods

    return ExtendedWriter
