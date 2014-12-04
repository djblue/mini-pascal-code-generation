program test1;
class test1
BEGIN
	FUNCTION test1;
	VAR
		aa1, bb1, cc1 : integer;
		dd1 : boolean;
	BEGIN
		aa1 := 13;
		bb1 := 7;
		cc1 := 0;
		IF aa1 > bb1
		THEN
			BEGIN
				cc1 := cc1 - 1;
				IF aa1 < bb1
				THEN
					BEGIN
						cc1 := cc1 - 1
					END
				ELSE
					BEGIN
						cc1 := cc1 + 1
					END
			END
		ELSE
			BEGIN
				cc1 := cc1 + 1
			END;
		print cc1
	END       
END
.
