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
{ s.pages
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
	cls_outfile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}

AND order : BE
{	LET htbl = VEC 10000
	LET pages = VEC 24

	LET ln = VEC 80
	LET eof = ?

	LET hash : l, r => l * 100 + r

	LET inshash : t, lv, rv BE
	{	LET h = hash(lv, rv)
		LET x = lv << 16 | rv << 8 | 1
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
				LET h = hash(v2, v1)
				IF t!h ~= 0 RESULTIS FALSE
			}
		}
		RESULTIS TRUE
	}

	LET reorder : t BE
	{	FOR i = 0 TO s.cnt-1 DO
		FOR j = i+1 TO s.cnt-1 DO
		{	LET v1, v2 = s.pages!i, s.pages!j
			LET h = hash(v2,v1)
			IF t!h ~= 0 DO s.pages!i := v2 <> s.pages!j := v1
		}
	}

	LET sum, rsum = 0, 0
	s.pages := pages

	FOR i = 0 TO 10000-1 DO htbl!i := 0

	eof := fget_uline(ln, 79)
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
									TEST validate(htbl) 
									THEN sum +:= s.pages!(s.cnt/2)
									ELSE reorder(htbl) <> rsum +:= s.pages!(s.cnt/2)
								}

	: [?] BE eof := fget_uline(ln, 79)

	writef("*nSUM IS %d  *n", sum)
	writef("*nRSUM IS %d  *n", rsum)
}

AND uputs : ln BE FOR i = 1 TO ln!0 DO wrch(ln!i)
AND uputsn : arr, c BE FOR i = 0 TO c-1 DO writef("%d   ", arr!i)
