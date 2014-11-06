%{
  var mips = require('./mips');/*{{{*//*}}}*/
  var _ = require('underscore');

  // context variables
  var currentClass = null;
  var currentFunction = null;
  var currentType = null;
  var currentId = null;

  var symbols = {};

  var stackSize = function (fn) {
    var cl = currentClass.name;
    if (symbols[cl][fn]) {
      return symbols[cl][fn]._offset;
    } else {
      return 0;
    }
  };

  var symbolOffset = 0;

  // add symbol to the current context
  var addSymbol = function (name, denoter) {
    var cl = currentClass.name;
    if (symbols[cl] === undefined) {
      symbols[cl] = {
        _offset: 0
      };
    }
    //console.log(currentFunction);
    //console.log(currentClass.name);
    if (currentFunction !== null) {
      var fn = currentFunction.name;
      if (symbols[cl][fn] === undefined) {
        symbols[cl][fn] = {
          _offset: 0
        };
      }
      symbols[cl][fn][name] = _.clone(denoter)
      symbols[cl][fn][name].offset = symbols[cl][fn]._offset;
      if (denoter.size) {
        symbols[cl][fn]._offset += denoter.size;
      }
    } else {
      symbols[cl][name] = _.clone(denoter);
      symbols[cl][name].offset = symbols[cl]._offset;
      // a denoter should always have a size
      if (denoter.size) {
        symbols[cl]._offset += denoter.size;
      }
    }
  };

  // find symbol accessible from he current context
  var findSymbol = function (name) {
    var cl = currentClass.name;
    var fn = currentFunction.name;
    if (symbols[cl]) {
      if (symbols[cl][fn]) {
        if (symbols[cl][fn][name]) {
          return symbols[cl][fn][name];
        }
      } else if (symbols[cl][name]) {
        return symbols[cl][name];
      }
    }
  };

  var classes = {};

  // get the size of a datatype
  var getSize = function (id) {
    if (id == 'integer' || id == 'boolean') {
      return 4;
    } else {
      return classes[id].size;
    }
  };

  var getOffset = function () {
    mips.comment('getting offset for ' + currentType.name + '.'+ currentId);
    var cl = classes[currentType.name];
    return cl.variables[currentId].offset
  };

  // registers
  var $zero = '$0'

  // stack pointer
    , $sp = '$sp'
    , $a0 = '$a0'
    , $v0 = '$v0'
    , $ra = '$ra'
    ;

  var whileCount = 0;
  var $wh = function () {
    return 'while_' + whileCount++;
  };

  var ifCount = 0;
  var $if = function () {
    return 'if_' + ifCount++;
  };

  var regCount = 0;
  // get next temporary register available
  var $t = (function () {
    return function () {
      return '$t' + regCount++;
    };
  })();

  // backup registers to stack
  var regBackup = function () {
    // allocate space on the stack (+1 for $ra)
    mips.addi($sp, $sp, -4 * (regCount + 1));
    // backup temps
    for (var i = 0; i < regCount; i++) {
      mips.sw('$t'+i, $sp, i*4);
    }
    // backup $ra
    mips.sw($ra, $sp, i*4);

    regCount = 0;

    // unload stack back into registers
    return function () {

      regCount = i;

      mips.lw($ra, $sp, i*4);
      i--;
      for (; i >= 0; i--) {
        mips.lw('$t'+i, $sp, i*4);
      }

      // git back stack
      mips.addi($sp, $sp, 4 * (regCount + 1));
    };
  };

  // release register
  var release = function (reg) {
    if (reg !== $v0) {
      regCount--;
    }
  };

  console.log('.text');
  console.log('main:');
  console.log('jal main_main');
  console.log('addi $v0, $zero, 10');
  console.log('syscall');

%}

%lex

%options flex case-insensitive

%%

\s+         {}

