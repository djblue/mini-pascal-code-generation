// Arithmetic and Logical Instructions

// buffer for statements
var buffer = [];

var add = function (inst) {
  buffer.push(inst);
};

// clear the buffer and get all the buffered instructions
exports.clear = function () {
  var temp = buffer;
  buffer = [];
  return temp;
};

var arith = function (inst) {
  return function ($d, $s, $t) {
    if ($t === undefined) {
      add(inst + ' ' + $d + ', ' + $s);
    } else {
      add(inst + ' ' + $d + ', ' + $s + ', ' + $t);
    }
  };
};

exports.add = arith('add');   // $d = $s + $t
exports.addi = arith('addi'); // $t = $s + SE(i)
exports.and = arith('and');   // $d = $s & $t
exports.or = arith('or');     // $d = $s | $t
exports.div = arith('div');   // lo = $s / $t; hi = $s % $t
exports.mult = arith('mult'); // hi:lo = $s * $t
exports.sub = arith('sub');   // $d = $s - $t
// subi works in mars, but not spim
exports.subi = arith('subi'); // $d = $s - SE(i)

// Comparison Instructions
var comp = function (inst) {
  return function ($d, $s, $t) {
    add(inst + ' ' + $d + ', ' + $s + ', ' + $t);
  };
};

// set equal to
exports.seq = comp('seq');
exports.slt = comp('slt');
exports.sle = comp('sle');
exports.sne = comp('sne');


// Store Instructions
exports.sw = function ($t, $s, i) {
  if (i === undefined) {
    i = 0;
  }
  add('sw ' + $t + ', ' + i + '(' + $s + ')'); // MEM [$s + i]:4 = $t
};

exports.lw = function ($t, $s, i) {
  if (i === undefined) {
    i = 0;
  }
  add('lw ' + $t + ', ' + i + '(' + $s + ')'); // MEM [$s + i]:4 = $t
};

// Data Movement Instructions

exports.mov = function ($d, $s) {
  exports.addi($d, $s, '0');
};

exports.mfhi = function ($d) { // $d = hi
  add('mfhi ' + $d);
};

exports.mflo = function ($d) { // $d = lo
  add('mflo ' + $d);
};

// Misc

exports.label = function (text) {
  add(text + ':')
}

exports.comment = function (text) {
  add('# ' + text);
}

exports.syscall = function () {
  add('syscall');
};


// Branch Instructions

// if ($s == $t) branch to label
exports.beq = function ($s, $t, label) {
  add('beq ' + $s + ', ' + $t + ', ' + label);
};

// Jump Instructions

exports.j = function (label) {
  add('j ' + label);
};

exports.jal = function (label) {
  add('jal ' + label);
};

exports.jr = function () {
  add('jr $ra');
};

exports.nest = function (instructions) {
  buffer = buffer.concat('', instructions.map(function (instruction) {
    return '    ' + instruction;
  }), '');
};
