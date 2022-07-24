#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

lassign [list [clock seconds] [split [set ocont [contents id 8888151 x]] \n] 3 end] cs lline
foreach line $lline {
	if {[incr i] > 3} {
		set ts [clock scan [
			string map {. {}} [join [regexp -inline -- {\d\d:\d\d.*?\d{4}} $line]]
		] -format {%H:%M, %d %b %Y} -locale de -timezone :Europe/Berlin]
		if {[expr $cs - $ts] > [expr 40 * 24 * 60 * 60]} {lremove lline $line}
	}
}
if {[set ncont [join $lline \n]] ne $ocont} {
	puts [edid 8888151 Aktualisierung $ncont / minor]
}
