program testFunctionCallClassByRef;

class testFunctionCallClassByRef
BEGIN

  FUNCTION setCompilerWorks(VAR value : integer ): integer;
  BEGIN
     value := 8;
     setCompilerWorks := value
  END ;

  FUNCTION testFunctionCallClassByRef;
    VAR retval  : integer;
        counter : integer;
  BEGIN
     counter := 9;
     PRINT counter;
     
     retval := setCompilerWorks(counter);
     
     PRINT counter
  END

END
.
