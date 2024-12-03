GET "libhdr"

MANIFEST
{	util.globstart = 300
}

GLOBAL
{	g.cis : util.globstart
	g.hFile

	g.cos
	g.hoFile

	g.start_time
	g.stop_time

	//func defs
	set_infile
	cls_infile

	set_outfile
	cls_outfile

	set_ramistrm
	set_ramostrm

	set_ramiostrm
	cls_ramiostrm

	fread_line
	fget_line
	fget_uline

	parse_num2

	trim

	get_cputime
	start_timer
	stop_timer
	get_time_taken_ms
	get_time_taken_sec
}