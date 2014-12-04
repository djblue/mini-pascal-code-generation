program testFunctionCallObjectExtend;

class myCustomClass
BEGIN

  VAR
    lightSwitch	   : boolean;
    compilerWorks	 : integer;

  FUNCTION setCompilerWorks (value	: integer) : integer;
  BEGIN
     compilerWorks := value;
     PRINT compilerWorks;
     setCompilerWorks := 2
  END   
   
END


class middleManClass extends myCustomClass
BEGIN
END   

class testFunctionCallObjectExtend
BEGIN

  FUNCTION testFunctionCallObjectExtend;
    VAR onOff	         : boolean;
        myCustomObject : middleManClass;
        retval	       : integer;
  BEGIN
     myCustomObject := NEW middleManClass;
     retval := myCustomObject.setCompilerWorks(11)
  END

END
.
