program main;

class ob
begin
  var block : array[0..10] of integer;
end

class main 
begin

  function mutate (var aa : ob) : ob;
  begin
    aa.block[5] := 1000;
    mutate := aa
  end;

  function main;
    var null, aa : ob;
  begin
    aa := new ob;
    null := mutate(aa);
    print aa.block[5];
    print null.block[5]
  end

end
.
