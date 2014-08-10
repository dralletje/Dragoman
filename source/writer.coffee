Symbol = require 'symbol'

# Symbol to access the methods
_methods = new Symbol 'Methods to alter the buffer.'

module.exports = class Writer
  constructor: (variables) ->
    @variables = variables
    @bufs = []
    @boxes = []

  # Use a variable from the variables
  getVar: ->
    @variables.shift()
  shift: @::getVar


  # Sanboxing of data
  newBox: ->
    @boxes.push []
  delBox: ->
    Buffer.concat @boxes.pop()
  capture: (fn) ->
    @newBox()
    args = fn._arguments or []
    fn this, args...
    @delBox()

  alter: (method, args) ->
    buf = @[_methods][method].write this, args...
    if buf instanceof Buffer
      # If a box is set, write to it. Else write to 'root box'
      box = @boxes[@boxes.length - 1] ?= @bufs
      box.push buf
    this # Chaining

  flush: ->
    # No idea why I made this.. ^^

  @extend: (methods) ->
    # Extend the methods allowed to use on the writer
    class ExtendedWriter extends Writer

    Object.keys(methods).forEach (method) ->
      if ExtendedWriter::[method]?
        throw new Error "Trying to overwrite '#{method}', but it already exists!"
      ExtendedWriter::[method] = (args...) ->
        @alter method, args
    ExtendedWriter::[_methods] = methods

    return ExtendedWriter
