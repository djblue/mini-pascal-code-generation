program testAttributeDesignatorComplex;

class main
BEGIN
   VAR aa, bb, cc : integer;   
END


class testAttributeDesignatorComplex
BEGIN

  FUNCTION testAttributeDesignatorComplex;
     VAR object : main;
  BEGIN
     object := new main;

     object.aa := 500;
     object.bb := 8;
     object.cc := 1;

     PRINT object.aa;
     PRINT object.bb;
     PRINT object.cc;

     
     object.aa := object.bb + object.cc;

     PRINT object.aa
  END

END
.

