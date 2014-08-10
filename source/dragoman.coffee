Forger = require './forger'
basics = require './collection'

Writer = require "./writer"
Reader = require "./reader"

module.exports = class Dragoman
  constructor: ->
    # {Name: {read: fn*, write: fn*}}
    @parsers = {}
    # Register the basics
    @with basics

  # Add an extension
  with: (ext) ->
    ext(this)
    this

  # Register a parser function for the forger
  register: (name, fn) ->
    @parsers[name] = fn

  # Run the function with the parsers inside, this way compile them
  compile: (fn) ->
    ExtendedForger = Forger.extend Object.keys(@parsers)
    fn =>
      new ExtendedForger this


  # Get writer and reader instances
  getWriter: (thing) ->
    new (Writer.extend(@parsers)) thing
  getReader: (thing) ->
    new (Reader.extend(@parsers)) thing
