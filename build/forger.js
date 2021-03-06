// Dragoman translator by Michiel Dral 
var Forger,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

module.exports = Forger = (function() {
  function Forger(dragoman, fn, variables) {
    this.dragoman = dragoman;
    this.fn = fn || '';
    this.variables = variables || [];
    this.bytecode = void 0;
  }

  Forger.prototype.compile = function() {
    var e, i, variablesString;
    variablesString = 'buffer' + ((function() {
      var _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = this.variables.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push(', _v' + (i + 1));
      }
      return _results;
    }).call(this)).join('');
    try {
      this.bytecode || (this.bytecode = new Function(variablesString, "return buffer" + this.fn + ".flush()"));
    } catch (_error) {
      e = _error;
      throw new Error("Couldn\'t compile function: " + e.message + "\n(" + variablesString + ") -> \n  return buffer" + this.fn + ".flush()\"");
    }
    this.bytecode._arguments = this.variables;
    return this.bytecode;
  };

  Forger.prototype.add = function(method, args) {
    var argNames;
    argNames = args.map(this.compileArgument).map((function(_this) {
      return function(arg) {
        if (['string', 'number'].indexOf(typeof arg) !== -1) {
          return JSON.stringify(arg);
        }
        _this.variables.push(arg);
        return '_v' + _this.variables.length;
      };
    })(this));
    this.fn += "." + method + "(" + (argNames.join(', ')) + ")";
    return this;
  };

  Forger.prototype.compileArgument = function(arg) {
    if (arg.compile != null) {
      return arg.compile();
    } else {
      return arg;
    }
  };


  /* Comment out till you need them
   * Return a new forger with the two formula's concatted
  concat: (other) ->
    new Forger @fn+other.fn
   * Return a function that creates a copy of this
  blueprint: ->
    =>
      new this.constructor @fn, @variables
   */

  Forger.prototype.build = function(vars) {
    var fn, res, writer;
    writer = this.dragoman.getWriter(vars.slice(0));
    fn = this.compile();
    res = writer.capture(fn);
    if (vars.rest != null) {
      return Buffer.concat([res, vars.rest]);
    } else {
      return res;
    }
  };

  Forger.prototype.extract = function(buffer, strict) {
    var fn, reader;
    reader = this.dragoman.getReader(buffer);
    fn = this.compile();
    return reader.scan(fn, void 0, strict);
  };

  Forger.extend = function(methods) {
    var ExtendedForger;
    ExtendedForger = (function(_super) {
      __extends(ExtendedForger, _super);

      function ExtendedForger() {
        return ExtendedForger.__super__.constructor.apply(this, arguments);
      }

      return ExtendedForger;

    })(this);
    methods.forEach(function(method) {
      if (ExtendedForger.prototype[method] != null) {
        throw new Error("Trying to overwrite '" + method + "', but it already exists!");
      }
      return ExtendedForger.prototype[method] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.add(method, args);
      };
    });
    return ExtendedForger;
  };

  return Forger;

})();
