SECTION ""

GET "u/utils.b" //Try to figure out proper inclusion utils.h should inject this into global manifest

LET start() = VALOF
{	IF NOT set_infile("data/dayN.data") DO
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