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

	SPACE = -1
	EOL = -2
	EOF = -3
}

LET start() = VALOF
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

AND rn_reports() BE
{	LET safe = 0
	AND lc, lp = 0, -1 //current and prev level

	LET chkch(c) = MATCH(c)
		: ' '  => SPACE
		: '0'..'9' => c - '0'
		: '*n' => EOL
		: endstreamch => EOF

	LET c, i = 0, 1
	AND dir = 0 //ascending or descending
	{	c := chkch(rdch())
		SWITCHON c INTO
		{	DEFAULT:	{	lc +:= c * (i * 10) //handle numeric
									i +:= 1
								}

			CASE -1:
			CASE -2:	{	LET diff = 0
									IF lp = -1 DO { lp := lc; LOOP }
									IF lp = lc GOTO RESET

									diff := lc - lp
									IF diff < -2 | diff > 2 GOTO RESET

									IF dir = 0 DO dir := diff > 0 -> INC, DEC
									// TEST dir = 0
									// THEN	{	IF lc <

									// 			}

								}
			ENDCASE

			CASE -3:	BREAK
		}
RESET:
		UNLESS c ~= EOL UNTIL c = '*n' | c = endstreamch DO {c := rdch(); writef("%d*n", c) }
		dir := 0
		c := 0
		i := 1


	}	REPEAT
}