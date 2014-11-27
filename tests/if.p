program main;

class main 
begin

  function main;
    var aa : integer;
  begin
    aa := 10;
    if aa <> 10
    then
      begin
        aa := aa + 1
      end
    else
      begin
        aa := aa - 1
      end;
    print aa
  end

end
.
