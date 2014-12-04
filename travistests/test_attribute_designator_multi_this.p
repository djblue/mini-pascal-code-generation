program testAttributeDesignatorMultiThis;

class room
BEGIN
   VAR doors  : integer;
      windows : integer;
END	      


class house
BEGIN
   VAR users	 : integer;
      this	 : room;
      livingroom : room;
      garage	 : room;
END		 


class testAttributeDesignatorMultiThis
BEGIN
   
  FUNCTION testAttributeDesignatorMultiThis;
    VAR renters : integer;
        my      : house;
        yours   : house;
  BEGIN
    yours := new house;
    my := new house;
    yours.livingroom := new room;
    my.this := new room;
     yours.livingroom.doors := 5;
     my.this.doors := yours.livingroom.doors;

     PRINT my.this.doors
  END

END
.
