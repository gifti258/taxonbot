#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot sauerland.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
while 1 {if [catch {set db [get_db dewiki]}] {after 60000 ; continue} else {break}}

lassign [list 3005956 [lsort -dictionary [dcat list Sauerland 0]]] pgid lpt
set llpt [tdot [llength $lpt]]
regexp -- {^.*?(Letzte.*?\n(.*?$))} [conts id $pgid x] oconts r1oconts r2oconts
set stand "Letzte Aktualisierung: [
	string trim [clock format [clock seconds] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de]
] ($llpt Artikel)"
foreach pt $lpt {dict lappend df [string index $pt 0] \[\[$pt\]\]}
foreach {f lf} $df {append reg "\n\n\{\{TOC\}\}\n\n== $f ==\n\n[join $lf { · }]"}
append reg "\n\n\[\[Kategorie:Wikipedia:WikiProjekt Sauerland\]\]"
if {$reg ne $r2oconts} {
	puts [edid $pgid "Bot: Aktualisierung ($llpt Artikel)" [string map [list $r1oconts $stand\n$reg] $oconts]]
}
