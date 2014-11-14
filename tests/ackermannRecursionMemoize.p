program main;

class ackermann
begin

  var memo : array[0..10] of array[0..10] of integer;

  function ackermannMemo (var mm, nn : integer) : integer;
  begin
    if memo[mm][nn] = 0 then
      begin
        if mm < 1 then
          memo[mm][nn] := nn + 1
        else
          begin
            if nn < 1
            then
              memo[mm][nn] := ackermannMemo(mm - 1, 1)
            else
              memo[mm][nn] := ackermannMemo(mm - 1, ackermannMemo(mm, nn - 1))
          end;
        ackermannMemo := memo[mm][nn]
      end
    else
      begin
        ackermannMemo := memo[mm][nn]
      end
  end
end

class main
begin
  function main;
    var res, mm, nn : integer;
                 aa : ackermann;
  begin
    mm := 0;
    aa := new ackermann;
    while mm < 3 do
      begin
        nn := 0;
        while nn < 5 do
          begin
            res := aa.ackermannMemo(mm, nn);
            print res;
            nn := nn + 1
          end;
          mm := mm + 1
      end
  end

end
.
