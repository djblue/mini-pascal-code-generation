program testAttributeDesignatorSimple3;

class AA
BEGIN
VAR row      : integer;
    yourBoat : integer;
END	       


class BB
BEGIN
VAR number	   : integer;
    elite	   : integer;
END	   

class testAttributeDesignatorSimple3
BEGIN

  FUNCTION testAttributeDesignatorSimple3;
    VAR aa : integer;
        bb : integer;
  BEGIN
     aa := 1;
     bb := 2;
     PRINT aa;
     PRINT bb
  END

END
.
