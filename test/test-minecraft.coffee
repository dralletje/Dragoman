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

    console.log args
    # Validate
    client.handshake.extract(handshake, false).should.deep.equal args
