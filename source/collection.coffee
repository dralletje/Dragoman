# Collection of ways to write to and read from a buffer

varint = require 'varint'
bufferEqual = require 'buffer-equal'

module.exports = (dragoman) ->
  dragoman.register 'varint',
    read: (buf) ->
      number = varint.decode buf.full() # Read first apearing varint
      buf.trash varint.decode.bytes   # And remove used bytes from buffer
      number
    write: (vars) ->
      number = vars.shift()
      new Buffer varint.encode(number)


  dragoman.register 'string',
    read: (buf) -> # Read string to end
      buf.full(true).toString()
    write: (vars) ->
      new Buffer vars.shift()


  dragoman.register 'varString',
    read: (buf) ->
      buf.withVarintLength (buffer) ->
        buffer.string()
    write: (writer) ->
      writer.withVarintLength (v) ->
        v.string()


  dragoman.register 'withVarintLength',
    read: (buf, fn) ->
      len = buf.varint().claim()
      buf.scan fn, len
      return undefined

    write: (writer, fn) ->
      dataencoded = writer.capture(fn)
      Buffer.concat [new Buffer(varint.encode dataencoded.length), dataencoded]


  dragoman.register 'UInt16BE',
    read: (buf) ->
      f = buf.full().readUInt16BE(0)
      buf.trash(2)
      return f
    write: (vars) ->
      number = vars.shift()
      buf = new Buffer 2
      buf.writeUInt16BE number, 0
      return buf

  # A value in the stream needs to be the specified value (For static values)
  dragoman.register 'is',
    read: (buf, value) ->
      console.log 'Value:', value
      data = buf.consume(value.length)
      if not bufferEqual(data, value)
        throw new Error "Expected '#{value}' but got '#{data}' :-("
      return undefined
    write: (vars, value) ->
      console.log 'Value:', value
      return value
