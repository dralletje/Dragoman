varint = require('varint').encode

module.exports = (b) ->
  handshake:
    # Header
    b().withLength b().intBE(3), # Length
      b().intBE(1), # Gap for secuence ID

      # Payload
      b().is(new Buffer [0x0a]).nullTerminatedString().intBE(4)
      .fixedLength(8, b().string()).is(new Buffer [0x00])
      .intBE(2).intBE(1).intBE(2).intBE(2).intBE(1)
      .more()

  handshakeResponse41:
    # Header
    b().withLength b().intBE(3), # Length
      b().intBE(1), # Gap for secuence ID

      # Payload
      b().intBE(4).intBE(4).intBE(1)
      .fixedLength(23, b().string())
      .nullTerminatedString().more()
