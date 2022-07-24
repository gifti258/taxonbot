#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set nconts [set oconts [conts t BD:Maimaid x]]
set tsformat {%Y-%m-%d %H:%M}
set 7days [utc <- seconds {} $tsformat {-7 days}]
set lsect {}
for {set sect 1} {$sect < 100} {incr sect} {
	if [catch {
		set csect [conts t BD:Maimaid $sect]
		if {[string first GiftBot/Ausrufer $csect] > -1} {
			set ts [utc <- [string map {Mai Mai.} {*}[dict values [regexp -inline -- {– \[\[Benutzer:GiftBot\|GiftBot\]\].*?(\d\d.*?\d{4})} $csect]]] {%H:%M, %e. %b. %Y} $tsformat {}]
			if {[clock scan $ts -format $tsformat] < [clock scan $7days -format $tsformat]} {
				lappend lsect [lindex [split $ts -] 0] $csect
			}
		}
	}] {break}
}
foreach {year sect} $lsect {
	puts [edit BD:Maimaid/Archiv/$year {Bot: Archivierung des Ausrufers} {} / appendtext \n\n$sect]
	puts [edit BD:Maimaid {Bot: Archivierung des Ausrufers} [set oconts [string map [list $sect {}] $oconts]]]
}

exit

