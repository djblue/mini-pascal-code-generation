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
     yours := new house;

     my.users := 1;
     my.garage := new room;
     my.garage.doors := 3;
     PRINT my.garage.doors;
     yours.livingroom := new room;
     yours.livingroom.doors := 5;
     PRINT yours.livingroom.doors;
     my.garage.windows := 1;
     PRINT my.garage.windows;

     yours.users := renters;
     PRINT yours.livingroom.doors;
     PRINT my.garage.doors;
     yours.livingroom.doors := my.garage.doors;
     yours.livingroom.windows := my.garage.windows;
     
     PRINT yours.livingroom.doors;
     PRINT yours.livingroom.windows;
     PRINT yours.users
  END

END
.
