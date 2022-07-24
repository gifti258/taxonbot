#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

catch {if {[exec pgrep -cxu taxonbot verwaist.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
while 1 {if [catch {set db [get_db dewiki]}] {after 60000 ; continue} else {break}}

set pgdate Wikipedia:Qualitätssicherung/[
	string trim [clock format [clock seconds] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de]
]
if [missing $pgdate] {exit}
set lconts [lrange [split [conts id 9708855 x] \n] 4 end]
for {set x 0} {$x < 10} {incr x} {
	lappend litem [lindex $lconts [expr round(rand() * [llength $lconts])]]
}
set in {Auf diese Artikel verweisen entweder nur Seiten aus anderen Namensräumen, Weiterleitungsseiten, Begriffsklärungsseiten und ähnliche und gelten damit noch als verwaist. Hilf bitte mit, die Mängel zu beheben:}
set appendtext "\n\n== Verwaiste Artikel ==\n$in\n[join [lsort -unique $litem] \n]\n\n${~}"
puts [edit $pgdate {Bot: Verwaiste Artikel} {} / appendtext $appendtext / minor]
