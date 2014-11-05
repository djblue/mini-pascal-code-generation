program main;

class main 
begin
  var aa : integer;
  function main;
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
