program testArrayDim4;

class testArrayDim4

BEGIN
   
FUNCTION testArrayDim4;
  VAR global  : ARRAY[0..99] OF ARRAY[0..9] OF ARRAY[10..14] OF ARRAY [1..3] OF integer; 
      counter : integer;
BEGIN
   global[95][5][12][2] := 88;
   PRINT global[95][5][12][2];
   
   counter := 0;
   WHILE counter <= 99 DO
   BEGIN
      global[counter][4][11][2] := 2;
      global[counter][4][11][2] := 2;
      global[counter][4][12][2] := 2;
      global[counter][4][12][2] := 2;
      global[counter][6][12][2] := 2;
      global[counter][6][11][2] := 2;
      global[counter][6][11][2] := 2;
      counter := counter + 1
   END;

   PRINT global[95][5][12][2];
   PRINT global[95][4][11][2];
   PRINT global[95][6][11][2];
   PRINT global[95][6][11][2]
END

END
.
