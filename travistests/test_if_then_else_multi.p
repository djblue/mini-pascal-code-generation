program testIfThenElseMulti;

class testIfThenElseMulti
BEGIN

  FUNCTION testIfThenElseMulti;
    VAR aa, bb, cc, dd: integer;
  BEGIN   
    aa := 3;
    cc := 3;

    PRINT cc;
    IF 0 THEN
    BEGIN
      bb := 1;
      dd := 3
    END
    ELSE
    BEGIN
        cc := 4
    END;
    PRINT cc
  END
   
END   
.

