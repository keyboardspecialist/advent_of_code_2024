SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "PRINT QUEUE"

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 5

}

STATIC
{ s.sum
	s.pages
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
	set_outfile("data/hash.txt")
	order()
	stop_timer()
	cls_infile()
	cls_outfile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}

AND order : BE
{	LET htbl = VEC 5000
	LET pages = VEC 24

	LET ln = VEC 80
	LET eof = fget_uline(ln, 79)

	LET hash : k => (k * 2654435761) >> 16 & (2500-1)
	LET hash2: h1, h2 => hash(hash(h1) * 31 + hash(h2))

	LET inshash : t, lv, rv BE
	{	LET h = hash2(lv, rv)
		LET x = lv << 16 | rv << 8 | 1
		IF t!h ~= 0 DO
		{	LET c = t!h
			LET p1, p2 = c>>16, (c>>8) & #xFF
			writef("COLLISION  %d |%d  :: %d  *n", lv, rv, h)
			writef("PREVIOUS %d |%d  ::  %d *n", p1, p2, hash2(p1, p2))
		}
		t!h := x
	}

	LET parse
	: <=0,?,?,c BE s.cnt := c <> EXIT
	:	s>0,
		ln[d1'0'..'9', d2'0'..'9'],
		i,j BE	{	LET n = (d1-'0') * 10 + (d2-'0')
							s.pages!j := n
							parse(s-3, ln+3, i+3, j+1)
						}

	LET validate : t => VALOF
	{	FOR i = 0 TO s.cnt-1 DO
		{	FOR j = i+1 TO s.cnt-1 DO
			{	LET v1,v2 = s.pages!i, s.pages!j
				LET h2 = hash2(v2, v1)
				IF t!h2 ~= 0 DO
				{
			//		writef("[[ %d  %d  ]] *n", v2, v1)
					RESULTIS FALSE
				}
			}
		}
		RESULTIS TRUE
	}

	s.pages := pages
	s.sum := 0

	FOR i = 0 TO 5000-1 DO htbl!i := 0

	UNTIL eof & ln!0 = 0
	EVERY(ln)
	: [>0,d1'0'..'9',
				d2'0'..'9',
				'|',
				d3'0'..'9',
				d4'0'..'9'] BE	{	LET n1, n2 = ?,?
													n1 := (d1-'0') * 10 + (d2-'0')
													n2 := (d3-'0') * 10 + (d4-'0')
													
													inshash(htbl, n1, n2)
												}
	: [>0,'0'..'9',
				'0'..'9',
				','] BE {	parse(ln!0, @(ln!1), 0, 0)
									IF validate(htbl) DO
									{
										s.sum +:= s.pages!(s.cnt/2)
									//	writef("CNT %d  HALF %d  %d   *n", s.cnt, s.cnt/2, s.pages!(s.cnt/2))
										uputsn(s.pages, s.cnt) <> wrch('*n')
									}

								}
	: [?] BE eof := fget_uline(ln, 79)

	writef("*nSUM IS %d  *n", s.sum)
}

AND uputs : ln BE FOR i = 1 TO ln!0 DO wrch(ln!i)
AND uputsn : arr, c BE FOR i = 0 TO c-1 DO writef("%d   ", arr!i)
