program testFunctionCallArgAlot;

class testFunctionCallArgAlot

BEGIN
   
   VAR retval : integer;

FUNCTION sum(value1: integer; value2: integer; value3: integer; value4: integer; value5: integer ): integer;
BEGIN
   retval := value1 + value2 + value3 + value4 + value5;
   sum := retval;
   PRINT retval
END;
   
FUNCTION testFunctionCallArgAlot;
BEGIN
   retval := sum(30, 10, 2, 7, -7);
   retval := retval * 2;
   PRINT retval;
   retval := sum(25, 30, -10, 15, -5);
   retval := retval / 5;
   PRINT retval
END

END
.
