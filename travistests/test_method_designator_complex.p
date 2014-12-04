program testMethodDesignatorComplex;

class main
BEGIN
   VAR value : integer;
END			  


class testMethodDesignatorComplex
BEGIN

   
  FUNCTION initMainObject (value : integer) : main;
    VAR newObject	 : main;
        dummyValue : integer;
  BEGIN
     newObject := new main;
     newObject.value := value;
     initMainObject := newObject
  END;

  FUNCTION testMethodDesignatorComplex;
    var object : main;
  BEGIN
    object := initMainObject(5);
    PRINT object.value
  END

END
.

