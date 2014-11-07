program main;

class thing
begin
  var aa : integer;
  function action(var ii : integer) : integer;
  begin
    action := ii
  end
end

class main
begin
  function main;
    var aa : thing;
  begin
    aa := new thing;
    print aa.action(256)
  end
end
.
