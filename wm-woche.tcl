#!/usr/bin/tclsh8.7
#exit

catch {if {[exec pgrep -cxu taxonbot wm-woche.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set a [utc -> seconds {} %Y {}]
set ltg [lreverse [scat "Wikipedia:Wikimedia:Woche $a" 4]]
foreach tg $ltg {
	if {[string first $a $tg] > -1} {
		set week [string trimleft [utc ^ $tg Wikimedia:Woche/%Y-%m-%d %V {}] 0]
		break
	}
}
set summary "Bot: aktuelle Ausgabe der Wikimedia:Woche (\[\[Wikipedia:$tg|$week/$a\]\])"
set oconts [conts t Wikipedia:Wikimedia:Woche/aktuell x]
set nconts "#WEITERLEITUNG \[\[Wikipedia:$tg\]\]"
if {$nconts ne $oconts} {
	puts [edit Wikipedia:Wikimedia:Woche/aktuell $summary $nconts / minor]
}
