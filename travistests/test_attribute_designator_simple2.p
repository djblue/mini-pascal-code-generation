program testAttributeDesignatorSimple2;

class main

BEGIN
   VAR aa, bb, cc : integer;   
END


class testAttributeDesignatorSimple2
BEGIN

  FUNCTION testAttributeDesignatorSimple2;
     VAR object : main;
  BEGIN
     object := new main;

     object.aa := 500;
     object.bb := 8;
     object.cc := 1;

     PRINT object.aa;
     PRINT object.bb;
     PRINT object.cc
  END

END
.

