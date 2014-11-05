program main;

class main 
begin
  var aa : array[0..3] of integer;
  function main;
  begin
    aa[0] := 1;
    aa[1] := 1;
    aa[2] := aa[1] + aa[0];
    aa[3] := aa[2] + aa[1];

    print aa[0];
    print aa[1];
    print aa[2];
    print aa[3]
  end
end
.
