%{
  var syms = require('./symbols');
  var temp = require('./temp');
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

      var main = $2 + '_' + $2;
      var inst = mips('program');

      inst
        .label('main')
        .comment('allocate global temp var')
        .addi($sp, $sp, -4)
        .addi($s1, $sp, 0)

        .comment('set the frame pointer')
        .mov($fp, $sp)
        .comment('jump to main method "' + main + '"')
        .jal(main)

        .comment('exit program')
        .li($v0, 10)
        .syscall()
        ;

      inst.print();
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

      var stack = func.heading.getStackSize();

      var inst = mips();

      inst
        .label(func.heading.label)
        .comment('set activation record')
        .addi($sp, $sp, -8)
        .sw($ra, $sp, 4)
        .sw($fp, $sp, 0)
        .mov($fp, $sp)
        ;

      if (stack !== 0) {
        var reg = temp.$t(inst);

        inst
          .comment('allocate stack space (' + stack + ' bytes)')
          .li(reg, -1 * stack)
          .add($sp, $sp, reg)
          ;

        temp.release(reg, inst);
      }

      inst
        .nest(func.block.statements)
        .comment('reset activation record')
        .mov($sp, $fp)
        .lw($fp, $sp, 0)
        .lw($ra, $sp, 4)
        .addi($sp, $sp, 8)
        .jr()
        ;

      if (!printClasses) inst.print();
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
    $$ = mips('sequence').concat($1);
  }
| statement_sequence SEMICOLON statement {
    $$ = mips('sequence').concat($1).concat($3);
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

    var inst = mips('assign').concat($1).concat($3);

    if ($1.register === $v0) {
      inst.comment('setting return value').mov($v0, $3);
    } else {
      inst
        .comment('assign expression: ' + $1.symbol + ' = ' + $3.register)
        .sw($3, $1)
        ;
    }

    temp.release($1.register, inst); // for variable_access
    temp.release($3.register, inst); // for expression evaluation

    $$ = inst;
  }
| variable_access ASSIGNMENT object_instantiation {

    var inst = mips('instantiation');
    var size = syms.getSize($3.name);
    var method = syms.getMethod($3.name, $3.name);

    inst
      .concat($1)
      // allocate memory on the heap
      .comment('allocating memory: ' + ' sizeof(' + $3.name + ') = ' + size)
      .li($v0, 9)
      // how many bytes to allocate
      .li($a0, size)
      .syscall()
      .sw($v0, $1)
      ;

    temp.release($1.register, inst); // for variable_access

    // class has a constructor (call constructor)
    if (method !== undefined) {

      var params = method.getParams();

      inst
        .add($sp, $sp, -4)
        .sw($s0, $sp)
        .mov($s0, $v0)
        ;

      if ($3.params.length > 0) {
        inst
          .comment('allocating space for params + (' + 4 * $3.params.length + ' bytes)')
          .addi($sp, $sp, -4 * $3.params.length)
          ;
      }

      $3.params.forEach(function (param, i) {
        // pop the dereference operation
        if (params[i].isReference) {
          param.pop();
        }
        inst.nest(param).sw(param, $sp, 4*i);
      });

      inst
        .comment('making constructor call to ' + $3.name)
        .jal(method.label)
        ;

      if ($3.params.length > 0) {
        inst.addi($sp, $sp, 4 * $3.params.length)
      }

      inst
        .lw($s0, $sp)
        .add($sp, $sp, 4)
        ;
    }

    $$ = inst;
  }
;

while_statement:
  WHILE boolean_expression DO statement {
    
    var inst = mips('while')
      , begin = inst.$wh()
      , end = inst.$wh()
      ;

    inst
      .comment('while expression')
      .label(begin)
      .nest($2)
      .beq($2, $zero, end)
      .nest($4)
      .j(begin)
      .label(end)
      ;

    $$ = inst;
  }
;

if_statement:
  IF boolean_expression THEN statement ELSE statement {

    var inst = mips('if')
      , el = inst.$if()
      , end = inst.$if()
      ;

    inst
      .comment('if expression')
      .nest($2)
      .beq($2, $zero, el)
      .nest($4)
      .j(end)
      .label(el)
      .nest($6)
      .label(end)
      ;

    $$ = inst;
  }
;

object_instantiation:
  NEW identifier { $$ = { name: $2, params: [] }; }
