program main;

class main begin

  function main;
    var aa, bb, ii : integer;
  begin

    aa := 1 +
        ( 2 +
        ( 3 + 
        ( 4 +
        ( 5 +
        ( 6 +
        ( ( ( 7 - 7 ) -
            ( 7 - 7 ) -
            ( 7 - 7 ) -
            ( 7 - 7 ) -
            ( 7 - 7 ) -
            ( 7 - 7 ) -
            ( 7 - 7 ) -
            ( 7 - 7 ) + 7 ) +
        ( 8 +
        ( 9 +
        ( 10 +
        ( 11 +
        ( 12 +
        ( 13 +
        ( 14 +
        ( 15 +
        ( 16 +
        ( 17 +
        ( 18 +
        ( 19 +
        ( 20 )))))))))))))))))));

    bb := 0;
    ii := 1;

    while ii <= 20 do
      begin
        bb := bb + ii;
        ii := ii + 1
      end;

    if aa = bb then
      begin
        print true
      end
    else
      begin
        print false
      end
  end

end
.
