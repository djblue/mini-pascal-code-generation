program testFunctionCallArgArray;

class myArray
begin
  var value : ARRAY[0..9] OF integer;
end

class testFunctionCallArgArray
BEGIN
   
  FUNCTION setCompilerWorks (aa : myArray) : integer;
  BEGIN
     PRINT aa.value[6];
     setCompilerWorks := 0
  END;

  FUNCTION testFunctionCallArgArray;
    VAR dummyArray : myArray;
        retval	  : integer;
  BEGIN
    dummyArray := new myArray;
    dummyArray.value[6] := 8;
    retval := setCompilerWorks(dummyArray)
  END

END
.
