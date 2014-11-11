program main;

class main 
begin

  function main;
    var aa : array[1..10] of integer;
        ii : integer;
  begin

    aa[1] := 1;
    aa[2] := 1;

    ii := 3;
    while ii < 11 do
    begin
      aa[ii] := aa[ii - 1] + aa[ii - 2];
      ii := ii + 1
    end;

    ii := 1;
    while ii < 11 do
    begin
      print aa[ii];
      ii := ii + 1
    end

  end

end
.
