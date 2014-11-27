program main;

class main 
begin

  function ackermann (mm, nn : integer) : integer;
  begin
    if mm < 1
    then
      ackermann := nn + 1
    else
      if nn < 1
      then
        ackermann := ackermann(mm - 1, 1)
      else
        ackermann := ackermann(mm - 1, ackermann(mm, nn - 1))
  end;

  function main;
    var res, mm, nn : integer;
  begin
    mm := 0;
    while mm < 3 do
      begin
        nn := 0;
        while nn < 5 do
          begin
            res := ackermann(mm, nn);
            print res;
            nn := nn + 1
          end;
          mm := mm + 1
      end
  end

end
.
