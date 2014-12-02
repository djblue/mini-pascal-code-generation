program main;


class beep
begin

  var aa, bb, cc : integer;

  function beep (aa, cc : integer) : beep;
  begin

    this.aa := aa;
    bb := 12;
    this.cc := cc;

    beep := this
  end

end

class main 
begin

  function main;
    var bb : beep;
  begin

    bb := new beep(1, 123);

    print bb.aa;
    print bb.bb;
    print bb.cc

  end
end
.
