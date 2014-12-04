program testFunctionCallObject;

class myCustomClass
BEGIN
   
  VAR lightSwitch	   : boolean;
      compilerWorks	 : integer;

  FUNCTION setCompilerWorks (value : integer) : integer;
  BEGIN
    compilerWorks := value;
    PRINT compilerWorks;
    setCompilerWorks := 4
  END   
   
END



class testFunctionCallObject
BEGIN
   
  FUNCTION testFunctionCallObject;
    VAR onOff	         : boolean;
        myCustomObject : myCustomClass;
        retval	       : integer;
  BEGIN
     myCustomObject := NEW myCustomClass;
     retval := myCustomObject.setCompilerWorks(11)
  END

END
.
