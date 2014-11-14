program main;

class ackermann
begin
  var memo : array[0..10] of array[0..10] of integer;
  function ackermann (var mm, nn : integer) : integer;
  begin
    if memo[mm][nn] = 0 then
    begin
      if mm < 1
      then
        memo[mm][nn] := nn + 1
      else
        if nn < 1
        then
          memo[mm][nn] := ackermann(mm - 1, 1)
        else
          memo[mm][nn] := ackermann(mm - 1, ackermann(mm, nn - 1))
      end;
      ackermann = memo[mm][nn]
    else
    begin
      ackermann = memo[mm][nn]
    end
end

class main
begin
  function main;
    var res, mm, nn : integer;
              aa    : ackermann;
  begin
    mm := 0;
    aa = new ackermann;
    while mm < 5 do
      begin
        nn := 0;
        while nn < 6 do
          begin
            res := aa.ackermann(mm, nn);
            print res;
            nn := nn + 1
          end;
          mm := mm + 1
      end
  end

end
.
