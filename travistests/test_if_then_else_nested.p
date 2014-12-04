program testIfThenElseNested;

class testIfThenElseNested
BEGIN

  FUNCTION testIfThenElseNested;
    VAR aa, bb, cc: integer;
  BEGIN   
    aa := 3;
    cc := 6;

    PRINT cc;
    IF False
    THEN
      BEGIN
        bb := 1
      END
    ELSE
      BEGIN
        bb := 0;
        IF cc = 7 
        THEN
          BEGIN
            bb:= 2
          END
        ELSE
          BEGIN
            bb := 5;
            cc := 4
          END
      END;
    
    PRINT bb;
    PRINT cc
  END
   
END   
.

