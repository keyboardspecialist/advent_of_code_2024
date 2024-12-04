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

	MUL = 1
	LPAREN
	RPAREN
	NUM
	COM
	REND
}

STATIC
{	s.m1
	s.m2

	s.num
	s.tok
	s.idx
	s.step
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
{	LET num = VEC 3
	LET tok = VEC 5
	LET acc = 0

	LET rule = TABLE MUL, LPAREN, NUM, COM, NUM, RPAREN, REND

	LET number
	: d'0'..'9', i BE { s.num!i := d }

	AND lex
	: 'm', MUL BE	{ writef("Found M *n"); s.tok!s.idx := 'm'; s.idx +:= 1 }
	: 'u', MUL BE	{ writef("Found U *n"); s.tok!s.idx := 'u'; s.idx +:= 1 }
	: 'l', MUL BE	{ writef("Found L *n"); s.tok!s.idx := 'l'; s.idx +:= 1 }
	: ['m', 'u', 'l'], MUL BE	{ writef("Found MUL! *n"); s.idx := 0; s.step := LPAREN }
	: '(', LPAREN BE	{ s.step := NUM } 
	: ')', RPAREN BE	{ s.step := REND }
	: '0'..'9', NUM BE	{ }
	: ',', COM BE	{ s.step := NUM }
	: c?, r? BE {s.idx := 0; s.step := MUL } //{ writef("Found %c while trying to parse rule %s *n", c, rulestr(r))}

	LET ch = rdch()
	LET idx = 0

	s.num := num
	s.tok := tok
	s.step := MUL
	UNTIL ch = endstreamch DO
	{	ch := rdch()
		lex(ch, step)

		IF s.idx = 3 DO lex(tok, step)

	}
	writef("*n")
}

AND rulestr(r) = VALOF SWITCHON r INTO
{	CASE MUL: RESULTIS "MUL"; ENDCASE
	CASE LPAREN: RESULTIS "LPAREN"; ENDCASE
	CASE RPAREN: RESULTIS "RPAREN"; ENDCASE
	CASE NUM: RESULTIS "NUM"; ENDCASE
	CASE COM: RESULTIS "COM"; ENDCASE
	DEFAULT: RESULTIS "NOTARULE"; ENDCASE
}