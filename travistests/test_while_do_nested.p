program testWhileDoNested;

class testWhileDoNested
BEGIN
   
  FUNCTION testWhileDoNested;
    VAR bb, cc, dd : integer;
  BEGIN   
    cc := 0;
    dd := 1;
    bb := 0;

    PRINT cc;
    PRINT dd;
    PRINT bb;
    WHILE cc < 7 DO
      BEGIN
        cc := cc + 1;
        WHILE dd < 5 DO
          BEGIN
            dd := dd * 2;
            bb := bb + 3
          END
      END;

    PRINT cc;
    PRINT dd;
    PRINT bb
  END

END
.

