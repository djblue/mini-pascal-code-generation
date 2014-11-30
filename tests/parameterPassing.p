program main;

class main 
begin

  function square (aa : integer) : integer;
  begin
    print aa;
    square := aa * aa
  end;

  function squareRef (var aa : integer) : integer;
  begin
    aa := aa * aa;
    squareRef := 0
  end;

  function main;
    var res, aa : integer;
  begin
    res := square(128);
    print res;

    aa := 1024;
    res := squareRef(aa);
    print res;
    print aa
  end

end
.
