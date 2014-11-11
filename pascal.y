%{
  var mips = require('./mips');
  var syms = require('./symbols');

  // registers
  var $zero = '$0'

  // stack pointer
    , $sp = '$sp'
    , $a0 = '$a0'
    , $v0 = '$v0'
    , $s0 = '$s0' // this context
    , $s1 = '$s1' // temp var
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
    mips.comment('backing up registers to the stack')
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

      mips.comment('restoring registers from the stack')
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

  if (process.argv[3] === '--classes') {
    var printClasses = true;
  } else {
    console.log('.text');
    console.log('main:');
    console.log('addi $sp, $sp, -4');
    console.log('addi $s1, $sp, 0');
    console.log('jal main_main');
    console.log('addi $v0, $zero, 10');
    console.log('syscall');
  }

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
    //console.log(JSON.stringify(symbols, null, 2));
    if (printClasses) {
      console.log(JSON.stringify(syms.classes, null, 2));
    }
  }
;

program_heading:
  PROGRAM identifier {
  }
| PROGRAM identifier LPAREN identifier_list RPAREN {
  }
;

identifier_list:
  identifier_list COMMA identifier { $$ = $1.concat($3); }
| identifier { $$ = [$1]; }
;

class_list:
  class_list class_identification BEGIN class_block END {
  }
| class_identification BEGIN class_block END {}
;

class_identification:
  CLASS identifier {
    syms.addClass($2);
  }
| CLASS identifier EXTENDS identifier {
    syms.addClass($2, $4);
  }
;

class_block:
  variable_declaration_part func_declaration_list {
    $2.forEach(function (func) {
      mips.label(func.heading.label);
      var stack = func.heading.getStackSize();
      if (stack !== 0) {
        mips.comment('allocate stack space (' + stack + ' bytes)');
        mips.addi($sp, $sp, -1 * stack);
      }
      if (func.heading.instructions.length === 0) {
        mips.comment('no parameters to load');
      } else {
        mips.nest(func.heading.instructions);
      }

      mips.nest(func.block.statements.instructions);
      if (stack !== 0) {
        mips.comment('deallocate stack space (' + stack + ' bytes)');
        mips.addi($sp, $sp, 1 * stack);
      }
      mips.jr();
      if (!printClasses) {
        console.log('\n' + mips.clear().join('\n'));
      }
    });
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
        size: syms.getSize($1)
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
  VAR variable_declaration_list SEMICOLON {}
| { }
;

variable_declaration_list:
  variable_declaration_list SEMICOLON variable_declaration {
  }
| variable_declaration { }
;

variable_declaration:
  identifier_list COLON type_denoter {
    $1.forEach(function (id) { syms.addVariable(id, $3); });
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
      denoter: syms.getDenoter($4)
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
    $$ = syms.addMethod($2, $4);
  }
| FUNCTION identifier formal_parameter_list COLON result_type {
    var method = $$ = syms.addMethod($2, $5);
    var a = 0;
    mips.comment('loading parameters for ' + $2);
    $3.forEach(function (declaration) {
      declaration.identifiers.forEach(function (id) {
        var offset = method.addParam(id, declaration.denoter);
        mips.sw('$a' + a, $sp, offset);
        a++;
      });
    });
    method.addInstructions(mips.clear());
  }
;

result_type: identifier;

function_identification:
  FUNCTION identifier { $$ = syms.addMethod($2); }
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

statement_part: compound_statement;

compound_statement:
  BEGIN statement_sequence END { $$ = $2; }
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
    if ($1.register === $v0) {
      mips.comment('setting return value');
      mips.mov($v0, $3);
    } else {
      mips.comment('assign expression: ' + $1.symbol + ' = ' + $3);
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
    var size = syms.getSize($3.name);
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
  NEW identifier { $$ = { name: $2, params: [] }; }
| NEW identifier params { $$ = { name: $2, params: $3 }; }
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
    var variable = syms.lookup($1);
    // trying to assign to a function name
    if (variable.isResult) {
      var reg = $t();
      mips.comment('setting return value');
      $$ = { register: $v0 };
    } else if (variable.isLocal) {
      var reg = $t();
      mips.comment(reg + ' = addressOf (local:' + $1 + ')');
      mips.addi(reg, $sp, variable.offset);
      $$ = { register: reg, symbol: $1, denoter: variable.denoter };
    } else if (variable.isInstance) {
      // handle instance vars
      var reg = $t();
      mips.comment(reg + ' = addressOf (instance:' + $1 + ')');
      mips.addi(reg, $s0, variable.offset);
      $$ = { register: reg, symbol: $1, denoter: variable.denoter };
    }
  }
| indexed_variable { }
| attribute_designator { }
| method_designator { }
;

indexed_variable:
  variable_access LBRAC index_expression_list RBRAC {
    var denoter = $1.denoter;
    var unit = denoter.unit;
    var lower = denoter.denoter.range.lower;
    var upper = denoter.denoter.range.upper;
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

    $$ = $1;
    $$.denoter = $1.denoter.denoter;
  }
;

index_expression_list:
  index_expression_list COMMA index_expression {
  }
| index_expression { }
;

index_expression: expression { } ;

attribute_designator:
  variable_access DOT identifier {
    var variable = syms.lookup($3, $1.denoter.name);
    mips.addi($1.register, $1.register, 0);
    $$ = { register: $1.register, symbol: $3, denoter: variable.denoter };
  }
;

method_designator:
  variable_access DOT function_designator {
    //var result = classes[$1.type.name].functions[$3.name].heading.result;
    // set parameters
    mips.comment('setting parameters for method call');
    var a = 0;
    $3.params.forEach(function (reg) {
      mips.mov('$a' + a, reg);
      a++;
      release(reg);
    });
    mips.addi($sp, $sp, -4);
    mips.sw($s0, $sp);
    mips.comment('setting this context for ' + $1.denoter.name);
    mips.mov($s0, $1.register);
    // back up registers
    var undo = regBackup();
    // make call
    var method = syms.getMethod($3.name, $1.denoter.name);
    mips.jal(method.label);
    // fix stack frame
    undo();
    mips.lw($s0, $sp);
    mips.addi($sp, $sp, 4);
    mips.comment('saving $v0 into temp var');
    mips.sw($v0, $s1);
    $$ = { register: $s1, symbol: $3.name, denoter: method.denoter };
  }
;

params: LPAREN actual_parameter_list RPAREN { $$ = $2; };

actual_parameter_list:
  actual_parameter_list COMMA actual_parameter {
    $$ = $1.concat($3);
  }
| actual_parameter { $$ = [$1]; }
| { $$ = []; }
;

actual_parameter:
  expression { }
| expression COLON expression { }
| expression COLON expression COLON expression { }
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
| unsigned_constant { }
| LPAREN expression RPAREN { $$ = $2; }
| function_designator {
    // set parameters
    var a = 0;
    $1.params.forEach(function (reg) {
      mips.mov('$a' + a, reg);
      a++;
      release(reg);
    });
    // back up registers
    var undo = regBackup();
    // make call
    var method = syms.getMethod($1.name);
    mips.comment('making function call to ' + $1.name);
    mips.jal(method.label);
    // fix stack frame
    undo();
    var reg = $t();
    mips.mov(reg, $v0);
    $$ = reg;
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
    $$ = { name: $1, params: $2 };
  }
;

addop: PLUS | MINUS | OR;
mulop: STAR | SLASH | MOD | AND;
relop: EQUAL | NOTEQUAL | LT | GT | LE | GE;

identifier:
  IDENTIFIER { $$ = $1.toLowerCase(); }
;
