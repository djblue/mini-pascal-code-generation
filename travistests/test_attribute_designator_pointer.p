program testAttributeDesignatorPointer;

class main

BEGIN
   VAR aa, bb, cc : integer;   
END


class testAttributeDesignatorPointer
BEGIN

  FUNCTION testAttributeDesignatorPointer;
    VAR object : main;
        next   : main;
  BEGIN
     object := new main;

     object.aa := 500;
     object.bb := 8;
     object.cc := 1;

     PRINT object.aa;
     PRINT object.bb;
     PRINT object.cc;

    next := new main;
     next := object;
     
     PRINT next.aa;
     PRINT next.bb;
     PRINT next.cc

  END

END
.

