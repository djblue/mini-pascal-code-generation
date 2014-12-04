program testAttributeDesignatorMulti;

class room
BEGIN
   VAR doors   : integer;
       windows : integer;
END	      


class house
BEGIN
   VAR users	    : integer;
       livingroom : room;
       garage	    : room;
END		 


class testAttributeDesignatorMulti
BEGIN
   
  FUNCTION testAttributeDesignatorMulti;
    VAR renters : integer;
        my      : house;
        yours   : house;

  BEGIN
     renters := 6;
     my := new house;
     my.livingroom := new room;
     my.garage := new room;

     yours := new house;
     yours.livingroom := new room;
     yours.garage := new room;

     my.users := 1;
     my.garage.doors := 3;
     my.garage.windows := 1;
     PRINT my.garage.doors;
     PRINT my.garage.windows;

     yours.users := renters;
     yours.livingroom.doors := my.garage.doors;
     yours.livingroom.windows := my.garage.windows;
     
     PRINT yours.livingroom.doors;
     PRINT yours.livingroom.windows;
     PRINT yours.users
  END

END
.
