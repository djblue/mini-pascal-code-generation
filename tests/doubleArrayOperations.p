program main;

class main 
begin

  function main;
    var aa, bb, cc : array[1..10] of array[1..10] of integer;
  begin

    aa[5][5] := 2;
    bb[3][3] := aa[5][5] + 2;
    cc[4][4] := bb[3][3] / aa[5][5];
    cc[4][4] := cc[4][4] * aa[5][5];

    print aa[5][5];
    print bb[3][3];
    print cc[4][4]

  end

end
.
