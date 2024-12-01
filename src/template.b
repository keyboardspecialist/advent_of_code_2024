SECTION ""

GET "u/utils.h"
GET "u/utils.b"

.

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 1

}


LET start() = VALOF
{	LET fname = VEC 10
	LET scb = set_ramostrm()
	writef("data/day%n.data", AOC_DAY)
	rewindstream()
	fget_line(fname, scb!end)
	cls_outfile()
	writef("fname is %s *n", fname)
	
	IF NOT set_infile("data/dayN.data") DO
	{	writef("Bad file*n")
		RESULTIS 1
	}

	start_timer()
	//advent func here
	stop_timer()
	cls_infile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}