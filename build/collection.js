// Dragoman translator by Michiel Dral 
var bufferEqual, varint;

varint = require('varint');

bufferEqual = require('buffer-equal');

module.exports = function(dragoman) {
  dragoman.register('varint', {
    read: function(buf) {
      var number;
      number = varint.decode(buf.full());
      buf.trash(varint.decode.bytes);
      return number;
    },
    write: function(vars) {
      var number;
      number = vars.shift();
      return new Buffer(varint.encode(number));
    }
  });
  dragoman.register('intBE', {
    read: function(buf, length) {
      var byte, bytes, i, num, _i, _len;
      bytes = length != null ? buf.consume(length) : buf.full();
      num = 0;
      for (i = _i = 0, _len = bytes.length; _i < _len; i = ++_i) {
        byte = bytes[i];
        num += byte * Math.pow(256, i);
      }
      return num;
    },
    write: function(vars, length) {
      var bytes, i, n, num, workingNum;
      num = vars.shift();
      if (num > 255 * Math.pow(256, length)) {
        throw new Error("Trying to put the numer " + num + " in only " + length + " bytes!");
      }
      workingNum = num;
      bytes = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = length; length <= 0 ? _i < 0 : _i > 0; i = length <= 0 ? ++_i : --_i) {
          n = Math.floor(workingNum / Math.pow(256, i - 1));
          workingNum -= n * Math.pow(256, i - 1);
          _results.push(n);
        }
        return _results;
      })();
      return new Buffer(bytes.reverse());
    }
  });
  dragoman.register('string', {
    read: function(buf) {
      return buf.full(true).toString();
    },
    write: function(vars) {
      return new Buffer(vars.shift());
    }
  });
  dragoman.register('varString', {
    read: function(buf) {
      return buf.withVarintLength(function(buffer) {
        return buffer.string();
      });
    },
    write: function(writer) {
      return writer.withVarintLength(function(v) {
        return v.string();
      });
    }
  });
  dragoman.register('nullTerminatedString', {
    read: function(buf) {
      return buf.nullTerminated(function(buffer) {
        return buffer.string();
      });
    },
    write: function(writer) {
      return writer.nullTerminated(function(v) {
        return v.string();
      });
    }
  });
  dragoman.register('UInt16BE', {
    read: function(buf) {
      var f;
      f = buf.full().readUInt16BE(0);
      buf.trash(2);
      return f;
    },
    write: function(vars) {
      var buf, number;
      number = vars.shift();
      buf = new Buffer(2);
      buf.writeUInt16BE(number, 0);
      return buf;
    }
  });
  dragoman.register('withLength', {
    read: function(buf, lenFn, gapFn, dataFn) {
      var len;
      if (dataFn == null) {
        dataFn = gapFn;
        gapFn = (function() {});
      }
      len = lenFn(buf).claim();
      gapFn(buf);
      buf.scan(dataFn, len);
      return void 0;
    },
    write: function(writer, lenFn, gapFn, dataFn) {
      var dataWithLength, gapData, lengthData;
      gapData = writer.capture(gapFn);
      dataWithLength = writer.capture(dataFn);
      lengthData = writer.capture(lenFn, [dataWithLength.length]);
      return Buffer.concat([lengthData, gapData, dataWithLength]);
    }
  });
  dragoman.register('withVarintLength', {
    read: function(buf, fn) {
      var len;
      len = buf.varint().claim();
      buf.scan(fn, len);
      return void 0;
    },
    write: function(writer, fn) {
      var dataencoded;
      dataencoded = writer.capture(fn);
      return Buffer.concat([new Buffer(varint.encode(dataencoded.length)), dataencoded]);
    }
  });
  dragoman.register('nullTerminated', {
    read: function(buf, fn) {
      var len;
      len = buf.seek(0);
      buf.scan(fn, len);
      buf.trash(1);
      return void 0;
    },
    write: function(writer, fn) {
      var result;
      result = writer.capture(fn);
      return Buffer.concat([result, new Buffer([0x00])]);
    }
  });
  dragoman.register('fixedLength', {
    read: function(buf, len, fn) {
      buf.scan(fn, len);
      return void 0;
    },
    write: function(writer, len, fn) {
      var result;
      result = writer.capture(fn);
      result.copy(new Buffer(len));
      return result;
    }
  });
  dragoman.register('is', {
    read: function(buf, value) {
      var data;
      data = buf.consume(value.length);
      if (!bufferEqual(data, value)) {
        throw new Error("Expected '" + (value.toJSON()) + "' but got '" + (data.toJSON()) + "' :-(");
      }
      return void 0;
    },
    write: function(vars, value) {
      return value;
    }
  });
  return dragoman.register('more', {
    read: function(buf) {
      return buf.full(true);
    },
    write: function(vars) {
      var varr;
      varr = vars.shift();
      if (varr == null) {
        return;
      }
      if (!(varr instanceof Buffer)) {
        throw new Error('More needs a buffer!');
      }
      return varr;
    }
  });
};
