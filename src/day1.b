SECTION "UTILS"

GET "u/utils.h"
GET "u/utils.b"

.

SECTION "HYSTERIA"

GET "u/utils.h"

MANIFEST
{ AOC_DAY = 1

}

LET start() = VALOF
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
	location_lists()
	stop_timer()
	cls_infile()
	writef("Execution Time: %d ms *n", get_time_taken_ms())
	RESULTIS 0
}
AND location_lists() BE
{	LET ll = VEC 2048
	AND rl = VEC 2048
	AND temp = VEC 2048
	AND line = VEC 12
	AND idx, dist, sim = 0, 0, 0
	AND eof = FALSE

	{	eof := fget_line(line, 12 * bytesperword)
		IF line%0 > 0 DO	
		{	parse_num2(line, @(ll!idx), @(rl!idx))
			idx +:= 1 
		}
	} REPEATUNTIL eof = TRUE
start_timer()
	merge_sort(ll, temp, idx)
	merge_sort(rl, temp, idx)
stop_timer()
writef("sort time %d *n", get_time_taken_ms())
start_timer()
	FOR i = 0 TO idx-1 DO dist +:= (ll!i <= rl!i) -> rl!i - ll!i, ll!i - rl!i
stop_timer()
writef("distance time %d *n", get_time_taken_ms())
	writef("Distance is %d *n", dist)

start_timer()
	sim := count_sparse(ll, rl, idx)
stop_timer()
writef("Similarity time %d *n", get_time_taken_ms())
	writef("Similarity score %d *n", sim)
}

AND merge_sort(o, t, sz) BE merge_split(o, t, 0, sz)

AND merge_split(o, t, b, e) BE
{	LET m = ?
	IF (e - b) < 2 RETURN

	m := b + (e-b)/2
	merge_split(o, t, b, m)
	merge_split(o, t, m, e)
	merge_merge(o, t, b, m, e)
	sys(Sys_memmovewords, @(o!b), @(t!b), e-b)
}

AND merge_merge(o, t, b, m, e) BE
{	LET ib, im = b, m
	FOR i = b TO e-1 DO
	{	TEST ib < m & (im >= e | o!ib <= o!im) 
		THEN { t!i := o!ib; ib := ib + 1 }
		ELSE { t!i := o!im; im := im + 1 }
	}
}

// Hash size should be ~1.5x the list length for good load factor
AND hash_count(key, hashv, sz) = (key * 2654435761) >> 16 & (sz-1) // Multiplicative hash

AND count_sparse(ll, rl, idx) = VALOF
{	LET sz, sim = 1, 0
	LET counts, keys, used = ?,?,?
	WHILE sz #< idx#*3#/2 DO sz := sz << 1
	
	counts := getvec(sz-1)
	keys := getvec(sz-1)
	used := getvec(sz-1)
	
	FOR i = 0 TO sz-1 DO used!i := FALSE
	
	FOR i = 0 TO idx-1 DO
	{	LET val = rl!i
		LET h = hash_count(val, 0, sz)
		
		UNTIL ~used!h | keys!h = val DO h := (h + 1) & (sz-1)
		
		TEST ~used!h THEN
		{	used!h := TRUE
			keys!h := val
			counts!h := 1
		}	ELSE counts!h +:= 1
	}

	FOR i = 0 TO idx-1 DO
	{	LET val = ll!i
		LET h = hash_count(val, 0, sz)
		
		UNTIL ~used!h | keys!h = val DO h := (h + 1) & (sz-1)
		IF used!h & keys!h = val DO sim +:= counts!h * val
	}

	freevec(counts)
	freevec(keys)
	freevec(used)

	RESULTIS sim
}