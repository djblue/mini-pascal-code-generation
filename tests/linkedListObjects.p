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

class account
begin
  var userId, balance : integer;
      critical : boolean;
  function printAccount : integer;
  begin
    print userId;
    print balance;
    print critical;
    printAccount := 0
  end
end

class myNode extends node
begin

  var data : integer;
      account : account;

  function myNode (aa : integer; var account : account) : myNode;
  begin
    data := aa;
    this.account := account;
    myNode := this
  end

end


class myList extends list
begin

  var accountCount : integer;

  function myList;
  begin
    accountCount := 256
  end;

  function pushMyNode (aa : integer) : myList;
    var temp : myNode;
        null : node;
        newAccount : account;
  begin
    newAccount := new account;

    newAccount.userId := accountCount;
    newAccount.balance := 0;
    newAccount.critical := true;

    accountCount := accountCount + 1;

    temp := new myNode(aa, newAccount);
    pushMyNode := push(temp)
  end;

  function printList;
    var temp : myNode;
        null : integer;
  begin
    temp := head;
    while temp <> 0 do
    begin
      print temp.data;
      null := temp.account.printAccount();
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
