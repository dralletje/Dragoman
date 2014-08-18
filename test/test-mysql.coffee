# Test setup
chai = require 'chai'
should = chai.should()
expect = chai.expect
chai.use require 'chai-as-promised'

# Dragoman setup
Dragoman = require '../'
protocol = require "./mysql-interface"

dragoman = new Dragoman
packets = dragoman.compile protocol

# Begin of minecraft tests
net = require 'net'
Promise = require 'bluebird'
mysql = require 'mysql'

###
connection.query('SELECT 1 + 1 AS solution', function(err, rows, fields) {
  if (err) throw err;
  console.log('The solution is: ', rows[0].solution);
});
connection.end();
###

unpack = (packet, response, to) ->
  info = packet.extract response
  console.log info.slice 0, -1
  newres = packet.build info...
  response.should.deep.equal newres
  to.write newres
  to.suck()
describe "Mysql", ->
  it 'should get connection from localmysql', ->
    new Promise (yell, cry) =>
      @server = net.createServer (connection) =>
        @socketToLocal = connection
        yell()

      @server.listen =>
        port = @server.address().port
        @mysql = mysql.createConnection
          host     : 'localhost'
          port     : port
          user     : 'username'
          password : 'password'
        @mysql.connect()

  it "should connect to and read the handshake from the server", ->
    @socketToServer = net.connect
      port: 3306

    @socketToServer.suck().then (response) =>
      # Initial handshake send from the server
      # Not fully acurate, but handles the most :p
      unpack packets.handshake, response, @socketToLocal

    .then (response) =>
      unpack packets.handshakeResponse41, response, @socketToServer

    .then (response) =>
      console.log response

  after ->
    @server.close()
    @socketToServer.destroy()
    @socketToLocal.destroy()
    @mysql.destroy()





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
