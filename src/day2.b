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

STATIC 
{ s.line
	s.levels
	s.cnt
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
	AND dir = NONE //ascending or descending
	AND line = VEC 32
	AND levels = VEC 8
	AND eof = FALSE

	AND parse
	: <=0,?,?,? BE EXIT
	: n, [a, ' '|'*n'], i, j BE { s.levels!j := a - '0'; parse(n-3, @(s.line!(i+2)), i+2, j+1); s.cnt+:=1}
	: n, [a, b], i, j BE { s.levels!j := (a - '0') * 10 + (b - '0'); parse(n-3, @(s.line!(i+3)), i+3, j+1); s.cnt+:=1 }

	s.line := line
	s.levels := levels
	{	eof := fget_uline(line, 32)
		s.cnt := 0
		IF line!0 > 0 DO parse(line!0, @(s.line!1), 1, 0)
		FOR i = 0 TO s.cnt DO writef(" %d ", s.levels!i)
		writef("*n")
	}	REPEATUNTIL eof = TRUE
}