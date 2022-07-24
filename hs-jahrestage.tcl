#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set date		[utc -> seconds {} {%e. %B %Y} {-1 day}]
set year		[utc -> seconds {} %Y {-1 day}]
set fyear 	[utc -> seconds {} %d%m {}]
set jtpage {Wikipedia Diskussion:Hauptseite/Jahrestage}
set njtconts [set ojtconts [conts t $jtpage x]]
set lsect [get [post $wiki {*}$parse / page $jtpage / prop sections] parse sections]

set larchconts {}
foreach sect $lsect {
	unset -nocomplain archconts
	dict with sect {
		if {$line eq $date} {
			set archconts [conts t $jtpage $index]
			lappend larchconts $line $archconts
			set njtconts [string map [list $archconts {}] $njtconts]
		}
	}
}
if ![empty larchconts] {
	if {$fyear eq {0101}} {
		set njtconts [string map [list "= $year =\n" {}] $njtconts]
	}
	set njtconts [string map [list \n\n\n\n\n \n\n \n\n\n\n \n\n \n\n\n \n\n] $njtconts]
	set archjtsummary "Bot: [join [dict keys $larchconts] {, }] von \[\[$jtpage\]\] archiviert"
	set jtsummary "Bot: [join [dict keys $larchconts] {, }] nach \[\[$jtpage/Archiv/$year\]\] archiviert"
	if {[conts t $jtpage x] eq $ojtconts} {
		if [missing $jtpage/Archiv/$year] {
			puts [edit $jtpage/Archiv/$year $archjtsummary "\{\{Archiv|Wikipedia Diskussion:Hauptseite/Jahrestage\}\}\n\n[join [dict values $larchconts] \n\n]"]
		} else {
			puts [edit $jtpage/Archiv/$year $archjtsummary {} / appendtext \n\n[join [dict values $larchconts] \n\n]]
		}
		puts [edit $jtpage $jtsummary $njtconts]
	}
}
