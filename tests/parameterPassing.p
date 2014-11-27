program main;

class main 
begin
  function square (aa : integer) : integer;
    var bb : integer;
  begin
    print aa;
    square := aa * aa
  end;
  function main;
    var res : integer;
  begin
    res := square(128);
    print res
  end
end
.