| NEW identifier params { $$ = { name: $2, params: $3 }; }
;

print_statement:
  PRINT variable_access {
    var inst = mips('print');
    inst
      .concat($2)
      .comment('printing: ' + $2.symbol)
      .lw($a0, $2)
      .addi($v0, $zero, 1)
      .syscall()
      .addi($a0, $zero, '0xA')
      .addi($v0, $zero, '0xB')
      .syscall()
      ;

    temp.release($2.register, inst); // for variable access
    $$ = inst;
  }
;

variable_access:
  identifier {

    var inst = mips('variable');

    inst.symbol = $1;

    if ($1 === 'true' || $1 === 'false') {
      var reg = temp.$t(inst);
      inst.register = $s1;
      inst.denoter = syms.getDenoter('boolean');
      inst.li(reg, ($1 === 'true')? 1 : 0).sw(reg, $s1);
      temp.release(reg, inst);

    } else if ($1 === 'this') {

      var reg = temp.$t(inst);
      inst.register = reg;
      var cl = syms.getCurrentClass();
      inst.denoter = syms.getDenoter(cl.name);
      inst.sw($s0, $s1).mov(reg, $s1);

    } else {

      var variable = syms.lookup($1);
      inst.denoter = variable.denoter;
      inst.symbol = $1;

      // trying to assign to a function name
      if (variable.isResult) {
        inst.register = $v0;

      } else {

        var reg = temp.$t(inst);
        inst.register = reg;

        if (variable.isParam && variable.isValue) {
          inst
            .comment(reg + ' = addressOf (param:' + $1 + ')')
            .li(reg, 8 + variable.offset)
            .add(reg, reg, $fp)
            ;
        } else if (variable.isParam && variable.isReference) {
          inst
            .comment(reg + ' = &addressOf (param:' + $1 + ')')
            .li(reg, 8 + variable.offset)
            .add(reg, reg, $fp)
            .lw(reg, reg)
            ;
        } else if (variable.isLocal) {
          inst
            .comment(reg + ' = addressOf (local:' + $1 + ')')
            .li(reg, (-1 * variable.offset) - 4)
            .add(reg, $fp, reg)
            ;
        } else if (variable.isInstance) {
          // handle instance vars
          inst
            .comment(reg + ' = addressOf (instance:' + $1 + ')')
            .li(reg, variable.offset)
            .add(reg, $s0, reg)
            ;
        }
      }
    }

    $$ = inst;
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

    var inst = mips('variable').concat($1).concat($3);
    var $i = temp.$t(inst);

    inst.symbol = $1.symbol;
    inst.register = $1.register;
    inst.denoter = $1.denoter.denoter.denoter;

   inst 
      .comment($1.symbol + '[' + lower + '..' + upper + '] = ' + unit + ' * $i')
      .li($i, unit);
      ;

    if (lower !== 0) {
      inst.addi($3, $3, -1*lower);
    }

    inst
      .mult($i, $3)
      .mflo($i)
      .sub($1, $1, $i)
      ;

    // release registers
    temp.release($i, inst);
    temp.release($3.register, inst);

    $$ = inst;
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
    var inst = mips('attribute');
    var reg = temp.$t(inst);

    inst.denoter = variable.denoter;
    inst.symbol = $3;
    inst.register = $1.register;

    inst
      .concat($1)
      .comment('dereferencing ' + $1.symbol + '.' + $3)
      .lw($1, $1)
      .li(reg, variable.offset)
      .add($1, $1, reg)
      ;

    temp.release(reg, inst);

    $$ = inst;
  }
;

method_designator:
  variable_access DOT function_designator {

    var undo = temp.regBackup();

    var method = syms.getMethod($3.name, $1.denoter.name);
    var params = method.getParams();

    var inst = mips('method').concat(undo).concat($1);

    inst.register = $s1;
    inst.symbol = $3.name;
    inst.denoter = method.denoter;

    inst
      .addi($sp, $sp, -4)
      .sw($s0, $sp)
      .comment('setting this context for ' + $1.denoter.name)
      .lw($s0, $1)
      .comment('allocating space for params + (' + 4 * $3.params.length + ' bytes)')
      .addi($sp, $sp, -4 * $3.params.length);
      ;

    $3.params.forEach(function (param, i) {
      // pop the dereference operation
      if (params[i].isReference) {
        param.pop();
      }
      inst.nest(param).sw(param, $sp, 4*i);
    });

    inst
      .comment('making method call to ' + $3.name)
      .jal(method.label)
      .addi($sp, $sp, 4 * $3.params.length)
      .lw($s0, $sp)
      .addi($sp, $sp, 4)
      .concat(undo.mips())
      ;


    inst
      .comment('saving $v0 into temp var')
      .sw($v0, $s1)
      ;

    $$ = inst;
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
    temp.release($1.register, $1);
  }
