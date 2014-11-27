program testArrayDim4;

class testArrayDim4
begin

  function testArrayDim4;
    var global  : array[0..99] of array[0..9] of array[10..14] of array [1..3] of integer;
        counter : integer;

  begin

    global[95][5][12][2] := 88;
    print global[95][5][12][2];

    counter := 0;

    while counter <= 99 do
      begin
        global[counter][4][11][2] := 2;
        global[counter][4][11][2] := 2;
        global[counter][4][12][2] := 2;
        global[counter][4][12][2] := 2;
        global[counter][6][12][2] := 2;
        global[counter][6][11][2] := 2;
        global[counter][6][11][2] := 2;
        counter := counter + 1
      end;

    print global[95][5][12][2];
    print global[95][4][11][2];
    print global[95][6][11][2];
    print global[95][6][11][2]

  end

end
.
