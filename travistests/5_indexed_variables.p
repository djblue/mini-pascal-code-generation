program test1;
class test1
BEGIN

	FUNCTION test1;
	VAR
		a1, b1 : integer;
		c1 : ARRAY[0..1] of integer;
		d1 : ARRAY[0..1] of ARRAY[0..1] of integer;
	BEGIN
		c1[1] := 7;
		d1[1][1] := 3;
		print c1[1]; (* 7 *)
		print d1[1][1] (* 3 *)
	END       
END
.
