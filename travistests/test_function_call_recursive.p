program testFunctionCallRecursive;

class testFunctionCallRecursive
BEGIN
   
  FUNCTION fibonacci(value : integer): integer;
  BEGIN

    IF value = 1 THEN
      fibonacci := 1
    ELSE
      fibonacci := fibonacci(value - 1) + value

  END;

  FUNCTION testFunctionCallRecursive;
    VAR retval : integer;
  BEGIN
    retval := fibonacci(5);
    PRINT retval
  END

END
.