"PROGRAM"   { return 'PROGRAM'; }
"AND"       { return 'AND'; }
"ARRAY"     { return 'ARRAY'; }
"CLASS"     { return 'CLASS'; }
"DO"        { return 'DO'; }
"ELSE"      { return 'ELSE'; }
"END"       { return 'END'; }
"EXTENDS"   { return 'EXTENDS'; }
"FUNCTION"  { return 'FUNCTION'; }
"IF"        { return 'IF'; }
"MOD"       { return 'MOD'; }
"NEW"       { return 'NEW'; }
"NOT"       { return 'NOT'; }
"OF"        { return 'OF'; }
"OR"        { return 'OR'; }
"PRINT"     { return 'PRINT'; }
"BEGIN"     { return 'BEGIN'; }
"THEN"      { return 'THEN'; }
"VAR"       { return 'VAR'; }
"WHILE"     { return 'WHILE'; }

[a-zA-Z]([a-zA-Z0-9])+    { return 'IDENTIFIER'; }

":="        { return 'ASSIGNMENT'; }
":"         { return 'COLON'; }
","         { return 'COMMA'; }
[0-9]+      { return 'DIGSEQ'; }
"."         { return 'DOT';} }
".."        { return 'DOTDOT'; }
"="         { return 'EQUAL'; }
">="        { return 'GE'; }
">"         { return 'GT'; }
"["         { return 'LBRAC'; }
"<="        { return 'LE'; }
"("         { return 'LPAREN'; }
"<"         { return 'LT'; }
"-"         { return 'MINUS'; }
"<>"        { return 'NOTEQUAL'; }
"+"         { return 'PLUS'; }
"]"         { return 'RBRAC'; }
")"         { return 'RPAREN'; }
";"         { return 'SEMICOLON'; }
"/"         { return 'SLASH'; }
"*"         { return 'STAR'; }

/lex

%end program

%% /* language grammar */

program:
  program_heading SEMICOLON class_list DOT {
    //console.log(JSON.stringify(classes, null, 2));
  }
;

program_heading:
  PROGRAM identifier {
  }
| PROGRAM identifier LPAREN identifier_list RPAREN {
  }
;

identifier_list:
  identifier_list COMMA identifier {
    $$ = $1.concat($3);
  }
| identifier {
    $$ = [$1];
  }
;

class_list:
  class_list class_identification BEGIN class_block END {
    $1[$2.name] = {
      name: $2.name,
      extends: $2.extends,
      variables: $4.variables,
      functions: $4.functions,
      size: $4.size
    };

    $$ = $1;
  }
| class_identification BEGIN class_block END {
    $$ = classes;
    $$[$1.name] = {
      name: $1.name,
      extends: $1.extends,
      variables: $3.variables,
      functions: $3.functions,
      size: $3.size
    };
  }
;

class_identification:
  CLASS identifier {
    currentClass = { name: $2 };
    $$ = currentClass;
  }
| CLASS identifier EXTENDS identifier {
    currentClass = { name: $2, extends: $4 };
    $$ = currentClass;
  }
;

class_block:
  variable_declaration_part func_declaration_list {
    var variables = {};
    var offset = 0;
    $1.forEach(function (declaration) {
      declaration.identifiers.forEach(function (id) {
        variables[id] = declaration.denoter;
        variables[id].offset = offset;
        offset += declaration.denoter.size;
      })
    });
    $2.forEach(function (func) {
      mips.label(func.heading.label);
      var stack = stackSize(func.heading.name);
      if (stack !== 0) {
        mips.comment('allocate stack space (' + stack + ' bytes)');
        mips.addi($sp, $sp, -1 * stack);
      }
      if (func.heading.parameters.length > 0) {
        mips.nest(func.heading.instructions);
      }
      mips.nest(func.block.statements.instructions);

      if (stack !== 0) {
        mips.comment('deallocate stack space (' + stack + ' bytes)');
        mips.addi($sp, $sp, 1 * stack);
      }

      mips.jr();
      console.log('\n' + mips.clear().join('\n'));
    });
    $$ = { variables: variables, size: offset, functions: $2 };
  }
;

type_denoter:
  array_type {
    $$ = {
      type: 'array',
      denoter: $1,
      unit: $1.denoter.size,
      size: $1.size
    };
  }
