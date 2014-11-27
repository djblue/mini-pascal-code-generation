program main;

class thingy
begin
  var aa : integer;

  function setAA(ii : integer) : integer;
  begin
    aa := ii;
    setAA := aa
  end;

  function getAA : integer;
  begin
    getAA := aa
  end

end

class thing extends thingy
begin
  var bb : integer;
end

class main
begin

  function main;
    var aa : thing;
  begin
    aa := new thing;
    print aa.setAA(1024);
    aa.bb := 2048;
    print aa.getAA();
    print aa.bb;
    print aa.aa
  end

end
.
