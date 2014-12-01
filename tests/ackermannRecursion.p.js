var output = require('../output')
  ;

var expect = function (result, message) {
  if (!result) {
    console.log("  \033[0;31mFAIL\033[0;0m: " + message);
  } else {
    console.log("  \033[0;32mPASS\033[0;0m: " + message);
  }
};

var keys = function (obj) { return Object.keys(obj).length };

expect(keys(output) === 1, 'only one class is parsed');
expect(output.main, 'main class is parsed');

expect(keys(output.main.vars) === 0, 'no class vars for main');

expect(keys(output.main.funcs) === 2, 'only two functions');
expect(output.main.funcs.main, 'main function');
expect(output.main.funcs.ackermann, 'ackerman function');

var a = output.main.funcs.ackermann;
expect(keys(a.params) === 2, 'ackermann has two params');
expect(a.size === 0, 'offset vars correctly')
