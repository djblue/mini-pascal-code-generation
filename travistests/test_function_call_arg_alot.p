program testFunctionCallArgAlot;

class testFunctionCallArgAlot
BEGIN
   
  FUNCTION sum(value1: integer; value2: integer; value3: integer; value4: integer; value5: integer) : integer;
    VAR retval : integer;
  BEGIN
     retval := value1 + value2 + value3 + value4 + value5;
     PRINT retval;
     sum := retval
  END;
   
  FUNCTION testFunctionCallArgAlot;
     VAR retval : integer;
  BEGIN
     retval := sum(30, 10, 2, 7, -7)
  END

END
.
