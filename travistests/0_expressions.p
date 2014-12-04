program test1;

class test1
BEGIN

	FUNCTION test1;
	VAR
		aa1, bb1 : integer;
		cc1 : integer;
		dd1 : integer;
	BEGIN
		aa1 := 0;
		bb1 := 1;
		cc1 := 2;
		print aa1; (* 0 *)
		print bb1; (* 1 *)
		print cc1; (* 2 *)
		dd1 := aa1 * bb1;
		print dd1; (* 0 *)
		dd1 := (cc1 * bb1);
		print dd1; (* 2 *)
		dd1 := aa1 + bb1;
		print dd1; (* 1 *)
		dd1 := cc1 * bb1;
		print dd1; (* 2 *)
		dd1 := (aa1 * bb1) + cc1;
		print dd1; (* 2 *)
		dd1 := (aa1 + cc1) * bb1 + 17;
		print dd1; (* 19 *)
		dd1 := ((aa1 + bb1) * cc1 * cc1 * (cc1 * bb1));
		print dd1; (* 8 *)
		dd1 := ((aa1 + bb1) * cc1 * cc1 * (cc1 + bb1));
		print dd1 (* 12 *)
	END       
END
.
