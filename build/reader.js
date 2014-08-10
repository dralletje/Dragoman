// Dragoman translator by Michiel Dral 

/* Consumable buffer
 * Just like a normal buffer, except that it
 * will destroy all bytes your read, so you can
 * can keep reading from the start.
 */
var Reader, Symbol, _methods,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Symbol = require('symbol');

_methods = new Symbol('Methods to rea the buffer.');

module.exports = Reader = (function() {
  function Reader(buffer) {
    this.boxes = [buffer];
    this.vars = [];
  }

  Reader.prototype.trash = function(len) {
    if (len == null) {
      len = 1;
    }
    this.boxes[this.boxes.length - 1] = this.full().slice(len);
    return this;
  };

  Reader.prototype.peek = function(len) {
    if (len == null) {
      len = 1;
    }
    return this.full().slice(0, len);
  };

  Reader.prototype.consume = function(len) {
    var piece;
    if (len == null) {
      len = 1;
    }
    piece = this.peek(len);
    this.trash(len);
    return piece;
  };

  Reader.prototype.full = function(consume) {
    var f;
    f = this.boxes[this.boxes.length - 1];
    if (consume != null) {
      this.trash(f.length);
    }
    return f;
  };

  Reader.prototype.scan = function(fn, len) {
    var args;
    if (len != null) {
      this.boxes.push(this.full().slice(0, len));
      this.boxes[this.boxes.length - 2] = this.boxes[this.boxes.length - 2].slice(len);
    }
    args = fn._arguments || [];
    fn.apply(null, [this].concat(__slice.call(args)));
    if (len != null) {
      if (this.full().length !== 0) {
        throw new Error('Buffer not fully consumed, hmmm');
      }
      this.boxes.pop();
    }
    return this.vars;
  };

  Reader.prototype.flush = function() {};

  Reader.prototype.claim = function() {
    return this.vars.pop();
  };

  Reader.prototype.getUsing = function(method, args) {
    var v, _ref;
    v = (_ref = this[_methods][method]).read.apply(_ref, [this].concat(__slice.call(args)));
    if ((v != null) && v !== this) {
      this.vars.push(v);
    }
    return this;
  };

  Reader.extend = function(methods) {
    var ExtendedReader;
    ExtendedReader = (function(_super) {
      __extends(ExtendedReader, _super);

      function ExtendedReader() {
        return ExtendedReader.__super__.constructor.apply(this, arguments);
      }

      return ExtendedReader;

    })(Reader);
    Object.keys(methods).forEach(function(method) {
      if (ExtendedReader.prototype[method] != null) {
        throw new Error("Trying to overwrite '" + method + "', but it already exists!");
      }
      return ExtendedReader.prototype[method] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.getUsing(method, args);
      };
    });
    ExtendedReader.prototype[_methods] = methods;
    return ExtendedReader;
  };

  return Reader;

})();
