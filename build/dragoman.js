// Dragoman translator by Michiel Dral 
var Dragoman, Forger, Reader, Writer, basics;

Forger = require('./forger');

basics = require('./collection');

Writer = require("./writer");

Reader = require("./reader");

module.exports = Dragoman = (function() {
  function Dragoman() {
    this.parsers = {};
    this["with"](basics);
  }

  Dragoman.prototype["with"] = function(ext) {
    ext(this);
    return this;
  };

  Dragoman.prototype.register = function(name, fn) {
    return this.parsers[name] = fn;
  };

  Dragoman.prototype.compile = function(fn) {
    var ExtendedForger;
    ExtendedForger = Forger.extend(Object.keys(this.parsers));
    return fn((function(_this) {
      return function() {
        return new ExtendedForger(_this);
      };
    })(this));
  };

  Dragoman.prototype.getWriter = function(thing) {
    return new (Writer.extend(this.parsers))(thing);
  };

  Dragoman.prototype.getReader = function(thing) {
    return new (Reader.extend(this.parsers))(thing);
  };

  return Dragoman;

})();
