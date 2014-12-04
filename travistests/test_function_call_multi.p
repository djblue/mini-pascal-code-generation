program testFunctionCallMulti;

class testFunctionCallMulti
BEGIN

  FUNCTION setCompilerWorks (value1: integer; value2: integer) : integer;
    VAR compilerWorks : integer;
        counter       : integer;
  BEGIN
    counter := value1 + value2;
    PRINT counter;
    setCompilerWorks := 5
  END;

  FUNCTION testFunctionCallMulti;
    VAR compilerWorks : integer;
  BEGIN
    compilerWorks := setCompilerWorks(2,8)
  END

END
.
