%{
  var mips = require('./mips');
  var _ = require('underscore');

  var symbols = {};
  var classes = {};

  var currentClass = null;
  var currentFunction = null;

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
      //console.log(reg)
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
      functions: $4.functions
    };

    $$ = $1;
  }
| class_identification BEGIN class_block END {
    $$ = classes;
    $$[$1.name] = {
      name: $1.name,
      extends: $1.extends,
      variables: $3.variables,
      functions: $3.functions
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
    $$ = { variables: $1, functions: $2 };
    $2.forEach(function (func) {
      mips.label(func.heading.label);
      mips.nest(func.block.statements.instructions);
      mips.jr();
      console.log('\n' + mips.clear().join('\n'));
    });
  }
;

type_denoter:
  array_type {
    $$ = {
      type: 'array',
      denoter: $1
    };
  }
| identifier {
    if ($1 === 'integer' || $1 === 'boolean') {
      $$ = {
        type: 'primitive',
        name: $1
      };
    } else {
      $$ = {
        type: 'class',
        name: $1
      };
    }
  }
;

array_type:
  ARRAY LBRAC range RBRAC OF type_denoter {
    $$ = {
      range: $3,
      denoter: $6
    };
  }
;

range:
  unsigned_integer DOTDOT unsigned_integer {
    $$ = { lower: $1, upper: $3 };
  }
;

variable_declaration_part:
  VAR variable_declaration_list SEMICOLON {
    var variables = $2;
    var offset = 0;
    variables.forEach(function (declaration) {
      declaration.identifiers.forEach(function (id) {
        symbols[id] = _.clone(declaration.denoter);
        symbols[id].offset = offset;
        offset += 4;
      });
    });
    $$ = variables;
  }
|
  {
    $$ = [];
  }
;

variable_declaration_list:
  variable_declaration_list SEMICOLON variable_declaration {
    $$ = $1.concat($3);
  }
| variable_declaration {
    $$ = [$1];
  }
;

variable_declaration:
  identifier_list COLON type_denoter {
    $$ = { identifiers: $1, denoter: $3 };
  }
;

func_declaration_list:
  func_declaration_list SEMICOLON function_declaration {
    $$ = $1.concat($3);
  }
| function_declaration {
    $$ = [$1]; 
  }
| {
    $$ = [];
  }
;

formal_parameter_list:
  LPAREN formal_parameter_section_list RPAREN {
  }
;

formal_parameter_section_list:
  formal_parameter_section_list SEMICOLON formal_parameter_section {
  }
| formal_parameter_section {
  }
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
      result: $4
    };
    $$ = currentFunction;
    symbols[$2] = { result: true };
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
  }
;

result_type: identifier;

function_identification:
  FUNCTION identifier {
    var label = currentClass.name + '_' + $2;
    //mips.label(label);
    currentFunction = {
      name: $2,
      label: label
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
    if ($1 === $v0) {
      mips.mov($v0, $3);
    } else {
      mips.sw($3 , $1);
    }
    release($1); // for variable_access
    release($3); // for expression evaluation
    $$ = {
      type: 'assign',
      instructions: mips.clear()
    };
  }
| variable_access ASSIGNMENT object_instantiation {
    release($1); // for variable_access
    release($3); // for object address
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
  }
| NEW identifier params {
  }
;

print_statement:
  PRINT variable_access {
    mips.comment('printing');
    mips.addi($v0, $zero, 1);
    mips.lw($a0, $2);
    mips.syscall();
    mips.addi($a0, $zero, '0xA');
    mips.addi($v0, $zero, '0xB');
    mips.syscall();
    $$ = {
      type: 'print',
      instructions: mips.clear()
    };
    release($2); // for variable access
  }
;

variable_access:
  identifier {
    // trying to assign to a function name
    if (symbols[$1].result === true) {
      $$ = $v0;
    } else {
      var reg = $t();
      mips.comment(reg + ' <- addr(' + $1 + ')');
      mips.addi(reg, $sp, symbols[$1].offset);
      $$ = reg;
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
    mips.lw($1, $1);
    $$ = $1;
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
  }
;
