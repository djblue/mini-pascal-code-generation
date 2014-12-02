# mini-pascal

[![Build Status](https://travis-ci.org/djblue/mini-pascal-code-generation.svg)](https://travis-ci.org/djblue/mini-pascal-code-generation)

Simple code generation for mini object oriented pascal.

# Supported

The following language features are supported. The grammar is defined in the
`pascal.y` file.

### Types

- integer
- boolean
- static arrays[start..end]
- nested static arrays
- custom types via classes

### Statements

- print
- if-else
- while
- assignment
- object instantiation

### Functions

- pass by value
- pass by reference
- local variables
- return values
- recursion via stack

### Classes

- inherited fields
- inherited methods
- method calls

### Expressions

- nested function calls
- logical (not, and, or)
- arithmetic (+, -, \*, /, mod)


# Stack Frame

The generated mips codes setups up the following stack frame for all function
calls.

```
|            |
+------------+
|  param[n]  |
+------------+
|    ...     |
+------------+
|  param[0]  |
+------------+
|    $ra     |
+------------+
|    $fp     |
+------------+
|  local[0]  |
+------------+
|    ...     |
+------------+
|  local[n]  |
+------------+
|    temp    |
```


## Install

To install dependencies, do:

    npm install

## Tests

To run all of the tests, do:

    npm test
