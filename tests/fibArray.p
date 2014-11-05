program main;

class main 
begin

  var aa : array[0..9] of integer;
      ii : integer;

  function main;
  begin

    aa[0] := 1;
    aa[1] := 1;

    ii := 2;
    while ii < 10 do
    begin
      aa[ii] := aa[ii - 1] + aa[ii - 2];
      ii := ii + 1
    end;

    ii := 0;
    while ii < 10 do
    begin
      print aa[ii];
      ii := ii + 1
    end

  end

end
.
