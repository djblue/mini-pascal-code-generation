var mips = require('./mips');

// registers
var $zero = '$0'

// stack pointer
  , $sp = '$sp'
  , $fp = '$fp'
  , $a0 = '$a0'
  , $v0 = '$v0'
  , $s0 = '$s0' // this context (base address of object)
  , $s1 = '$s1' // temp variable address
  , $s2 = '$s2' // temp conditional eval register
  , $ra = '$ra'
  ;

var regCount = 0;
// get next temporary register available
exports.$t = function (mips) {
  if (regCount < 10) {
    return '$t' + regCount++;
  } else {
    var reg = regCount++ % 10;
    mips.addi($sp, $sp, -4);
    mips.sw('$t' + reg, $sp);
    return '$t' + reg;
  }
};

// backup registers to stack
exports.regBackup = function () {

  var inst = mips('backup');

  // allocate space on the stack (+1 for $ra)
  if (regCount > 0) {
    inst
      .comment('backing up registers to the stack')
      .addi($sp, $sp, -4 * regCount)
      ;
    // backup temps
    for (var i = 0; i < regCount; i++) {
      inst.sw('$t'+i, $sp, i*4);
    }
    regCount = 0;
  }

  // unload stack back into registers
  inst.mips = function () {
    
    var undo = mips('undo');

    if (i > 0) {
      regCount = i;
      undo
        .comment('restoring registers from the stack')
      i--;
      for (; i >= 0; i--) {
        undo.lw('$t'+i, $sp, i*4);
      }
      undo.addi($sp, $sp, 4 * regCount);
    }

    return undo;

  };

  return inst;
};

// release register
exports.release = function (reg, mips) {
  if (reg && reg.match(/^\$t\d$/)) {
    if (regCount < 9) {
      regCount--;
    } else {
      var reg = --regCount % 10;
      mips.lw('$t' + reg, $sp);
      mips.addi($sp, $sp, 4);
    }
  }
};
