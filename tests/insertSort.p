program main;

class main
begin

  function main;
    var aa : array[0..10] of integer;
        ii, jj, temp : integer;
  begin
    ii := 10;
    jj := 0;
    while ii > 0 do
    begin
      aa[jj] := ii;
      jj := jj + 1;
      ii := ii - 1
    end;

    ii := 0;
    while ii < 10 do
    begin
      print aa[ii];
      ii := ii + 1
    end;

    ii := 0;
    while ii < 10 do
    begin
      jj := ii;
      while (jj > 0) AND (aa[jj - 1] > aa[jj]) do
      begin
        temp := aa[jj];
        aa[jj] := aa[jj - 1];
        aa[jj - 1] := temp;
        jj := jj - 1
      end;
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
