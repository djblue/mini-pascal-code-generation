program testArraySimple;

class testArraySimple
BEGIN

  FUNCTION testArraySimple;
    VAR bad	  : ARRAY[4..9] OF integer; 
        good	: ARRAY[78..123] OF integer;
  BEGIN
     bad[5] := 67;
     bad[6] := 70;
     good[99] := bad[9];
     good[99] := bad[6];

     PRINT bad[5];
     PRINT bad[6];
     PRINT good[99]
  END

END
.
