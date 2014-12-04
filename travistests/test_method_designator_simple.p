program testMethodDesignatorSimple;

class main
BEGIN
  VAR value : integer;
END			  


class testMethodDesignatorSimple
BEGIN
   
  FUNCTION initMainObject (value : integer) : integer;
  BEGIN
    initMainObject := 8
  END;

  FUNCTION testMethodDesignatorSimple;
    VAR dummyValue : integer;
  BEGIN
     dummyValue := initMainObject(5);
     PRINT dummyValue
  END

END
.
