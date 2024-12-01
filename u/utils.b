GET "utils.h"

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////   FILE IO
/////////////////////////////////////////////////////////////////////////////////////////

//Swap existing stream with a new one
// 
LET set_infile(filename) = VALOF 
{	g.hFile := findinput(filename)
	IF g.hFile DO
	{	g.cis := input()
		selectinput(g.hFile)
	}
	RESULTIS g.hFile    
}
	
//close file and return input to previous stream
AND cls_infile()    BE
	IF g.hFile DO
	{	endread()
		selectinput(g.cis)
		g.hFile := 0
	}

AND set_outfile(filename) = VALOF
{	g.hoFile := findoutput(filename)
	IF g.hoFile DO
	{	g.cos := output()
		selectoutput(g.hoFile)
	}
	RESULTIS g.hoFile
}

AND cls_outfile()   BE
	IF g.hoFile DO
	{	endwrite()
		selectoutput(g.cos)
		g.hoFile := 0
	}

AND reset_infile() BE rewindstream(g.hFile)
	
AND fread_line()   = VALOF
{	LET ch = ?
	LET out, nr = 0, 0
	LET buf = VEC 64
	result2 := FALSE
	IF g.cis = input() RESULTIS 0   //we don't want this stream
	
	{	ch := rdch()
		IF ch = endstreamch DO
		{	result2 := TRUE
			BREAK
		}
		IF ch = '*n' BREAK
		buf%nr := ch; nr := nr + 1
	}	REPEAT
	
	IF nr > 0 DO
	{	LET i = 1
		out := getvec(nr/bytesperword + 1)
		out%0 := nr
		{	out%i := buf%(i-1)
			i := i + 1
		}	REPEATWHILE i <= nr
	}
	RESULTIS out
}

AND fget_line(out, n) = VALOF
{	LET ch = ?
	LET nr = 0
	LET buf = VEC 64
	LET eof = FALSE
	IF g.cis = input() RESULTIS TRUE   //we don't want this stream

	out%0 := 0
	
	{	ch := rdch()
		IF ch = endstreamch DO
		{	eof := TRUE
			BREAK
		}
		IF ch = '*n' BREAK
		buf%nr := ch; nr := nr + 1
	}	REPEATWHILE nr < n
	
	IF nr > 0 DO
	{	LET i = 1
		out%0 := nr
		{	out%i := buf%(i-1)
			i := i + 1
		}	REPEATWHILE i <= nr
	}
	RESULTIS eof
}

//should refactor to use readn()
AND parse_num2(str, a, b) BE
{	IF str%0 ~= 0 DO
	{	LET str2int(s, i) BE    //whoops, could have used string_to_number
		{	LET n, k = s%0, 1
			LET ch   = s%n
			!i := 0
			
			{	ch      := ch - '0'
				!i      := !i + ch * k
				n, k    := n - 1, k * 10
				ch      := s%n
			}	REPEATWHILE n > 0
		}
		
		LET buf     = VEC 10
		LET p, i    = 0, ?
		
		UNTIL str%(p+1) = ' '   DO  p := p + 1
		FOR i = 0 TO p-1        DO  buf%(i+1) := str%(i+1)
		
		buf%0 := p
		str2int(buf, a)
		
		i := p + 2
		p := 1
		{	buf%p := str%i
			p, i := p + 1, i + 1
		}	REPEATUNTIL i = str%0 + 1
		
		buf%0 := p-1
		str2int(buf, b)
	}
}

AND trim(str) BE
{	LET f, r, i, p = ?, ?, ?, 1
	IF str%0 = 0 RETURN
	r := str%0 + 1
	f := 0
	
	{	f := f + 1
	}	REPEATUNTIL f = r | str%f ~= ' '  

	IF f = r DO
	{	str%0 := 0
		RETURN
	}

	{	r := r - 1
	}	REPEATUNTIL r = f | str%r ~= ' '

	FOR i = f TO r DO
	{	str%p := str%i
		p := p + 1
	}

	str%0 := r - f + 1
//   writef("*n%s", str)
}

AND isnumeric(v) = v >= '0' & v <= '9' -> TRUE, FALSE

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////


AND start_timer()           BE g.start_time := sys(Sys_cputime)
AND stop_timer()            BE g.stop_time  := sys(Sys_cputime)
AND get_time_taken_ms()     =  g.stop_time - g.start_time   
AND get_time_taken_sec()    = (g.stop_time - g.start_time) / 1000
