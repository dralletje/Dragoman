### Consumable buffer
# Just like a normal buffer, except that it
# will destroy all bytes your read, so you can
# can keep reading from the start.
###

Symbol = require 'symbol'

# Symbol to access the methods
_methods = new Symbol 'Methods to read explorer the buffer.'
_getUsing = new Symbol 'The internal _getUsing method.'

module.exports = class Reader
  constructor: (buffer, @opts) ->
    @boxes = [buffer]
    @vars = []

  ### Use bytes from the buffer ###
  # Remove the first x bytes
  trash: (len=1) ->
    @boxes[@boxes.length - 1] = @full().slice len
    return this
  # Get the first x bytes
  peek: (len=1) ->
    @full().slice 0, len
  # get the first x bytes, and remove them
  consume: (len=1) ->
    piece = @peek len
    @trash len
    return piece
  # Get the full upcoming buffer
  full: (consume) ->
    f = @boxes[@boxes.length - 1]
    if consume? then @trash f.length
    return f

  # Seek the position of the byte that fullfils the requirement
  seek: (fn) ->
    if fn not instanceof Function
      _fn = fn
      fn = (k) -> k is _fn
    place = 0
    for byte,i in @full()
      if fn(byte)
        break
      place++
    return place

  ## Start reading the buffer
  # fn: Function that describes the buffer
  # len (undefined): Only allow the function to this part of the buffer
  # strictMode (true): Throw an error when the buffer is not fully consumed
  scan: (fn, len, strictMode=true) ->
    # If it is to parse a slice, create new 'box'
    if len?
      # Create new box
      @boxes.push @full().slice 0, len
      # Remove slice of new box from current one
      @boxes[@boxes.length - 2] = @boxes[@boxes.length - 2].slice len

    # When arguments are set, use them
    args = fn._arguments or []
    # To execute the just compiled function
    fn this, args...

    # If the buffer is not fully consumed, let them know
    if strictMode  and  @full().length isnt 0
      throw new Error 'Buffer not fully consumed, hmmm.'

    # If it was a new box, remove the box (it should be empty)
    if len?
      @boxes.pop()

    return @vars

  # Ran at the end of a scan chain, maybe usefull later
  flush: ->
    return this

  # Used by read functions only:
  # It gets the latest variable added, and removes it from the list
  claim: ->
    @vars.pop()

  # Invoked by the compiled function, well, indirectly.
  # They are invoked with .<method>(args...) and then passed here.
  # It just executes the code linked to that method
  @::[_getUsing] = (method, args) ->
    v = @[_methods][method].read this, args...
    if v? and v isnt this
      @vars.push v
    this # Chaining

  # Extend the reader with a set of methods
  # Just creates a new class and adds all methods, linking to
  # _getUsing, to the prototype.
  @extend: (methods) ->
    class ExtendedReader extends Reader

    Object.keys(methods).forEach (method) ->
      if ExtendedReader::[method]?
        throw new Error "Trying to overwrite '#{method}', but it already exists!"
      ExtendedReader::[method] = (args...) ->
        @[_getUsing] method, args
    ExtendedReader::[_methods] = methods

    return ExtendedReader