| identifier {
    if ($1 === 'integer' || $1 === 'boolean') {
      $$ = {
        type: 'primitive',
        name: $1,
        size: 4
      };
    } else {
      $$ = {
        type: 'class',
        name: $1,
        size: classes[$1].size
      };
    }
  }
;

array_type:
  ARRAY LBRAC range RBRAC OF type_denoter {
    $$ = {
      range: $3,
      denoter: $6,
      // +1 because of zero based indexing
      size: $6.size * ($3.upper - $3.lower + 1)
    };
  }
;

range:
  unsigned_integer DOTDOT unsigned_integer {
    $$ = { lower: Number($1), upper: Number($3) };
  }
;

variable_declaration_part:
  VAR variable_declaration_list SEMICOLON {
    $2.forEach(function (declaration) {
      declaration.identifiers.forEach(function (id) {
        addSymbol(id, declaration.denoter);
      });
    });
    $$ = $2
  }
| { $$ = []; }
;

variable_declaration_list:
  variable_declaration_list SEMICOLON variable_declaration {
    $$ = $1.concat($3);
  }
| variable_declaration { $$ = [$1]; }
;

variable_declaration:
  identifier_list COLON type_denoter {
    $$ = {
      identifiers: $1,
      denoter: $3,
      size: $1.length * $3.size
    };
  }
;

func_declaration_list:
  func_declaration_list SEMICOLON function_declaration {
    currentFunction = null;
    $$ = $1.concat($3);
  }
| function_declaration {
    currentFunction = null;
    $$ = [$1];
}
| {
    currentFunction = null;
    $$ = [];
  }
;

formal_parameter_list:
  LPAREN formal_parameter_section_list RPAREN {
    $$ = $2;
  }
;

formal_parameter_section_list:
  formal_parameter_section_list SEMICOLON formal_parameter_section {
    $$ = $1.concat($3);
  }
| formal_parameter_section { $$ = [$1]; }
;

formal_parameter_section:
  value_parameter_specification {
  }
| variable_parameter_specification {
  }
;

value_parameter_specification:
  identifier_list COLON identifier {
  }
;

variable_parameter_specification:
  VAR identifier_list COLON identifier {
    $$ = {
      identifiers: $2,
      denoter: {
        name: $4,
        size: getSize($4)
      }
    };
  }
;

function_declaration:
  function_identification SEMICOLON function_block {
    $$ = {
      heading: $1,
      block: $3
    };
  }
| function_heading SEMICOLON function_block {
    $$ = {
      heading: $1,
      block: $3
    };
  }
;

function_heading:
  FUNCTION identifier COLON result_type {
    var label = currentClass.name + '_' + $2;
    //mips.label(label);
    currentFunction = {
      name: $2,
      label: label,
      parameters: [],
      result: $4
    };
    $$ = currentFunction;
    addSymbol($2, { result: true, type: 'return' });
  }
| FUNCTION identifier formal_parameter_list COLON result_type {
    var label = currentClass.name + '_' + $2;
    //mips.label(label);
    currentFunction = {
      name: $2,
      label: label,
      parameters: $3,
      result: $5
    };
    $$ = currentFunction;
    addSymbol($2, { result: true, type: 'return' });

    // wait to set current function to parameters get
    // bound to this function
    mips.comment('loading parameters');
    var a = 0;
    $3.forEach(function (param) {
      param.identifiers.forEach(function (id) {
        addSymbol(id, param.denoter);
        mips.sw('$a' + a, $sp, findSymbol(id).offset);
        a++;
      });
    });
    currentFunction.instructions = mips.clear();
  }
;

result_type: identifier;

function_identification:
  FUNCTION identifier {
    var label = currentClass.name + '_' + $2;
    //mips.label(label);
    currentFunction = {
      name: $2,
      label: label,
      parameters: []
    };
    $$ = currentFunction;
  }
;

function_block:
  variable_declaration_part statement_part {
    $$ = {
      type: 'block',
      variables: $1,
      statements: $2
    };
  }
;

statement_part:
  compound_statement {
  }
;

