### Consumable buffer
# Just like a normal buffer, except that it
# will destroy all bytes your read, so you can
# can keep reading from the start.
###

Symbol = require 'symbol'

# Symbol to access the methods
_methods = new Symbol 'Methods to rea the buffer.'

module.exports = class Reader
  constructor: (buffer) ->
    @boxes = [buffer]
    @vars = []

  # Use bytes from the buffer
  trash: (len=1) ->
    @boxes[@boxes.length - 1] = @full().slice len
    return this
  peek: (len=1) ->
    @full().slice 0, len
  consume: (len=1) ->
    piece = @peek len
    @trash len
    return piece
  full: (consume) ->
    f = @boxes[@boxes.length - 1]
    if consume? then @trash f.length
    return f

  # Start reading the buffer using fn
  scan: (fn, len) ->
    if len?
      # Maak nieuwe box met slice van actuale box
      @boxes.push @full().slice 0, len
      # Verwijder wat je in de nieuwe box hebt gestopt van de actuale
      @boxes[@boxes.length - 2] = @boxes[@boxes.length - 2].slice len
    args = fn._arguments or []
    fn this, args...
    if len?
      if @full().length isnt 0
        throw new Error 'Buffer not fully consumed, hmmm'
      @boxes.pop()

    return @vars

  flush: ->
    # Again, I don't know!

  # To let the reader know you need to variable, not the end user :p
  claim: ->
    @vars.pop()

  getUsing: (method, args) ->
    v = @[_methods][method].read this, args...
    if v? and v isnt this
      @vars.push v
    this # Chaining


  @extend: (methods) ->
    # Extend the methods allowed to use on the writer
    class ExtendedReader extends Reader

    Object.keys(methods).forEach (method) ->
      if ExtendedReader::[method]?
        throw new Error "Trying to overwrite '#{method}', but it already exists!"
      ExtendedReader::[method] = (args...) ->
        @getUsing method, args
    ExtendedReader::[_methods] = methods

    return ExtendedReader
