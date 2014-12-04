program testExpressionSimple;

class testExpressionSimple
BEGIN

  FUNCTION testExpressionSimple;
     VAR dd, ee : integer;
  BEGIN
     dd := 550;
     ee := (dd / 2) - 200;
     PRINT ee
  END

END
.

