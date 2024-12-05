SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "CERES SEARCH"

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 4

}

STATIC
{	s.grid
	s.xvec
	s.xcnt

	s.xmascnt
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
	ceres()
	stop_timer()
	cls_infile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}

AND ceres : BE
{	LET ch = ?
	AND stride = 0
	AND rows = 1

	LET grid = VEC 5000
	AND xvec = VEC 1000
	AND xcnt = 0

	LET dirs = TABLE UP, DOWN, LEFT, RIGHT, UPL, UPR, DNL, DNR

	LET checkdir
	: UP, x ?, y >3, ?, ? BE {}
	: DOWN,x ?,y ?, ?, >3 BE {}
	: RIGHT, x ?,y ?, >3, ? BE {}
	: LEFT,x >3,y?, ?,  ? BE {}
	: UPL, x >3,y >3, ?, ? BE {}
	: UPR, x ?,y >3, >3, ? BE {}
	: DNL, x >3,y ?, ?, >3 BE {}
	: DNR, x ?, y ?, >3,>3 BE {}


	s.grid := grid
	s.xvec := xvec

	ch := rdch()
	UNTIL ch = endstreamch EVERY(ch)
		: '*n'	BE IF stride = 0 DO stride := g.hFile!scb_pos <> rows +:= 1
		: 'X'		BE xvec!xcnt := g.hFile!scb_pos <> xcnt +:= 1
		: c'A'..'Z'	BE grid%(g.hFile!scb_pos) := c
		: ?			BE ch := rdch()


	s.xcnt := xcnt //just in case

	s.xmascnt := 0
  // 8 search dirs
	//    \  ^  /
	//     \ ^ /
	//      \^/
	// < < < X > > >
	//      /.\
	//     / . \
	//    /  .  \

	FOR i = 0 TO xcnt DO
	{	LET x = xvec!xcnt MOD stride
		LET y = xvec!xcnt / stride

		FOR d = 0 TO 7 DO checkdir(dirs!d, x, y, stride-x, rows-y)
		//fwd
		IF stride - x >= 3 DO
		{

		}

		//back
		IF x >= 3 DO
		{

		}

		//up, up-lef
		IF y > 3 DO
		{

		}

		//down
		IF rows - y >= 3 DO
		{

		}

		//up-left
	}

	writef("rows %d stride %d, and X's found %d *n", rows, stride, xcnt)

}