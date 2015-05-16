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
    args.rest = Buffer([0,1])
    handshake = client.handshake.build args

    buf = new Buffer [17, 0, 4, 11, 100, 101, 115, 101, 114, 118, 101, 114, 46, 116, 107, 99, 221, 1, 0, 1 ]

    # Validate
    handshake.should.deep.equal buf
    client.handshake.extract(handshake, false).should.deep.equal args
