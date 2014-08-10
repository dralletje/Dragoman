net = require 'net'
Promise = require 'bluebird'
varint = require('varint')

# :-D
EventEmitter = require('events').EventEmitter
EventEmitter::waitFor = (event) ->
  new Promise (resolve, reject) =>
    @once event, (args...) ->
      resolve args[0]
    .once 'error', (err) ->
      reject err

ReadableStream = require('stream').Readable
ReadableStream::suck = () ->
  @waitFor('readable').then () =>
    data = @read()
    if not data? then throw new Error 'Hey, your stream had ended!'
    data

minecraftString = (string) ->
  Buffer.concat [new Buffer(varint.encode string.length), new Buffer string]

module.exports.ping = (host, port=25565) ->
  server = net.connect
    port: port
    host: host

  server.on 'connect', ->
    packetId   = new Buffer varint.encode 0
    version    = new Buffer varint.encode 4
    hostString = minecraftString host
    portString = new Buffer 2
    portString.writeUInt16BE port, 0
    state      = new Buffer varint.encode 1

    data = Buffer.concat [packetId, version, hostString, portString, state]
    @write Buffer.concat [new Buffer(varint.encode data.length), data]
    @write new Buffer [1, 0]

  .suck().then (res) ->
    console.log '^^'
    if res[0] isnt 255
      throw new Error "No motd recieved!"
    res = res.slice 1

    length = res[1]
    res = res.slice 1

    motd = res.slice 0, length
    res = res.slice length
    console.log motd.toString()

    console.log res.slice(3).toString()

if not module.parent
  console.log process.argv[2], process.argv[3]
  module.exports.ping process.argv[2], process.argv[3]
