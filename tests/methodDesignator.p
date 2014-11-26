program testMethodDesignatorSimple;

class main
begin
 var value : integer;
end       

class testMethodDesignatorSimple
begin

  function initMainObject(value : integer) : integer;
  begin
    initMainObject := 8
  end;

  function testMethodDesignatorSimple;
    var dummyValue : integer;
  begin
    dummyValue := initMainObject(5);
    print dummyValue
  end

end
.
