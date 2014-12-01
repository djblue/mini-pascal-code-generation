%{
  var mips = require('./mips');
  var syms = require('./symbols');
  var temp = require('./temp');

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

  if (process.argv[3] === '--classes') {
    var printClasses = true;
  } else {
    console.log('.text');
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
    if (printClasses) {
      console.log(JSON.stringify(syms.classes, null, 2));
    }
  }
;

program_heading:
  PROGRAM identifier {
    if (!printClasses) {

      mips.label('main');
      mips.comment('allocate global temp var');
      mips.addi($sp, $sp, -4);
      mips.addi($s1, $sp, 0);

      var main = $2 + '_' + $2
      mips.comment('set the frame pointer');
      mips.mov($fp, $sp);
      mips.comment('jump to main method "' + main + '"');
      mips.jal(main);

      mips.comment('exit program');
      mips.li($v0, 10);
      mips.syscall();

      console.log(mips.clear().join('\n'))
    }
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

      mips.comment('set activation record');
      mips.addi($sp, $sp, -8);
      mips.sw($ra, $sp, 4);
      mips.sw($fp, $sp, 0);
      mips.mov($fp, $sp);

      if (stack !== 0) {
        mips.comment('allocate stack space (' + stack + ' bytes)');
        var reg = temp.$t();
        mips.li(reg, -1 * stack);
        mips.add($sp, $sp, reg);
        temp.release(reg);
      }

      mips.nest(func.block.statements.instructions);

      mips.comment('reset activation record');
      mips.mov($sp, $fp);
      mips.lw($fp, $sp, 0);
      mips.lw($ra, $sp, 4);
      mips.addi($sp, $sp, 8);

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
| identifier { $$ = syms.getDenoter($1); }
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
    $$ = $1.concat($3);
  }
| function_declaration { $$ = [$1]; }
| { $$ = []; }
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
  value_parameter_specification { }
| variable_parameter_specification { }
;

value_parameter_specification:
  identifier_list COLON identifier {
    $$ = {
      identifiers: $1,
      denoter: syms.getDenoter($3)
    };
  }
;

variable_parameter_specification:
  VAR identifier_list COLON identifier {
    $$ = {
      identifiers: $2,
      denoter: syms.getDenoter($4),
      isReference: true
    };
  }
;

function_declaration:
  function_identification SEMICOLON function_block {
    $$ = { heading: $1, block: $3 };
  }
| function_heading SEMICOLON function_block {
    $$ = { heading: $1, block: $3 };
  }
;

function_heading:
  FUNCTION identifier COLON result_type {
    $$ = syms.addMethod($2, $4);
  }
| FUNCTION identifier formal_parameter_list COLON result_type {
    var method = $$ = syms.addMethod($2, $5);
    $3.forEach(function (declaration) {
      declaration.identifiers.forEach(function (id) {
        method.addParam(id, declaration.denoter, declaration.isReference);
      });
    });
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

    mips.adj($1.instructions);
    mips.adj($3.instructions);

    if ($1.register === $v0) {
      mips.comment('setting return value');
      mips.mov($v0, $3.register);
    } else {
      mips.comment('assign expression: ' + $1.symbol + ' = ' + $3.register);
      mips.sw($3.register , $1.register);
    }
    $$ = {
      type: 'assign',
      instructions: mips.clear()
    };
    temp.release($1.register); // for variable_access
    temp.release($3.register); // for expression evaluation
  }
| variable_access ASSIGNMENT object_instantiation {
    mips.adj($1.instructions);
    var size = syms.getSize($3.name);
    // allocate memory on the heap
    mips.comment('allocating memory: ' + ' sizeof(' + $3.name + ') = ' + size);
    mips.li($v0, 9);
    mips.li($a0, size); // how many bytes to allocate
    mips.syscall();
    mips.sw($v0, $1.register);
    $$ = {
      type: 'instantiation',
      instructions: mips.clear()
    };
    temp.release($1.register); // for variable_access
  }
;

while_statement:
  WHILE boolean_expression DO statement {
    mips.comment('while expression');
    var begin = mips.$wh();
    var end = mips.$wh();
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
  }
;

if_statement:
  IF boolean_expression THEN statement ELSE statement {
    mips.comment('if expression');
    var el = mips.$if();
    var end = mips.$if();
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
  }
;

object_instantiation:
  NEW identifier { $$ = { name: $2, params: [] }; }
| NEW identifier params { $$ = { name: $2, params: $3 }; }
;

print_statement:
  PRINT variable_access {
    mips.adj($2.instructions);
    mips.comment('printing: ' + $2.symbol);
    mips.lw($a0, $2.register);
    mips.addi($v0, $zero, 1);
    mips.syscall();
    mips.addi($a0, $zero, '0xA');
    mips.addi($v0, $zero, '0xB');
    mips.syscall();
    $$ = {
      type: 'print',
      instructions: mips.clear()
    };
    temp.release($2.register); // for variable access
  }
;

variable_access:
  identifier {
    if ($1 === 'true' || $1 === 'false') {
      var value = ($1 === 'true')? 1 : 0;
      var reg = temp.$t();
      mips.li(reg, value);
      mips.sw(reg, $s1);
      temp.release(reg);
      $$ = {
        register: $s1,
        symbol: $1,
        denoter: syms.getDenoter('boolean')
      };
    } else {
      var variable = syms.lookup($1);
      // trying to assign to a function name
      if (variable.isResult) {
        $$ = { register: $v0, instructions: mips.clear() };
      } else if (variable.isParam && variable.isValue) {
        var reg = temp.$t();
        mips.comment(reg + ' = addressOf (param:' + $1 + ')');
        mips.li(reg, 8 + variable.offset);
        mips.add(reg, reg, $fp);
        $$ = { register: reg, symbol: $1, denoter: variable.denoter, instructions: mips.clear() };
      } else if (variable.isParam && variable.isReference) {
        var reg = temp.$t();
        mips.comment(reg + ' = &addressOf (param:' + $1 + ')');
        mips.li(reg, 8 + variable.offset);
        mips.add(reg, reg, $fp);
        mips.lw(reg, reg);
        $$ = { register: reg, symbol: $1, denoter: variable.denoter, instructions: mips.clear() };
      } else if (variable.isLocal) {
        var reg = temp.$t();
        mips.comment(reg + ' = addressOf (local:' + $1 + ')');
        mips.li(reg, (-1 * variable.offset) - 4);
        mips.add(reg, $fp, reg);
        $$ = { register: reg, symbol: $1, denoter: variable.denoter, instructions: mips.clear() };
      } else if (variable.isInstance) {
        // handle instance vars
        var reg = temp.$t();
        mips.comment(reg + ' = addressOf (instance:' + $1 + ')');
        mips.li(reg, variable.offset);
        mips.add(reg, $s0, reg);
        $$ = { register: reg, symbol: $1, denoter: variable.denoter, instructions: mips.clear() };
      }
    }
  }
| indexed_variable { }
| attribute_designator { }
| method_designator { }
;

indexed_variable:
  variable_access LBRAC index_expression_list RBRAC {

    mips.adj($1.instructions);
    mips.adj($3.instructions);

    var denoter = $1.denoter;
    var unit = denoter.unit;
    var lower = denoter.denoter.range.lower;
    var upper = denoter.denoter.range.upper;
    var $i = temp.$t();
    mips.comment($1.symbol + '[' + lower + '..' + upper + '] = ' + unit + ' * $i');
    mips.li($i, unit);
    if (lower !== 0) {
      mips.addi($3.register, $3.register, -1*lower);
    }

    mips.mult($i, $3.register);
    mips.mflo($i);

    mips.sub($1.register, $1.register, $i);
    // release registers
    temp.release($i);
    temp.release($3.register);

    $$ = $1;
    $$.denoter = $1.denoter.denoter.denoter;
    $$.instructions = mips.clear();
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

    mips.adj($1.instructions);

    var variable = syms.lookup($3, $1.denoter.name);
    mips.comment('dereferencing ' + $1.symbol + '.' + $3);
    mips.lw($1.register, $1.register);
    var reg = temp.$t();
    mips.li(reg, variable.offset);
    mips.sub($1.register, $1.register, reg);
    temp.release(reg);
    $$ = {
      register: $1.register,
      symbol: $3,
      denoter: variable.denoter,
      instructions: mips.clear()
    };
  }
;

method_designator:
  variable_access DOT function_designator {

    mips.adj($1.instructions);

    var undo = temp.regBackup();

    mips.addi($sp, $sp, -4);
    mips.sw($s0, $sp);

    mips.comment('setting this context for ' + $1.denoter.name);
    mips.lw($s0, $1.register);

    mips.comment('allocating space for params + (' + 4 * $3.params.length + ' bytes)');
    mips.addi($sp, $sp, -4 * $3.params.length);

    $3.params.forEach(function (param, i) {
      mips.adj(param.instructions);
      mips.sw(param.register, $sp, 4*i);
    });

    mips.comment('making method call to ' + $3.name);
    var method = syms.getMethod($3.name, $1.denoter.name);
    mips.jal(method.label);

    mips.addi($sp, $sp, 4 * $3.params.length);

    mips.lw($s0, $sp);
    mips.addi($sp, $sp, 4);

    undo();

    mips.comment('saving $v0 into temp var');
    mips.sw($v0, $s1);

    $$ = {
      register: $s1,
      symbol: $3.name,
      denoter: method.denoter,
      instructions: mips.clear()
    };
  }
;

params: LPAREN actual_parameter_list RPAREN { $$ = $2; };

actual_parameter_list:
  actual_parameter_list COMMA actual_parameter {
    $$ = $1.concat($3);
  }
| actual_parameter { $$ = [$1] }
| { $$ = []; }
;

actual_parameter:
  expression {
    temp.release($1.register);
    $$ = {
      register: $1.register,
      instructions: $1.instructions
    };
  }
| expression COLON expression { }
| expression COLON expression COLON expression { }
;

boolean_expression: expression {
  mips.adj($1.instructions);
  mips.mov($s2, $1.register);
  $$ = {
    type: 'boolean',
    register: $s2,
    instructions: mips.clear()
  };
  temp.release($1.register);
};

expression:
  simple_expression {
    $$ = {
      register: $1,
      instructions: mips.clear()
    };
  }
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
    temp.release($3);
    $$ = {
      register: $1,
      instructions: mips.clear()
    };
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
      case 'or':
        mips.or($1, $1, $3);
        break;
    }
    $$ = $1;
    temp.release($3);
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
      case 'and':
        mips.and($1, $1, $3);
        break;
    }
    $$ = $1;
    temp.release($3);
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

    mips.adj($1.instructions);

    if ($1.register === $s1) {
      var reg = temp.$t();
      mips.lw(reg, $1.register);
      $$ = reg;
    } else {
      mips.lw($1.register, $1.register);
      $$ = $1.register;
    }
  }
| unsigned_constant {
    var reg = temp.$t();
    mips.li(reg, $1);
    $$ = reg;
  }
| LPAREN expression RPAREN {
    mips.adj($2.instructions);
    $$ = $2.register;
  }
| function_designator {

    var method = syms.getMethod($1.name);

    var undo = temp.regBackup();

    mips.comment('allocating params + (' + 4 * $1.params.length + ' bytes)');
    mips.addi($sp, $sp, -4 * $1.params.length);


    var params = method.getParams();

    $1.params.forEach(function (param, i) {
      if (params[i].isReference) {
        // pop the dereference operation
        param.instructions.pop();
      }
      mips.comment('loading param: ' + $1.name + '[' + i + ']');
      mips.nest(param.instructions);
      mips.sw(param.register, $sp, 4*i);
    });

    // make call
    mips.comment('making function call to ' + $1.name);
    mips.jal(method.label);

    mips.addi($sp, $sp, 4 * $1.params.length);

    undo();

    var reg = temp.$t();
    mips.mov(reg, $v0);
    $$ = reg;
  }
| NOT primary {
  }
;

unsigned_constant: unsigned_number;

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
