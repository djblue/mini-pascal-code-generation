program test1;
class test1
BEGIN
	FUNCTION test1;
	VAR
		aa1, bb1 : integer;
		cc1 : boolean;
	BEGIN
		aa1 := 0;
		bb1 := 1;
		cc1 := aa1 > bb1;
		print cc1;
		cc1 := aa1 < bb1;
		print cc1
	END       
END
.