compound_statement:
  BEGIN statement_sequence END {
    $$ = $2;
  }
;

statement_sequence:
  statement {
    $$ = {
      type: 'sequence',
      instructions: $1.instructions || []
    };
  }
| statement_sequence SEMICOLON statement {
    $$ = {
      type: 'sequence',
      instructions: $1.instructions.concat($3.instructions)
    };
  }
;

statement:
  assignment_statement
| compound_statement
| if_statement
| while_statement
| print_statement
;

assignment_statement:
  variable_access ASSIGNMENT expression {
    mips.comment('assign expression');
    if ($1.register === $v0) {
      mips.mov($v0, $3);
    } else {
      mips.sw($3 , $1.register);
    }
    $$ = {
      type: 'assign',
      instructions: mips.clear()
    };
    release($1.register); // for variable_access
    release($3); // for expression evaluation
  }
| variable_access ASSIGNMENT object_instantiation {
    var size = classes[$3.name].size;
    // allocate memory on the heap
    mips.comment('allocating memory for ' + $3.name);
    mips.comment('sizeof(' + $3.name + ') = ' + size);
    mips.addi($v0, $zero, 9);
    mips.addi($a0, $zero, size); // how many btyes to allocate
    mips.syscall();
    mips.sw($v0, $1.register);
    $$ = {
      type: 'instantiation',
      instructions: mips.clear()
    };
    release($1.register); // for variable_access
  }
;

while_statement:
  WHILE boolean_expression DO statement {
    mips.comment('while expression');
    var begin = $wh();
    var end = $wh();
    mips.label(begin);
    mips.nest($2.instructions);
    mips.beq($2.register, $zero, end);
    mips.nest($4.instructions)
    mips.j(begin);
    mips.label(end);
    $$ = {
      type: 'while',
      instructions: mips.clear()
    };
    release($2.register); // release register for condition
  }
;

if_statement:
  IF boolean_expression THEN statement ELSE statement {
    mips.comment('if expression');
    var el = $if();
    var end = $if();
    mips.nest($2.instructions);
    mips.beq($2.register, $zero, el);
    mips.nest($4.instructions);
    mips.j(end);
    mips.label(el);
    mips.nest($6.instructions);
    mips.label(end);
    $$ = {
      type: 'if',
      instructions: mips.clear()
    };
    release($2.register); // release register for condition
  }
;

object_instantiation:
  NEW identifier {
    $$ = {
      name: $2,
      params: []
    };
  }
| NEW identifier params {
    $$ = {
      name: $2,
      params: $3
    };
  }
;

print_statement:
  PRINT variable_access {
    mips.comment('printing');
    mips.addi($v0, $zero, 1);
    mips.lw($a0, $2.register);
    mips.syscall();
    mips.addi($a0, $zero, '0xA');
    mips.addi($v0, $zero, '0xB');
    mips.syscall();
    $$ = {
      type: 'print',
      instructions: mips.clear()
    };
    release($2.register); // for variable access
  }
;

variable_access:
  identifier {
    currentType = findSymbol($1);
    // trying to assign to a function name
    if (findSymbol($1).result === true) {
      $$ = { register: $v0 };
    } else {
      var reg = $t();
      mips.comment(reg + ' <- addr(' + $1 + ')');
      mips.addi(reg, $sp, findSymbol($1).offset);
      $$ = { register: reg, symbol: $1 };
    }
  }
| indexed_variable {
  }
| attribute_designator {
  }
| method_designator {
  }
;

indexed_variable:
  variable_access LBRAC index_expression_list RBRAC {
    var type = findSymbol($1.symbol);
    var unit = type.unit;
    var lower = type.denoter.range.lower;
    var upper = type.denoter.range.upper;
    var $i = $t();
    mips.comment($1.symbol + '[' + lower + '..' + upper + '] = ' + unit + ' * $i');
    mips.addi($i, $zero, unit);
    if (lower !== 0) {
      mips.addi($3, $3, -1*lower);
    }
    mips.mult($i, $3);
    mips.mflo($i);
    mips.add($1.register, $1.register, $i);
    // release registers
    release($i);
    release($3);
  }
