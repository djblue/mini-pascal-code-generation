program testWhileDo;

class testWhileDo
BEGIN

  FUNCTION testWhileDo;
    VAR cc : integer;
  BEGIN 
    cc := 0;
    WHILE cc < 7 DO
      BEGIN
        cc := cc + 1
      END;
    PRINT cc
  END
END
.
