// Arithmetic and Logical Instructions

var whileCount = 0;
var ifCount = 0;

module.exports = function (type) {

  var buff = [];

  var add = function (inst) { buff.push(inst); };

  var parseArgs = function (fun) {
    return function () {
      var args = Array.prototype.map.call(arguments, (function (arg) {
        if (arg.register !== undefined) {
          return arg.register;
        } else {
          return arg;
        }
      }));
      fun.apply(null, args);
    }
  };

  var arith = function (inst) {
    return parseArgs(function ($d, $s, $t) {
      if ($t === undefined) {
        add(inst + ' ' + $d + ', ' + $s);
      } else {
        add(inst + ' ' + $d + ', ' + $s + ', ' + $t);
      }
    });
  };

  var comp = function (inst) {
    return parseArgs(function ($d, $s, $t) {
      add(inst + ' ' + $d + ', ' + $s + ', ' + $t);
    });
  };

  var store = function(inst) {
    return parseArgs(function ($t, $s, i) {
      if (i === undefined) i = 0;
      add(inst + ' ' + $t + ', ' + i + '(' + $s + ')');
    });
  };

  var methods = {

    // arithmetic instructions
    add:  arith('add'),   // $d = $s + $t
    addi: arith('addi'),  // $t = $s + SE(i)
    and:  arith('and'),   // $d = $s & $t
    or:   arith('or'),    // $d = $s | $t
    div:  arith('div'),   // lo = $s / $t; hi = $s % $t
    mult: arith('mult'),  // hi:lo = $s * $t
    sub:  arith('sub'),   // $d = $s - $t

    // comparison instructions
    seq: comp('seq'),
    slt: comp('slt'),
    sle: comp('sle'),
    sne: comp('sne'),

    // store Instructions
    sw: store('sw'), // MEM [$s + i]:4 = $t
    lw: store('lw'), // MEM [$s + i]:4 = $t

    // branch instructions
    // if ($s == $t) branch to label
    beq: parseArgs(function ($s, $t, label) {
      add('beq ' + $s + ', ' + $t + ', ' + label); }),

    // data movement instructions
    mov: parseArgs(function ($d, $s) {
      add('add ' + $d +  ', ' + $s + ', $0'); }),

    li: parseArgs(function ($d, c) {
      add('li ' + $d + ', ' + c); }),

     // $d = hi
    mfhi: parseArgs(function ($d) { add('mfhi ' + $d); }),
    // $d = lo
    mflo: parseArgs(function ($d) { add('mflo ' + $d); }),

    // jump Instructions
    j: function (label) { add('j ' + label); },
    jal: function (label) { add('jal ' + label); },
    jr: function () { add('jr $ra'); },

    // misc
    label: function (text) { add(text + ':') },
    comment: function (text) { add('nop # ' + text); },
    syscall: function () { add('syscall'); },

    nest: function (mips) {
      if (mips !== undefined && mips.getInstructions !== undefined) {
        buff = buff.concat('',
          mips.getInstructions().map(function (instruction) {
            return '    ' + instruction;
          }), ''
        );
      } else {
        buff = buff.concat(mips);
      }
    },

    concat: function (mips) {
      if (mips !== undefined) {
        buff = buff.concat(mips.getInstructions());
      }
    },

    // pop last instruction (messy hack but it works)
    pop: function () { buff.pop() }

  };

  // make all methods chain-able

  var chain = function (fun) {
    return function () {
      fun.apply(null, arguments);
      return methods;
    };
  };

  Object.keys(methods).forEach(function (key) {
    methods[key] = chain(methods[key]);
  });

  // non-chain-able methods

  // label generators
  methods.$wh = function () { return 'while_' + whileCount++; };
  methods.$if = function () { return 'if_' + ifCount++; };

  methods.getInstructions =  function () { return buff; };
  methods.join = function () { return buff; };

  methods.print = function () { 
    console.log('\n' + buff.join('\n') + '\n');
  };

  methods.bug = function () {
    process.stderr.write(JSON.stringify({
      meta: methods,
      inst: buff
    }, null, 2) + '\n');
  };

  methods.type = type;

  return methods;

};
