SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "MULL IT OVER"

GET "u/utils.h"

MANIFEST
{	AOC_DAY = 3

	INIT = 0
	MUL
	LPAREN
	RPAREN
	NUM1
	NUM2
	COM
	REND

	MAYBE_DO
	MAYBE_DONT
	DOO
	DONT
	DEND
}

STATIC
{	s.m1
	s.m2

	s.tok
	s.idx
	s.step

	s.enabled
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

AND tok2int : => MATCH(s.idx)
						: 1 => s.tok!0
						: 2 => s.tok!0 * 10 + s.tok!1
						: 3 => s.tok!0 * 100 + s.tok!1 * 10 + s.tok!2

// <number> - 0..9, 1-3 digits
// MUL - 'm' 'u' 'l'
//valid syntax => MUL '(' <number> ',' <number> ')'
AND madder : BE
{	LET tok = VEC 5
	LET acc = 0

	LET lexmul
	: c'm', INIT BE	{	s.tok!s.idx := c
										s.idx +:= 1
										s.step := MUL
									}

	: c'u'|'l', MUL BE	{	s.tok!s.idx := c
												s.idx +:= 1
											}

	: ['m', 'u', 'l'],s MUL BE	{	s.idx := 0
																s.step := LPAREN
															}

	: '(',s LPAREN BE	{	s.step := NUM1
										}

	: ')',s RPAREN BE	{	writef("Found %s *n", rulestr(s)) //same as comma, we only eat it
											s.step := REND
										}

	: d '0'..'9', s NUM1|NUM2 BE	{	s.tok!s.idx := d - '0'
																	s.idx +:= 1
																}
	: ',',s NUM1 BE	{	s.m1 := tok2int()
										s.idx := 0
										s.step := NUM2
									}
	: ')', s NUM2 BE	{	s.m2 := tok2int()
											s.idx := 0
											s.step := REND
										}
	: ',',s COM BE	{	writef("Found %s *n", rulestr(s)) //maybe not needed, we only eat this char
										s.step := NUM2
									}

	: c?, r? BE {	s.idx := 0
								s.step := INIT
							}

	LET lexdo
	: c'd', s INIT BE	{	s.step := MAYBE_DO
											s.tok!s.idx := c
											s.idx +:= 1
										}

	: c'o', s MAYBE_DO BE	{	s.tok!s.idx := c
													s.idx +:= 1
												}

	: ['d', 'o'], s MAYBE_DO BE	{ s.step := MAYBE_DONT }

	: '(', s MAYBE_DONT BE	{	s.step := DOO
														s.idx := 0
													}

	: ')', s DOO BE	{	s.enabled := TRUE
										s.step := INIT
									}

	: c'n'|'*''|'t', s MAYBE_DONT BE	{ s.tok!s.idx := c; s.idx +:= 1 }

	: ['d', 'o', 'n', '*'', 't'], s MAYBE_DONT BE	{ s.step := DONT; s.idx := 0 }

	: '(', s DONT BE	{	s.step := DEND
										}

	: ')', s DEND BE	{	s.enabled := FALSE
											s.step := INIT
										}

	: ?, ? BE { s.step := INIT; s.idx := 0 }

	LET ch = rdch()
	LET idx = 0

	s.tok := tok
	s.step := INIT
	UNTIL ch = endstreamch DO
	{	lexmul(ch, s.step)

		IF s.idx = 3 & s.step = MUL DO lexmul(tok, s.step)

		IF s.step = REND DO
		{	s.step := INIT //we're valid, compute it
			acc +:= s.m1 * s.m2
		}

		ch := rdch()
	}
	writef("MADD ACC %d *n", acc)

	acc := 0
	s.step := INIT
	s.enabled := TRUE
	rewindstream(g.hFile)
	ch := rdch()

	UNTIL ch = endstreamch DO
	{	IF s.step <= REND & s.enabled DO lexmul(ch, s.step)
		IF s.step = INIT | s.step >= MAYBE_DO DO lexdo(ch, s.step)

		MATCH(s.idx, s.step)
		: 3, MUL BE lexmul(tok, s.step)
		: 2, MAYBE_DO BE lexdo(tok, s.step)
		: 5, MAYBE_DONT BE lexdo(tok, s.step)

		IF s.step = REND & s.enabled DO 
		{	s.step := INIT
			acc +:= s.m1 * s.m2
		}

		ch := rdch()
	} 
	writef("ENABLE BIT ACC %d *n", acc)
}

AND rulestr 
: INIT => "INIT"
: MUL => "MUL"
: LPAREN => "LPAREN"
: RPAREN => "RPAREN"
: NUM1 => "NUM1"
: NUM2 => "NUM2"
: COM => "COM"
: REND => "REND"
: MAYBE_DO => "MAYBE_DO"
: MAYBE_DONT => "MAYBE_DONT"
: DOO => "DOO"
: DONT => "DONT"
: DEND => "DEND"
