SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "CERES SEARCH"

GET "u/utils.h"

MANIFEST
{	AOC_DAY = 4

	UP = 0
	DOWN
	LEFT
	RIGHT
	UPL
	UPR
	DNL
	DNR
}

STATIC
{	s.grid
	s.xvec
	s.xcnt

	s.stride

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
	AND scbpos = 0
	AND stride = 0
	AND rows = 1

	LET grid = VEC 5000
	AND xvec = VEC 5000
	AND avec = VEC 5000
	AND xcnt = 0
	AND acnt = 0

	//live mas, etc
	LET checkmas
	: 'M', 'A', 'S' BE s.xmascnt +:= 1
	: ? BE EXIT

	//dir, x, y, dist from right, dist from bottom
	LET checkdir
	: UP, x ?, y >=3, ?, ? BE	{	LET mp, ap, xp = (y-1) * s.stride + x, (y-2) * s.stride + x, (y-3) * s.stride + x
															checkmas(s.grid%mp,s.grid%ap,s.grid%xp)
														}

	: DOWN,x ?,y ?, ?, >=3 BE	{	LET mp, ap, xp = (y+1) * s.stride + x, (y+2) * s.stride + x, (y+3) * s.stride + x
															checkmas(s.grid%mp,s.grid%ap,s.grid%xp)
														}

	: RIGHT,x ?,y ?, >=3,? BE	{	LET offs = y * s.stride + x
															checkmas(s.grid%(offs+1),s.grid%(offs+2),s.grid%(offs+3))
														}
	
	: LEFT,x >=3,y?, ?,  ? BE	{	LET offs = y * s.stride + x
															checkmas(s.grid%(offs-1),s.grid%(offs-2),s.grid%(offs-3))
														}

	: UPL, x >=3,y >=3, ?, ? BE	{	LET mp, ap, xp = (y-1) * s.stride + x-1, (y-2) * s.stride + x-2, (y-3) * s.stride + x-3
																checkmas(s.grid%mp,s.grid%ap,s.grid%xp)
															}

	: UPR, x ?,y >=3, >=3, ? BE	{	LET mp, ap, xp = (y-1) * s.stride + x+1, (y-2) * s.stride + x+2, (y-3) * s.stride + x+3
																checkmas(s.grid%mp,s.grid%ap,s.grid%xp)
															}

	: DNL, x >=3,y ?, ?, >=3 BE	{	LET mp, ap, xp = (y+1) * s.stride + x-1, (y+2) * s.stride + x-2, (y+3) * s.stride + x-3
																checkmas(s.grid%mp,s.grid%ap,s.grid%xp)
															}

	: DNR, x ?, y ?, >=3,>=3 BE	{	LET mp, ap, xp = (y+1) * s.stride + x+1, (y+2) * s.stride + x+2, (y+3) * s.stride + x+3
																checkmas(s.grid%mp,s.grid%ap,s.grid%xp)
															}
	//:	c?, x?,y?,?,? BE writef("NOT MATCHED! %s  ::  %d  ,  %d *n",dir2str(c), x, y)

	LET x.mas
	: 'M', 'M', 'S', 'S' BE s.xmascnt +:= 1

	s.grid := grid
	s.xvec := xvec

	ch := rdch()
	UNTIL ch = endstreamch 
	EVERY(ch)
		: '*n'	BE { IF stride = 0 DO stride := scbpos; rows +:= 1 }
		: 'X'		BE xvec!xcnt := scbpos <> xcnt +:= 1
		: 'A'		BE avec!acnt := scbpos <> acnt +:= 1
		: c'A'..'Z'	BE grid%scbpos := c <> scbpos +:= 1
		: ?			BE ch := rdch()

	writef("Found As ->  %d *n", acnt)

	s.xcnt := xcnt //just in case
	s.stride := stride
	s.xmascnt := 0

	FOR i = 0 TO xcnt-1 DO
	{	LET x = xvec!i MOD stride 
		LET y = xvec!i / stride
		FOR d = 0 TO 7 DO checkdir(d, x, y, stride-x, rows-y)
	}

	writef("XMAS %d *n", s.xmascnt)

	s.xmascnt := 0
	FOR i = 0 TO acnt-1 DO
	{	LET x = avec!i MOD stride 
		LET y = avec!i / stride
		LET tl,tr,bl,br = 0,0,0,0

		IF x = 0 | x = stride LOOP
		IF y = 0 | y = rows LOOP
		
		// S S  M M  M S  S M
		//  A    A    A    A
		// M M  S S  M S  S M

		tl := grid%((y-1) * stride + x-1)
		tr := grid%((y-1) * stride + x+1)
		bl := grid%((y+1) * stride + x-1)
		br := grid%((y+1) * stride + x+1)

		x.mas(tl, tr, bl, br)
		x.mas(bl, br, tl, tr)
		x.mas(tr, br, tl, bl)
		x.mas(tl, bl, tr, br)
	}

	writef("X-MAS %d *n", s.xmascnt)
}

AND dir2str
: UP => "UP"
: DOWN => "DOWN"
: LEFT => "LEFT"
: RIGHT => "RIGHT"
: UPL => "UPL"
: UPR => "UPR"
: DNR => "DNR"
: DNL => "DNL"