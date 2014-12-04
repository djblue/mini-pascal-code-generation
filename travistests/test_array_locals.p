program testArrayLocal;

class testArrayLocal
BEGIN

  FUNCTION testArrayLocal;
    VAR local  : ARRAY[0..9] OF integer;
        global: ARRAY[0..99] OF integer; 
        local2  : ARRAY[0..9] OF integer;
        counter : integer;
  BEGIN
     local[5] := 88;
     local2[5] := 99;

     counter := 0;
     WHILE counter <= 9 DO
     BEGIN
        local2[counter] := 3;
        counter := counter + 1
     END;

     counter := 0;
     WHILE counter <= 99 DO
     BEGIN
        global[counter] := 2;
        counter := counter + 1
     END;

     PRINT local[5];
     PRINT local2[5]
  END

END
.
