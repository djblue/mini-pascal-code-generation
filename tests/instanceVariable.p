program main;

class store
begin

  var aa : array[1..50] of integer; 
      yy, xx, zz : integer;
      ww : array[51..100] of integer; 

  function setXX (var argxx : integer) : integer;
  begin
    xx := argxx;
    setXX := argxx
  end;

  function getXX : integer;
  begin
    getXX := xx
  end
end

class main 
begin

  function main;
    var ss : store;
  begin
    ss := new store;
    print ss.setXX(256);
    ss.yy := 0;
    ss.zz := 0;
    print ss.getXX();
    print ss.setXX(512);
    ss.zz := 0;
    ss.yy := 0;
    print ss.getXX()
  end
end
.
