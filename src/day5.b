SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "PRINT QUEUE"

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 5

	lv
	rv

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
	order()
	stop_timer()
	cls_infile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}

AND order : BE
{	LET htbl = VEC 5000
	LET pages = VEC 24

	LET ln = VEC 80
	LET eof = fget_uline(ln, 79)

	LET hash : t lv rv BE 
	{ LET h = lv * 31 + rv
		t!h := TRUE
	}

	LET parse
	: <=0,?,?,c BE s.cnt := c <> writef("*n HIT  %d  *n", c) <> EXIT
	:	s>0,
		ln[d1'0'..'9', d2'0'..'9'],
		i,j BE	{	LET n = (d1-'0') * 10 + (d2-'0')
							s.pages!j := n
							parse(s-3, ln+3, i+3, j+1)
						}

	LET validate : ln BE
	{	

	}

	s.pages := pages

	UNTIL eof & ln!0 = 0
	EVERY(ln)
	: [>0,d1'0'..'9',
				d2'0'..'9',
				'|',
				d3'0'..'9',
				d4'0'..'9'] BE	{	LET n1, n2 = ?,?
													n1 := (d1='0') * 10 + (d2-'0')
													n2 := (d3-'0') * 10 + (d4-'0')
													
													hash(htbl, n1,n2)
												}
	: [>0,'0'..'9',
				'0'..'9',
				','] BE {	parse(ln!0, @(ln!1), 0, 0)
									
								}
	: [?] BE eof := fget_uline(ln, 79)
}

AND uputs : ln BE FOR i = 1 TO ln!0 DO wrch(ln!i)
AND uputsn : arr c BE FOR i = 1 TO c DO writef("%d ", arr!i)