;

index_expression_list:
  index_expression_list COMMA index_expression {
  }
| index_expression {
  }
;

index_expression:
  expression {
  }
;

attribute_designator:
  variable_access DOT identifier {
    var offset = getOffset($1);
    mips.addi($1.register, $1.register, offset);
  }
;

method_designator:
  variable_access DOT function_designator {
  }
;

params:
  LPAREN actual_parameter_list RPAREN {
    $$ = $2;
  }
;

actual_parameter_list:
  actual_parameter_list COMMA actual_parameter{
    $$ = $1.concat($3);
  }
| actual_parameter {
    $$ = [$1];
  }
|
  {
    $$ = [];
  }
;

actual_parameter:
  expression {
  }
| expression COLON expression {
  }
| expression COLON expression COLON expression {
  }
;

boolean_expression: expression {
  $$ = {
    type: 'boolean',
    register: $1,
    instructions: mips.clear()
  };
};

expression: simple_expression
| simple_expression relop simple_expression {
    switch ($2) {
      case '=':
        mips.comment($1 + ' = ' + $3);
        mips.seq($1, $1, $3);
        break;
      case '<>':
        mips.comment($1 + ' <> ' + $3);
        mips.sne($1, $1, $3);
        break;
      case '<':
        mips.comment($1 + ' < ' + $3);
        mips.slt($1, $1, $3);
        break;
      case '<=':
        mips.comment($1 + ' <= ' + $3);
        mips.sle($1, $1, $3);
        break;
      case '>':
        mips.comment($1 + ' > ' + $3);
        mips.slt($1, $3, $1);
        break;
      case '>=':
        mips.comment($1 + ' >= ' + $3);
        mips.sle($1, $3, $1);
        break;
    }
    $$ = $1;
    release($3);
  }
;

simple_expression: term
| simple_expression addop term {
    switch ($2) {
      case '+':
        mips.add($1, $1, $3);
        break;
      case '-':
        mips.sub($1, $1, $3);
        break;
      case '|':
        mips.or($1, $1, $3);
        break;
    }
    $$ = $1;
    release($3);
  }
;

term: factor
| term mulop factor {
    switch ($2) {
      case '*':
        mips.mult($1, $3);
        mips.mflo($1);
        break;
      case '/':
        mips.div($1, $3);
        mips.mflo($1);
        break;
      case 'mod':
        mips.div($1, $3);
        mips.mfhi($1);
        break;
      case '&':
        mips.and($3, $1, $3);
        break;
    }
    $$ = $1;
    release($3);
  }
;

sign: PLUS | MINUS;

factor:
  sign factor {
    // make the numbers negative on '-'
    if ($1 == '-') {
      mips.sub($2, $zero, $2);
    }
    $$ = $2;
  }
| primary;

primary:
  variable_access {
    mips.lw($1.register, $1.register);
    $$ = $1.register;
  }
| unsigned_constant {
  }
| LPAREN expression RPAREN {
    $$ = $2;
  }
| function_designator {
    // back up registers
    var undo = regBackup();
    // set parameters
    var a = 0;
    $1.params.forEach(function (reg) {
      mips.mov('$a' + a, reg);
      a++;
    });
    // make call
    mips.jal(currentClass.name + '_' + $1.name);
    // fix stack frame
    undo();
    $$ = $v0;
  }
| NOT primary {
  }
;

unsigned_constant:
  unsigned_number {
    var reg = $t();
    mips.addi(reg, $zero, $1);
    $$ = reg;
  }
;

unsigned_number: unsigned_integer;
unsigned_integer: DIGSEQ;

function_designator:
  identifier params {
    $$ = {
      name: $1,
      params: $2
    };
  }
;

addop: PLUS | MINUS | OR;
mulop: STAR | SLASH | MOD | AND;
relop: EQUAL | NOTEQUAL | LT | GT | LE | GE;

identifier:
  IDENTIFIER {
    $$ = $1.toLowerCase();
    currentId = $$;
  }
;
