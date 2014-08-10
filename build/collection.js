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
  return dragoman.register('is', {
    read: function(buf, value) {
      var data;
      console.log('Value:', value);
      data = buf.consume(value.length);
      if (!bufferEqual(data, value)) {
        throw new Error("Expected '" + value + "' but got '" + data + "' :-(");
      }
      return void 0;
    },
    write: function(vars, value) {
      console.log('Value:', value);
      return value;
    }
  });
};
