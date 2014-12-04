program testFunctionCallClass;

class testFunctionCallClass
BEGIN
   
  FUNCTION setCompilerWorks (value : integer) : integer;
    var counter : integer;
  BEGIN
    counter := value;
    PRINT counter;
    setCompilerWorks := 5
  END;

  FUNCTION testFunctionCallClass;
  VAR compilerWorks : integer;
      counter	      : integer;
  BEGIN
     compilerWorks := setCompilerWorks(8)
  END

END
.
