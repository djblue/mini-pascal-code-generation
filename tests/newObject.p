program main;

class beep
begin
  var yy, xx : integer;
end

class main 
begin
  var bb : beep;
  function main;
  begin
    bb := new beep;
    bb.xx := 56;
    print bb.xx;
    bb.yy := 24;
    print bb.yy
  end
end
.
