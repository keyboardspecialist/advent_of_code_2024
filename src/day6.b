SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "GUARD GALLIVANT"

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 6

	UP = 0
	RIGHT
	DOWN
	LEFT
}

STATIC
{	s.gx
	s.gy
	s.gd

	s.grid
	s.stride

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
	guard()
	stop_timer()
	cls_infile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}

AND guard : BE
{ LET grid = VEC (130*130)

	LET ch = ?
	LET stride = 0
	LET scbpos = 0

	LET update
	: '#',x,y BE s.gd := (s.gd + 1) MOD 4
	: '.',
		x>=0 <130,
		y >= 0 <130 BE	{	s.grid!(y * s.stride + x) := 'X'
											s.cnt +:= 1
											s.gx := x; s.gy := y
										}
	: 'X',x,y BE s.gx := x <> s.gy := y
	: ?,x,y BE s.gx := x <> s.gy := y 


	ch := rdch();
	UNTIL ch = endstreamch
	EVERY(ch)
	: '*n'	BE IF stride = 0 DO stride := scbpos
	: d'^'|'>'|'v'|'<' 	BE	{	s.gx := scbpos MOD stride
														s.gy := scbpos / stride

														MATCH(d)
														: '^' BE s.gd := UP
														: '>' BE s.gd := RIGHT
														: 'v' BE s.gd := DOWN
														: '<' BE s.gd := LEFT
													}
	: c~='*n' BE grid!scbpos := ch <> scbpos +:= 1
	: ? BE ch := rdch()

	grid!(s.gy * stride + s.gx) := 'X'
	s.cnt := 1
	s.stride := stride
	s.grid := grid

	UNTIL s.gx >= stride | s.gy >= stride | s.gx < 0 | s.gy < 0
	MATCH(s.gd)
	: UP		BE update( grid!((s.gy-1) * stride + s.gx), s.gx, s.gy-1, s.gd)
	: RIGHT BE update( grid!(s.gy * stride + (s.gx+1)), s.gx+1, s.gy, s.gd)
	: DOWN	BE update( grid!((s.gy+1) * stride + s.gx), s.gx, s.gy+1, s.gd)
	: LEFT	BE update( grid!(s.gy * stride + (s.gx-1)), s.gx-1, s.gy, s.gd)

	writef("DISTINCT MOVES %d  *n", s.cnt)
}