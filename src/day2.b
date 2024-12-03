SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "RED-NOSED REPORTS"

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 2

	INC = 99
	DEC = -99
	NONE = 0
}

//Using these to keep state during parsing since BCPL doesn't support dynamic free vars
// "closures"
STATIC 
{ s.line
	s.levels
	s.cnt
	s.dir
}

LET start : => VALOF
{	LET fname = VEC 10
	LET scb = set_ramiostrm()
	writef("data/day%n.data", AOC_DAY)
	rewindstream(scb)
	fget_line(fname, scb!scb_end)
	cls_ramiostrm()

	writef("Reading data file... %s*n", fname)

	IF NOT set_infile(fname) DO
	{	writef("Bad file*n")
		RESULTIS 1
	}

	start_timer()
	rn_reports()
	stop_timer()
	cls_infile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}

AND rn_reports : BE
{	LET safe1, safe2 = 0, 0
	AND line = VEC 32
	AND levels = VEC 8
	AND unsafes = VEC 800
	AND ucnt = 0
	AND eof = FALSE

	AND parse
	: <=0,?,?,? BE EXIT
	: =1,[a],?,j 				BE	{ s.levels!j := a - '0'; s.cnt+:=1; EXIT }
	: n, [a, ' '], i, j BE	{ s.levels!j := a - '0'
														s.cnt+:=1
														parse(n-2, @(s.line!(i+2)), i+2, j+1)
													}
	: n, [a, b], i, j		BE	{ s.levels!j := (a - '0') * 10 + (b - '0')
														s.cnt+:=1
														parse(n-3, @(s.line!(i+3)), i+3, j+1)
													}

	AND check_level
	: a,b <a, INC => FALSE
	: a,b >a, DEC => FALSE
	: a,b =a, ?   => FALSE
	: a,b <a, DEC => (a-b) > 3 -> FALSE, TRUE
	: a,b >a, INC => (b-a) > 3 -> FALSE, TRUE
	: a,b <a, NONE => VALOF { s.dir := DEC ;RESULTIS (a-b) > 3 -> FALSE, TRUE }
	: a,b >a, NONE => VALOF { s.dir := INC ;RESULTIS (b-a) > 3 -> FALSE, TRUE }

	//point to our local vecs to avoid the heap
	s.line := line
	s.levels := levels

	{	LET valid = TRUE
		eof := fget_uline(line, 32)
		s.cnt := 0
		s.dir := NONE
		UNLESS line!0 = 0 DO
		{	parse(line!0, @(s.line!1), 1, 0)
			FOR i = 0 TO s.cnt-2 DO 
			{	LET t = check_level(s.levels!i, s.levels!(i+1), s.dir)
				valid := valid & t
			}
			IF valid DO safe1 +:= 1

			IF valid = FALSE DO
			{	unsafes!ucnt := getvec(s.cnt+1)
				sys(Sys_memmovewords, @(unsafes!ucnt!1), s.levels, s.cnt)
				unsafes!ucnt!0 := s.cnt
				ucnt +:= 1
			}
		}
	}	REPEATUNTIL eof = TRUE

	writef("SAFE %d *n", safe1)

	safe2 := safe1

	FOR i = 0 TO ucnt-1 DO
	{	LET valid = TRUE

		FOR j = 1 TO unsafes!i!0 DO
		{	LET tv = VEC 8
			LET x = 0
			FOR k = 1 TO unsafes!i!0 IF k ~= j DO { tv!x := unsafes!i!k; x+:=1 }
			s.dir := NONE
			valid := TRUE
			FOR n = 0 TO x-2 DO
			{	LET a,b = ?, ?
				LET t = ? 
				a := tv!n
				b := tv!(n+1)
				t := check_level(a, b, s.dir)
				valid := valid & t
			}
			IF valid DO { safe2 +:=1; BREAK }
		}
	}

	writef("brute force safe2 %d *n", safe2)

	//I dunno, this is all a mess, finds too many
	//safe2 := safe1

	// FOR i = 0 TO ucnt-1 DO
	// {	LET bads = VEC 8
	// 	AND valid = TRUE

	// //	writef("Checking unsafe %d *n", i)
	// //	FOR l = 1 TO unsafes!i!0 DO writef(" %d ", unsafes!i!l)
	// //	writef("*n")
	// 	bads!0 := 0
	// 	s.dir := NONE
	// 	FOR j = 1 TO (unsafes!i!0)-1 DO
	// 	{LET t = check_level(unsafes!i!j, unsafes!i!(j+1), s.dir)
	// 		IF t = FALSE DO
	// 		{	bads!0 +:= 1
	// 			bads!(bads!0) := j
	// 		}
	// 	}

		// FOR j = 1 TO bads!0 DO
		// {	s.dir := NONE
		// 	valid := TRUE
		// 	FOR k = 1 TO (unsafes!i!0)-1 DO
		// 	{	LET a,b = ?, ?
		// 		LET t = ?
		// 		IF k+1 = unsafes!i!0 & k = bads!j LOOP

		// 	  a := k = bads!j -> 
		// 						(k = 1 -> unsafes!i!(k+1), unsafes!i!(k-1))
		// 						, unsafes!i!k

		// 		b := k = bads!j & k = 1 -> unsafes!i!(k+2), unsafes!i!(k+1)

		// 		t := check_level(a, b, s.dir)

		// 		IF t = FALSE & k <= unsafes!i!0-2 DO
		// 		{
		// 			a := unsafes!i!k
		// 			b := unsafes!i!(k+2)

		// 			t := check_level(a, b, s.dir)
		// 		}
		// 		valid := valid & t
		// 	}

		// 	IF valid DO { safe2 +:= 1; BREAK }
		// }

		//now deal with directional issues
		//backtrack til we clear the bad level that flipped the dir. itll be one of the preceeding 2 of our first marked
		// IF bads!1 >= 2 FOR z = 0 TO 1 DO
		// {	s.dir := NONE
		// 	valid := TRUE
		// 	FOR j = bads!1-z TO unsafes!i!0-1 DO
		// 	{	LET a,b = ?, ?
		// 		LET t = ?
		// 		a := unsafes!i!(j)
		// 		b := unsafes!i!(j+1)

		// 		t := check_level(a, b, s.dir)
		// 		valid := valid & t
		// 	}
		// 	IF valid DO { safe2 +:= 1; BREAK }
		// }

		// IF valid = FALSE  DO
		// {
		// writef("Checking unsafe %d *n", i)
		// FOR l = 1 TO unsafes!i!0 DO writef(" %d ", unsafes!i!l)
		// writef("*n")
		// writef("Found %d bad levels *n", bads!0)
		// FOR l = 1 TO bads!0 DO writef(" %d ", bads!l)
		// writef("*n")
		// }


	//}
	//writef("DAMPENER SAFE %d *n", safe2)

	FOR i = 0 TO ucnt-1 DO freevec(unsafes!i)
}