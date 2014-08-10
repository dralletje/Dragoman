varint = require('varint').encode

module.exports = (start) ->
  client:
    handshake: # Eerst even zonder
      start().withVarintLength start().is(new Buffer varint 0x00).varint().varString().UInt16BE().varint()

  server:
    state1: # Ping state
      0x00: start().withVarintLength start().is(new Buffer varint 0x00).varString()
