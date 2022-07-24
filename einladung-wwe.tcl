#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set t0 [utc -> seconds -- %Y-%m-%d {}]
set wlist [conts id 9903215 1]
set conts [conts id 9903215 3]
regexp -- {\d{4}-\d\d-\d\d} $conts t1
if {$t1 eq $t0} {
	regexp -- {<pre>\n(.*?)\n</pre>} $conts -- text
	set top [string trim {*}[dict values [regexp -inline -line -- {==(.*?)==} $text]]]
	set text [string trim [regsub -line -- {.*} $text {}]]
	foreach usertalk [dict values [regexp -all -inline -- {\* \[\[(Benutzer(?:in)*?[ _]Diskussion:.*)(?:\]\]|\|)} $wlist]] {
		puts \n$usertalk:\n[edit $usertalk $top $text / section new]
		if {[incr i] == 1} {gets stdin}
	}
}
