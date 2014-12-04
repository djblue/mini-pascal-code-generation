program testIfThenElse;

class testIfThenElse

BEGIN

  FUNCTION testIfThenElse;
    VAR aa, bb: integer;
  BEGIN   
    aa := 3;

    if aa = 0
    THEN
      BEGIN
        bb := 7
      END
    ELSE
      BEGIN
        bb := 9
      END;
    PRINT bb
  END
END   
.
