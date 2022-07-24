#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set page Wikipedia:Löschkandidaten/Urheberrechtsverletzungen/Archiv
set month [utc -> seconds {} {%B %Y} {1 month}]
set katlogmonth [string map {Mai. Mai} [utc -> seconds {} {%b. %Y} {1 month}]]
set katmonth [utc -> seconds {} %Y-%m {1 month}]
set summary [format {Bot: Monat %s angelegt} $month]
set output {{{Archiv|Wikipedia:Löschkandidaten/Urheberrechtsverletzungen}}}
if {[lindex $month 0] eq {Januar}} {
	puts [edit $page $summary {} / prependtext "== [lindex $month 1] ==\n* \[\[$page/$month\]\]\n\n" / minor]
} else {
	puts [edit $page $summary [regsub -- "== [lindex $month 1] ==\n" [conts t $page x] "&* \[\[$page/$month\]\]\n"] / minor]
}
puts [edit $page/$month {Bot: neue Archivseite angelegt} $output]

set page "Kategorie:Wikipedia:GND fehlt [utc -> seconds {} %Y-%m {1 month}]"
if [missing $page] {
	puts [edit $page {Bot: neue Monatskategorie angelegt} {{{GND fehlt}}}]
}

set page "Wikipedia:Redundanz/$month"
set output [format {{{Autoarchiv-Erledigt | Alter= 7 | Ziel= '%s/Archiv' | Zeigen= ja | Ebene= 3}}} $page]
append output "\n\{\{Navigationsleiste Redundanz\}\}"
if 0 {
for {set day 1} {$day <= 31} {incr day} {
	set date [utc -> [utc <- seconds {} $day-%m-%Y {1 month}] %d-%m-%Y {%e. %B} {}]
	if {[regexp -inline -- {\d{1,2}} $date] == $day} {append output "\n\n== $date =="} else {break}
}
}
puts [edit $page {Bot: neue Monatsseite angelegt} $output]
#puts $output
#set katmonth [utc <- $month {%B %Y} %Y-%m {2 months}]
set output [format {{{Archiv|Wikipedia:Redundanz/%s}}} $month]
append output \n\[\[Kategorie:Wikipedia:Redundanzarchiv|#$katmonth\]\]
puts [edit $page/Archiv {Bot: neue Archivseite angelegt} $output]
#puts $output
set output {{{Wartungskategorie}}}
append output "\n\{\{TOC Kategorie\}\}\n\n\[\[Kategorie:Wikipedia:Redundanz|#$katmonth\]\]"
puts [edit [format {Kategorie:Wikipedia:Redundanz %s} $month] {Bot: neue Wartungskategorie angelegt} $output]
#puts $output
#puts [format {Kategorie:Wikipedia:Redundanz %s} $month]

puts [edit Benutzer:TaxonKatBot/Kategorienlog "Bot: Archivlink für den Monat $month" {} / appendtext "\n* \[\[/$katlogmonth|$katlogmonth\]\]" / minor]

exit
