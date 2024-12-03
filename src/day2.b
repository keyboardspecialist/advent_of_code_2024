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
{	LET safe = 0
	AND line = VEC 32
	AND levels = VEC 8
	AND eof = FALSE

	AND parse
	: <=0,?,?,? BE EXIT
	: =1,[a],?,j 				BE	{ s.levels!j := a - '0'; s.cnt+:=1; EXIT}
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
			IF valid DO safe +:= 1
		}
	}	REPEATUNTIL eof = TRUE

	writef("SAFE %d *n", safe)
}