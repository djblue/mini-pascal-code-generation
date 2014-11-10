program main;

class first
begin
  var qq : array[1..100] of integer;
end

class boop extends first
begin
  var aa : array[1..5] of integer;
end


class beep extends boop
begin
  var yy, xx : integer;
end

class main 
begin

  var bb : beep;
      parent : boop;
      ii : integer;

  function main;
  begin

    bb := new beep;
    bb.xx := 56;
    print bb.xx;
    bb.yy := 24;
    print bb.yy;

    parent := bb;

    ii := 0;
    while  ii < 6 do
      begin
        parent.aa[ii] := ii;
        ii := ii + 1
      end;

    ii := 5;
    while ii > 0 do
      begin
        print parent.aa[ii];
        ii := ii - 1
      end

  end
end
.
