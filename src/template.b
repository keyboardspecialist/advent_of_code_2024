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
	LET scb = set_ramiostrm()
	writef("data/day%n.data", AOC_DAY)
	rewindstream(scb)
	fget_line(fname, scb!scb_end)
	cls_ramiostrm()

	writef("Reading data file... %s*n", fname)
	
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