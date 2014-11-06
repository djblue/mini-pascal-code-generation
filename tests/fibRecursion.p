program main;

class main 
begin

  function fib (var nn : integer) : integer;
  begin
    if nn < 3
    then
      begin
        fib := 1
      end
    else
      begin
        fib := fib(nn - 1) + fib(nn - 2)
      end
  end;

  function main;
    var res : integer;
  begin
    res := fib(12);
    print res
  end

end
.
