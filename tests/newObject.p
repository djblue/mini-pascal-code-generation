program main;

class boop
begin
  var aa : array[1..5] of integer;
      yy, xx : integer;
end


class beep
begin
  var aa : array[1..5] of integer;
      yy, xx : integer;
      nested : boop;
end

class main 
begin

  function main;
    var bb : beep;
        ii : integer;
  begin

    bb := new beep;
    bb.xx := 56;
    print bb.xx;
    bb.yy := 24;
    print bb.yy;

    ii := 0;
    while  ii < 6 do
      begin
        bb.aa[ii] := ii;
        ii := ii + 1
      end;

    ii := 5;
    while ii > 0 do
      begin
        print bb.aa[ii];
        ii := ii - 1
      end;

    bb.nested := new boop;
    bb.nested.xx := 1000;
    print bb.nested.xx;
    bb.nested.yy := 100;
    print bb.nested.yy;
    bb.nested.aa[1] := 10;
    print bb.nested.aa[1];
    bb.nested.aa[5] := 1;
    print bb.nested.aa[5]

  end
end
.
