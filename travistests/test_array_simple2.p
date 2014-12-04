program testArraySimple2;

class testArraySimple2
BEGIN
   
  FUNCTION testArraySimple2;
     VAR junk    : integer;
         values : ARRAY[4..13] OF integer;
         padding : integer;
  BEGIN
     junk := 88;
     values[13] := junk;
     
     PRINT values[13];
     values[12] := 77;
     padding := 99;
     PRINT values[13]
  END

END
.
