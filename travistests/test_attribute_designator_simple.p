program testAttributeDesignatorSimple;

class BB
BEGIN
   VAR row : integer;
END


class AA extends BB
BEGIN
   VAR works : integer;
END


class testAttributeDesignatorSimple
BEGIN

  FUNCTION testAttributeDesignatorSimple;
     VAR aa      : integer;
         bb      : integer;
        objectAA : AA;
  BEGIN
     aa := 6;
     bb := 7;
     objectAA := new AA;
     objectAA.works := aa;
     bb := objectAA.works;
     
     PRINT bb;
     PRINT objectAA.works
  END

END
.
