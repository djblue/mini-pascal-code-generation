program main;

class main 
begin
  function go : integer;
  begin
    go := 64
  end;
  function main;
    var aa : integer;
  begin
    aa := 1;
    print aa;
    aa := go();
    print aa;
    aa := aa + go() + 10;
    print aa
  end
end
.
