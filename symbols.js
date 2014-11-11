// the only evil global
var _ = require('underscore')
  , classes = exports.classes = {}
  , cl = null // current class
  , fn = null // current function
  ;

// bailing out, good luck
var fatal = function (message) {
  console.log('ERROR:' + message);
  process.exit(2);
};

// make sure the names aren't clobbering each other
var fatalIfDefined = function (symbol) {
  if (symbol !== undefined) {
    fatal('symbol "'+ symbol + '" already defined.');
  };
};


// add instance/local variables
// name - name of variable
// denoter - type of variable
exports.addVariable = function (name, denoter) {

  if (fn !== null) {
    var scope = fn;
  } else {
    var scope = cl;
  }

  var offset = scope.size;
  var variable = scope.vars[name] = {};
  variable.name = name;
  variable.offset = scope.size;
  variable.denoter = _.clone(denoter);

  if (fn !== null) {
    variable.isLocal = true;
  } else {
    variable.isInstance = true;
  }

  if (denoter.type === 'class') {
    // reference variable only take up 4 bytes
    scope.size += 4;
  } else {
    scope.size += denoter.size;
  }

};

// add a method to a class
// name - the name of the function
// params - array of type denoters
// returns - the type denoter of the return variable
exports.addMethod = function (name, denoterId) {

  fatalIfDefined(cl.funcs[name]);

  fn = cl.funcs[name] = {
    name: name,
    params: {},
    denoter: exports.getDenoter(denoterId),
    vars: {},
    label: cl.name + '_' + name,
    size: 0,
    instructions: [],
    getStackSize: function () {
      return this.size;
    },
    addParam: function (name, denoter) {
      var offset = this.size;
      var param = this.params[name] = {};
      param.name = name;
      param.denoter = _.clone(denoter);
      param.offset = offset;
      param.isLocal = true;
      fn.size += denoter.size;
      return offset;
    },
    addInstructions: function (instList) {
      this.instructions = instList;
    }
  };

  return fn;
};

exports.getMethod = function (name, klass) {
  if (klass !== undefined) {
    return classes[klass].funcs[name];
  } else {
    return cl.funcs[name];
  }
};

// name - name of class to add
// parent - name of parent class
exports.addClass = function (name, parent) {

  fatalIfDefined(classes[name]);

  cl = classes[name] = {
    name: name,
    parent: parent,
    funcs: {},
    vars: {}
  };

  // starting new class, not in a function
  fn = null;

  var parent = classes[parent];

  // set size of class based on parent
  if (parent !== undefined) {
    cl.size = parent.size;
  } else {
    cl.size = 0;
  }

};

// get the size of a class
exports.getSize = function (name) {
  return classes[name].size;
};

// get variable by name
// name - name of variable to look up
// klass - optional class name, if provided
//  will look up "name" in class.
exports.lookup = function (name, klass) {
  // name is current function name
  if (name === fn.name) {
    return {
      isResult: true,
      name: name,
      denoter: fn.denoter
    };
  // search parent for fields
  } else if (klass != undefined) {
    klass = classes[klass];
    return klass.vars[name] ||
      exports.lookup(name, klass.parent);
  } else {
    return fn.params[name] || fn.vars[name] || cl.vars[name];
  }
};

// get the type denote by type name
exports.getDenoter = function (name) {
  if (name === 'integer' || name === 'boolean') {
    return {
      type: 'primitive',
      name: name,
      size: 4
    };
  }
};