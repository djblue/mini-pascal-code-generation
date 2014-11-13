program main;

class main
begin
  function main;
    var aa : integer;
  begin
    aa := 10;
    if aa < 11
    then
      begin
        if aa > 8
        then
          begin
            if aa = 10
            then
              begin
                if (aa > 8) and (aa = 10)
                then
                  begin
                    aa := 15
                  end
                else
                  begin
                    aa := aa + 1
                  end
              end
            else
              begin
                aa := aa + 1
              end
          end
        else
          begin
            aa := aa + 1
          end
      end
    else
      begin
        aa := aa - 1
      end;
    print aa
  end
end
.
