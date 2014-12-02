program main;

class node 
begin

  var data : integer;
      next : node;

end

class list
begin
  var head : node;

  function push (data : integer) : list;
    var newNode : node;
  begin
    newNode := new node;
    newNode.data := data;
    newNode.next := head;
    head := newNode;
    push := this
  end;

  function printList;
    var temp : node;
  begin
    temp := head;
    while temp <> 0 do
    begin
      print temp.data;
      temp := temp.next
    end
  end

end

class main 
begin

  function main;
    var ll, null : list;
        ii : integer;
  begin
    ll := new list;
    ii := 0;
    while ii < 10 do
      begin
        null := ll.push(ii);
        ii := ii + 1
      end;
    null := ll.printList()
  end

end
.
