program main;

class node 
begin
  var next : node;
end

class list
begin

  var head : node;

  function push (var node : node) : list;
  begin
    node.next := head;
    head := node;
    push := this
  end

end


class myNode extends node
begin

  var data : integer;

  function myNode (aa : integer) : myNode;
  begin
    data := aa;
    myNode := this
  end

end


class myList extends list
begin

  function pushMyNode (aa : integer) : myList;
    var temp : myNode;
        null : node;
  begin
    temp := new myNode(aa);
    pushMyNode := push(temp)
  end;

  function printList;
    var temp : myNode;
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
    var ll, null : myList;
        ii : integer;
  begin
    ll := new myList;
    ii := 0;
    while ii < 10 do
      begin
        null := ll.pushMyNode(ii);
        ii := ii + 1
      end;
    null := ll.printList()
  end

end
.
