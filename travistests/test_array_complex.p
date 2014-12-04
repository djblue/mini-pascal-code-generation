program testArrayComplex;

class testArrayComplex
BEGIN
   
FUNCTION testArrayComplex;
VAR
   bad	   : ARRAY[0..9] OF integer; 
   good	   : ARRAY[0..9] OF integer;
   counter : integer;
BEGIN
   counter := 0;

   WHILE counter <= 9 DO
   BEGIN
      bad[counter] := 3;
      good[counter] := 3;
      counter := counter + 1
   END;

   PRINT bad[5];
   bad[5] := 8;
   PRINT bad[5];

   PRINT good[8];
   good[bad[5]] := 7;
   PRINT good[8]

END

END
.
