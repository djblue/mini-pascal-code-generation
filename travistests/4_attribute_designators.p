program test1;

class test3
BEGIN
	VAR
		a3, b3 : integer;
END       

class test2
BEGIN
	VAR
		a2 : test3;
		b2 : integer;
END       

class test1
BEGIN
	FUNCTION test1;
		VAR
		  c1 : integer;
			a1 : test2;
	BEGIN
		a1 := new test2;
		a1.a2 := new test3;
		a1.a2.a3 := 107;
		a1.b2 := 91;
		a1.a2.b3 := a1.b2 * a1.a2.a3;
		print a1.a2.a3;
		print a1.b2;
		print a1.a2.b3
	END       
END
.
