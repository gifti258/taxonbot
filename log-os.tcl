#!/usr/bin/tclsh8.7

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

if {[utc -> seconds {} %e {}] != 1} {exit}
lassign {Wikipedia:Oversight/Logbuch 4479779} log logid
lassign [list [utc -> seconds {} %B {}] [utc -> seconds {} %m {}]] monthB monthm
set armonth [utc -> seconds {} %B {-25 days}]
set year [utc -> seconds {} %Y {}]
if {$monthB ne {Januar}} {set aryear $year} else {set aryear [expr $year - 1]}
append sqltime $year $monthm 01000000

set db [get_db dewiki]
set rev [lindex [mysqlsel $db "
	select rev_id from revision
	where rev_page = $logid and rev_timestamp < $sqltime
	order by rev_id desc
;" -flatlist] 0]
mysqlclose $db

if {$monthB eq {Februar}} {
	set arconts "<includeonly>= $year =</includeonly>\n\[\[Kategorie:Wikipedia:Oversight|Logbuch/Archiv/$year\]\]"
} else {
	set arconts [conts t $log/Archiv/$aryear x]
}
set narconts [string map [list \[\[ "; \[\{\{fullurl:$log|oldid=$rev\}\} $armonth\]\n\[\["] $arconts]
puts [edit $log/Archiv/$aryear "Bot: Archivierung des OS-Logbuchs ($armonth)" $narconts / minor]

set nlogconts "\{\{$log/Intro\}\}\n__NOTOC__\n\n== $monthB $year ==\n\{\{$log/Kopf\}\}"
puts [edit $log "Bot: Archivierung des OS-Logbuchs ($armonth $aryear)" $nlogconts]

puts $narconts\n\n$nlogconts
