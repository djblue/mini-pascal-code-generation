program main;

class main 
begin

  function main;
    var aa : array[0..6] of array[0..6] of integer;
  begin
    aa[5][5] := 512;
    print aa[5][5]
  end

end
.
