program main;

class main 
begin

  function sum (aa, bb, cc, dd, ee, ff, gg, hh, ii : integer) : integer;
  begin
    sum := (aa + bb + cc) + (dd + ee + ff) + (gg + hh + ii)
  end;

  function main;
    var res : integer;
  begin
    res := sum(1,2,3,4,5,6,7,8,9);
    print res
  end

end
.
