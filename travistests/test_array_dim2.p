program testArrayDim2;

class testArrayDim2

BEGIN
FUNCTION testArrayDim2;
  var global  : ARRAY[0..99] OF ARRAY[0..9] of integer; 
      counter : integer;
BEGIN
   global[95][5] := 88;
   PRINT global[95][5];
   
   counter := 17;
   WHILE counter <= 99 DO
   BEGIN
      global[counter][4] := 2;
      global[counter][6] := 2;
      counter := counter + 1
   END;

   PRINT global[95][5]
END

END
.
