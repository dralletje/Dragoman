// Dragoman translator by Michiel Dral 
var Symbol, Writer, _methods,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Symbol = require('symbol');

_methods = new Symbol('Methods to alter the buffer.');

module.exports = Writer = (function() {
  function Writer(variables) {
    this.variables = variables;
    this.bufs = [];
    this.boxes = [];
  }

  Writer.prototype.getVar = function() {
    return this.variables.shift();
  };

  Writer.prototype.shift = Writer.prototype.getVar;

  Writer.prototype.newBox = function() {
    return this.boxes.push([]);
  };

  Writer.prototype.delBox = function() {
    return Buffer.concat(this.boxes.pop());
  };

  Writer.prototype.capture = function(fn) {
    var args;
    this.newBox();
    args = fn._arguments || [];
    fn.apply(null, [this].concat(__slice.call(args)));
    return this.delBox();
  };

  Writer.prototype.alter = function(method, args) {
    var box, buf, _base, _name, _ref;
    buf = (_ref = this[_methods][method]).write.apply(_ref, [this].concat(__slice.call(args)));
    if (buf instanceof Buffer) {
      box = (_base = this.boxes)[_name = this.boxes.length - 1] != null ? _base[_name] : _base[_name] = this.bufs;
      box.push(buf);
    }
    return this;
  };

  Writer.prototype.flush = function() {};

  Writer.extend = function(methods) {
    var ExtendedWriter;
    ExtendedWriter = (function(_super) {
      __extends(ExtendedWriter, _super);

      function ExtendedWriter() {
        return ExtendedWriter.__super__.constructor.apply(this, arguments);
      }

      return ExtendedWriter;

    })(Writer);
    Object.keys(methods).forEach(function(method) {
      if (ExtendedWriter.prototype[method] != null) {
        throw new Error("Trying to overwrite '" + method + "', but it already exists!");
      }
      return ExtendedWriter.prototype[method] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.alter(method, args);
      };
    });
    ExtendedWriter.prototype[_methods] = methods;
    return ExtendedWriter;
  };

  return Writer;

})();
