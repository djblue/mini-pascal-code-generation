program testFunctionCallBase;

class baseClass
BEGIN

  FUNCTION setCompilerWorks (value: boolean ) : integer;
   VAR lightSwitch	 : boolean;
       compilerWorks : boolean;
  BEGIN
    compilerWorks := value;
    PRINT compilerWorks;
    setCompilerWorks := 21
  END   
   
END


class middleMan extends baseClass
BEGIN
   VAR confusing : boolean;
END		 


class testFunctionCallBase extends middleMan
BEGIN
   
  FUNCTION testFunctionCallBase;
   VAR onOff  : boolean;
       retval : integer;
  BEGIN
     retval := setCompilerWorks(11)
  END

END
.
