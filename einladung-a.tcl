#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

regexp -- {<pre>\n(.*Treffen = (\d{1,4}).*)\n</pre>} [conts id 7642008 x] -- text no
foreach usertalk [dict values [regexp -all -inline -- {\* \[\[(Benutzer(?:in)*?[ _]Diskussion:.*)(?:\]\]|\|)} [conts id 7641966 2]]] {
	puts \n$usertalk:\n[edit $usertalk "Einladung zum $no. Augsburger Stammtisch" $text / section new]
	if {[incr zzz] == 1} {gets stdin}
}

exit

set luser [dict values [regexp -inline -all -- {\:Benutzer\:(.*?)\}\}} [conts id 8492723 x]]]

regexp -- {(Hallo\!.*?)\</nowiki\>} [conts t {user talk:Doc Taxon} 31] -- einl

foreach user $luser {
	puts \n$user:\n[edit "Benutzer Diskussion:$user" {[[Wikipedia:Mainz|Mainzer Stammtisch]] zusammen mit [[Wikipedia:Wiki Loves Broadcast/Treffen 2021/1|Wikipedia:Wiki Loves Broadcast]]} [string map {... ~~~} [string trim $einl]] / section new]
	if {[incr zzz] == 1} {gets stdin}
}

#puts $luser
#puts [llength $luser]
#puts .$einl.
