# Test setup
chai = require 'chai'
should = chai.should()
expect = chai.expect
chai.use require 'chai-as-promised'

# Dragoman setup
Dragoman = require '../'
minecraftProtocol = require "./minecraft-interface"

dragoman = new Dragoman
{client, server} = packets = dragoman.compile minecraftProtocol

# Begin of minecraft tests
net = require 'net'
Promise = require 'bluebird'

describe "Minecraft", ->
  it "should create and validate a handshake", ->
    # Create
    # TODO: Make the packet have the 0x00 required itself
    [host, port] = ['deserver.tk', 25565]
    args = [4, host, port, 1]
    handshake = client.handshake.build args...
    # Validate
    client.handshake.extract(handshake).should.deep.equal args

    socket = net.connect
      port: port
      host: host

    .on 'connect', ->
      @write handshake
      @write new Buffer [1, 0] # State 1 status request

    .suck().then (response) ->
      # JSON response
      info = JSON.parse server.state1[0x00].extract(response)[0]


## Additions for awesomeness :-D
EventEmitter = require('events').EventEmitter
EventEmitter::waitFor = (event) ->
  new Promise (resolve, reject) =>
    @once event, (args...) ->
      resolve args[0]
    .once 'error', (err) ->
      reject err

ReadableStream = require('stream').Readable
ReadableStream::suck = ->
  @waitFor('readable').then =>
    data = @read()
    if not data? then throw new Error 'Hey, your stream had ended!'
    data
