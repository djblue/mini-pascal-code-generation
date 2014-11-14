program main;

class insertionSort
begin

  function sort(var aa : array[0..10] of integer) : integer;
  begin
    print aa[0];
    aa[1] := 1;
    sort := aa[1]
  end

end

class main
begin
  function main;
    var aa   : array[0..10] of integer;
      sorter : insertionSort;
      temp   : integer;
  begin
    aa[0] := 1;
    sorter := new insertionSort;
    temp := sorter.sort(aa);
    print aa[1]
  end
end
.
