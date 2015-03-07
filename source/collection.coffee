# Collection of ways to write to and read from a buffer

varint = require 'varint'
bufferEqual = require 'buffer-equal'

module.exports = (dragoman) ->
  dragoman.register 'varint',
    read: (buf) ->
      number = varint.decode buf.full() # Read first apearing varint
      buf.trash varint.decode.bytes     # And remove used bytes from buffer
      number
    write: (vars) ->
      number = vars.shift()
      new Buffer varint.encode(number)


  # FIXME: This working is not yet confirmed XD
  dragoman.register 'intBE',
    read: (buf, length) ->
      bytes = if length? then buf.consume(length) else buf.full()
      num = 0
      for byte,i in bytes
        num += byte * Math.pow(256, i)
      return num
    write: (vars, length) ->
      num = vars.shift()
      if num > 255 * Math.pow(256, length)
        throw new Error "Trying to put the numer #{num} in only #{length} bytes!"

      workingNum = num
      bytes = for i in [length...0]
        n = Math.floor workingNum / Math.pow(256, i-1)
        workingNum -= n * Math.pow(256, i-1)
        n
      new Buffer bytes.reverse()


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


  dragoman.register 'nullTerminatedString',
    read: (buf) ->
      buf.nullTerminated (buffer) ->
        buffer.string()
    write: (writer) ->
      writer.nullTerminated (v) ->
        v.string()


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


  ## /Selectors/
  # Had no other way to call them :p
  # They find out how long something has to be, and pas it to the
  # child function to parse it more.

  dragoman.register 'withLength',
    read: (buf, lenFn, gapFn, dataFn) ->
      # GapFn is optional
      if not dataFn?
        dataFn = gapFn
        gapFn = (->)

      # Get the length of the following data
      len = lenFn(buf).claim()
      # Let the gap get some data too, if he wants
      gapFn buf
      # Pass the other data to
      buf.scan dataFn, len
      return undefined

    write: (writer, lenFn, gapFn, dataFn) ->
      gapData = writer.capture gapFn
      dataWithLength = writer.capture dataFn
      lengthData = writer.capture lenFn, [dataWithLength.length]
      Buffer.concat [lengthData, gapData, dataWithLength]


  dragoman.register 'withVarintLength',
    read: (buf, fn) ->
      len = buf.varint().claim()
      buf.scan fn, len
      return undefined

    write: (writer, fn) ->
      dataencoded = writer.capture(fn)
      Buffer.concat [new Buffer(varint.encode dataencoded.length), dataencoded]


  dragoman.register 'nullTerminated',
    read: (buf, fn) ->
      # Seek returns position, scan till there
      len = buf.seek(0)
      buf.scan fn, len
      # Trash the NULL
      buf.trash 1
      return undefined

    write: (writer, fn) ->
      # Run the code to get the result
      result = writer.capture(fn)
      # Terminate it with a 0
      Buffer.concat [result, new Buffer([0x00])]


  dragoman.register 'fixedLength',
    read: (buf, len, fn) ->
      buf.scan fn, len
      return undefined

    write: (writer, len, fn) ->
      result = writer.capture(fn)
      result.copy new Buffer(len) # Limit/expand it to the given size
      return result


  # A value in the stream needs to be the specified value (For static values)
  dragoman.register 'is',
    read: (buf, value) ->
      data = buf.consume(value.length)
      if not bufferEqual(data, value)
        throw new Error "Expected '#{value.toJSON()}' but got '#{data.toJSON()}' :-("
      return undefined
    write: (vars, value) ->
      return value


  # When you've got enough, but the server think not
  dragoman.register 'more',
    read: (buf) ->
      buf.full true
    write: (vars) ->
      varr = vars.shift()
      if not varr?
        return # Just quit
      if varr not instanceof Buffer
        throw new Error 'More needs a buffer!'
      varr
