SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "MULL IT OVER"

GET "u/utils.h"

MANIFEST
{	AOC_DAY = 3

	EOF = -2
	EOL = -1
}

STATIC
{	s.m1
	s.m2

	s.num
	s.bufp
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
	madder()
	stop_timer()
	cls_infile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}


// <number> - 0..9, 1-3 digits
// MUL - 'm' 'u' 'l'
//valid syntax => MUL '(' <number> ',' <number> ')'
AND madder : BE
{

	//static buffers
	LET num = VEC 3

	LET peek
	: => VALOF	{	IF s.bufp+1 >= g.hFile!scb_end RESULTIS EOF
								RESULTIS g.hFile!scb_buf%(s.bufp+1)
							}

	AND scanner
	: BE	{	LET c = g.hFile!scb_buf%s.bufp
					IF s.bufp-g.hFile!scb_end <= 3 EXIT
					lex( c, g.hFile!scb_buf%s.bufp )
					scanner()
				}
	AND number
	: d'0'..'9', i BE { s.num!i := d }

	AND lex
	: ='m',[a, b, c] BE MATCH(a, b, c)
											: 'u', 'l','(' BE	{	writef("found a mul match at %d *n", s.bufp) //parse <number> <comma> <number> <rparen>
																					s.bufp +:= 3

																				}
											: c ? BE	{ writef("no match on char %c *n ", c); s.bufp +:= 1	//advance stream pos
																		}

	//
	s.num := num
	s.bufp := g.hFile!scb_pos

	scanner()
}