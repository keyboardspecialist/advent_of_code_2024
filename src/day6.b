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

	CRATE = 'O'
}

STATIC
{	s.gx
	s.gy
	s.gd

	s.grid
	s.stride

	s.visited
	s.brk

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

	LET sx, sy = 0,0

	LET update
	: '#',?,? BE s.gd := (s.gd + 1) MOD 4
	: '.',
		x>=0 <130,
		y>=0 <130 BE	{	s.grid!(y * s.stride + x) := 'X'
										s.cnt +:= 1
										s.gx := x; s.gy := y
									}

	: 'X',x,y BE s.gx := x <> s.gy := y
	: ?  ,x,y BE s.gx := x <> s.gy := y 

	LET lupdate
	: '#',?,? BE s.gd := (s.gd + 1) MOD 4
	: CRATE,
		x>=0 < 130,
		y>=0 < 130 BE {	TEST s.visited > 0
										THEN s.brk := TRUE <> s.cnt +:= 1 <> writef("VISITED AGAIN %d  %d  *n", s.visited, s.gd)
										ELSE s.visited +:= 1// <> writef("VISITED %d  %d *n", s.visited, s.gd)
										s.gx := x; s.gy := y
									}
	: 'X',x,y BE s.gx := x <> s.gy := y
	: ?  ,x,y BE s.gx := x <> s.gy := y 

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
	sx := s.gx
	sy := s.gy

	UNTIL s.gx >= stride | s.gy >= stride | s.gx < 0 | s.gy < 0
	MATCH(s.gd)
	: UP		BE update( grid!((s.gy-1) * stride + s.gx), s.gx, s.gy-1, s.gd)
	: RIGHT BE update( grid!(s.gy * stride + (s.gx+1)), s.gx+1, s.gy, s.gd)
	: DOWN	BE update( grid!((s.gy+1) * stride + s.gx), s.gx, s.gy+1, s.gd)
	: LEFT	BE update( grid!(s.gy * stride + (s.gx-1)), s.gx-1, s.gy, s.gd)

	writef("DISTINCT MOVES %d  *n", s.cnt)

	s.cnt := 0
	
	//489 too low
	FOR i = 0 TO stride-1 DO
	{	FOR j = 0 TO stride-1 DO
		{	//writef("Trying  %d  %d  *n", i, j)
			IF grid!(i * stride + j) = '#' LOOP
			IF i = sy & j = sx LOOP

			grid!(i * stride + j) := CRATE
			s.visited := 0
			s.brk := FALSE
			s.gx := sx
			s.gy := sy
			s.gd := UP
			UNTIL (s.gx >= stride | s.gy >= stride | s.gx < 0 | s.gy < 0) | s.brk
			MATCH(s.gd)
			: UP		BE lupdate( grid!((s.gy-1) * stride + s.gx), s.gx, s.gy-1, s.gd)
			: RIGHT BE lupdate( grid!(s.gy * stride + (s.gx+1)), s.gx+1, s.gy, s.gd)
			: DOWN	BE lupdate( grid!((s.gy+1) * stride + s.gx), s.gx, s.gy+1, s.gd)
			: LEFT	BE lupdate( grid!(s.gy * stride + (s.gx-1)), s.gx-1, s.gy, s.gd)

			grid!(i * stride + j) := '.'
		}
	}

	writef("LOOP COUNT %d  *n", s.cnt)
}