| expression COLON expression { }
| expression COLON expression COLON expression { }
;

boolean_expression: expression {

  var inst = mips('boolean:expression').concat($1).mov($s2, $1);
  inst.register = $s2
  temp.release($1.register, inst);

  $$ = inst;
};

expression:
  simple_expression { }
| simple_expression relop simple_expression {
    $1.concat($3)
    switch ($2) {
      case '=':
        $1.comment($1.register + ' = ' + $3.register);
        $1.seq($1, $1, $3);
        break;
      case '<>':
        $1.comment($1.register + ' <> ' + $3.register);
        $1.sne($1, $1, $3);
        break;
      case '<':
        $1.comment($1.register + ' < ' + $3.register);
        $1.slt($1, $1, $3);
        break;
      case '<=':
        $1.comment($1.register + ' <= ' + $3.register);
        $1.sle($1, $1, $3);
        break;
      case '>':
        $1.comment($1.register + ' > ' + $3.register);
        $1.slt($1, $3, $1);
        break;
      case '>=':
        $1.comment($1.register + ' >= ' + $3.register);
        $1.sle($1, $3, $1);
        break;
    }
    temp.release($3.register, $1);
  }
;

simple_expression: term
| simple_expression addop term {
    $1.concat($3)
    switch ($2) {
      case '+':
        $1.add($1, $1, $3);
        break;
      case '-':
        $1.sub($1, $1, $3);
        break;
      case 'or':
        $1.or($1, $1, $3);
        break;
    }
    temp.release($3.register, $1);
  }
;

term: factor
| term mulop factor {
    $1.concat($3)
    switch ($2) {
      case '*':
        $1.mult($1, $3);
        $1.mflo($1);
        break;
      case '/':
        $1.div($1, $3);
        $1.mflo($1);
        break;
      case 'mod':
        $1.div($1, $3);
        $1.mfhi($1);
        break;
      case 'and':
        $1.and($1, $1, $3);
        break;
    }
    temp.release($3.register, $1);
  }
;

sign: PLUS | MINUS;

factor:
  sign factor {
    // make the numbers negative on '-'
    if ($1 == '-') {
      $2.sub($2, $zero, $2);
    }
    $$ = $2;
  }
| primary;

primary:
  variable_access {
    var inst = mips('primary:variable').concat($1);
    if ($1.register === $s1) {
      var reg = temp.$t(inst);
      inst.lw(reg, $1.register);
      inst.register = reg;
    } else {
      inst.lw($1.register, $1.register);
      inst.register = $1.register;
    }
    $$ = inst;
  }
| unsigned_constant {
    var inst = mips('primary:constant');
    var reg = temp.$t(inst);
    inst.li(reg, $1);
    inst.register = reg;

    $$ = inst;
  }
| LPAREN expression RPAREN { $$ = $2; }
| function_designator {

    var method = syms.getMethod($1.name);
    var params = method.getParams();
    var undo = temp.regBackup();
    var inst = mips('primary:function').concat(undo);

    inst
      .comment('allocating params + (' + 4 * $1.params.length + ' bytes)')
      .addi($sp, $sp, -4 * $1.params.length)
      ;

    $1.params.forEach(function (param, i) {
      // pop the dereference operation
      if (params[i].isReference) {
        param.pop();
      }
      inst
        .comment('loading param: ' + $1.name + '[' + i + ']')
        .nest(param).sw(param, $sp, 4*i);
    });

    // make call
    inst
      .comment('making function call to ' + $1.name)
      .jal(method.label)
      .addi($sp, $sp, 4 * $1.params.length)
      .concat(undo.mips())
      ;

    var reg = temp.$t(inst);
    inst.mov(reg, $v0);

    inst.register = reg;

    $$ = inst;
  }
| NOT primary {
    $2.not($2, $2);
    $$ = $2;
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
