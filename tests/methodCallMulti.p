program main;

class thing2
begin
  var aa : integer;
  function action(ii : integer) : integer;
  begin
    action := ii
  end
end

class thing
begin
  var bb : thing2;
  function action(ii : integer) : integer;
  begin
    bb := new thing2;
    action := bb.action(512)
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
