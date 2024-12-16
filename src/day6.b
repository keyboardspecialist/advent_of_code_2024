SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "GUARD GALLIVANT"

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 6

	UP = 1
	RIGHT=2
	DOWN=4
	LEFT=8

	CRATE = 'O'
}

STATIC
{	s.gx
	s.gy
	s.gd

	s.grid
	s.stride

	s.brk

	s.visited
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
	: '#',?,? BE s.gd := (s.gd << 1) MOD #xF
	: '.',
		x>=0 <130,
		y>=0 <130 BE	{	s.grid!(y * s.stride + x) := 'X'
										s.cnt +:= 1
										s.gx := x; s.gy := y
									}

	: 'X',x,y BE s.gx := x <> s.gy := y
	: ?  ,x,y BE s.gx := x <> s.gy := y 

	LET lupdate
	// : o'#'|CRATE,x,y BE	{	LET p = @(s.grid!(y * s.stride + x))
	// 											LET n = (!p & #xFF00) >> 8
	// 											LET v = n & s.gd
	// 											IF v & s.visited DO s.brk := TRUE <> s.cnt +:= 1 <> writef("BREAKING %d [%d  %d ] *n",s.cnt, x, y)
	// 											n |:= s.gd
	// 											!p := (!p & #xFF) | (n << 8)
	// 											//writef("BUMP %d  [%d  %d ] *n", s.gd, x, y)
	// 											s.gd := (s.gd << 1) MOD #xF
	// 											IF o = CRATE DO s.visited := TRUE
	// 										}
	: '#',x,y BE s.gd := (s.gd << 1) MOD #xF
	: CRATE,x,y BE	{	s.visited +:= 1
										IF s.visited > 1 DO s.cnt +:= 1 <> s.brk := TRUE <> writef("LOOP  %d  *n", s.cnt)
										s.gd := (s.gd << 1) MOD #xF
										writef("crate bounce*n")
									}
	: 'X'|'.',
		x>=0 <130,
		y>=0 <130 BE s.gx := x <> s.gy := y
	: c?,x, y BE s.brk := TRUE

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
	: UP		BE update( grid!((s.gy-1) * stride + s.gx), s.gx, s.gy-1)
	: RIGHT BE update( grid!(s.gy * stride + (s.gx+1)), s.gx+1, s.gy)
	: DOWN	BE update( grid!((s.gy+1) * stride + s.gx), s.gx, s.gy+1)
	: LEFT	BE update( grid!(s.gy * stride + (s.gx-1)), s.gx-1, s.gy)

	writef("DISTINCT MOVES %d  *n", s.cnt)

	s.cnt := 0
	
	//489 too low
	FOR i = 0 TO stride-1 DO
	{	FOR j = 0 TO stride-1 DO
		{	
			IF grid!(i * stride + j) = '#' LOOP
			IF i = sy & j = sx LOOP

			writef("Trying  %d  %d  *n", j, i)

			grid!(i * stride + j) := CRATE
			s.brk := FALSE
			s.gx := sx
			s.gy := sy
			s.gd := UP
			s.visited := 0
			UNTIL (s.gx >= stride | s.gy >= stride | s.gx < 0 | s.gy < 0) | s.brk
			MATCH(s.gd)
			: UP		BE lupdate( grid!((s.gy-1) * stride + s.gx)&#xFF, s.gx, s.gy-1)
			: RIGHT BE lupdate( grid!(s.gy * stride + (s.gx+1))&#xFF, s.gx+1, s.gy)
			: DOWN	BE lupdate( grid!((s.gy+1) * stride + s.gx)&#xFF, s.gx, s.gy+1)
			: LEFT	BE lupdate( grid!(s.gy * stride + (s.gx-1))&#xFF, s.gx-1, s.gy)

			grid!(i * stride + j) := '.'
			reset()
		}
	}

	writef("LOOP COUNT %d  *n", s.cnt)
}

AND reset : BE	FOR i = 0 TO s.stride * s.stride-1 DO s.grid!i := s.grid!i & #xFF
