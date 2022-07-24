#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set menteepage {Benutzerin:Maimaid/Meine Mentees}
set menteeoconts [conts t $menteepage x]
set menteenconts [string map [list \n\n\n \n\n] $menteeoconts]
set lrex [regexp -all -inline -line -- {^\*.*?Beiträge/(.*?)\|.*?(\n.*)$} $menteenconts]
foreach {rex user templ} $lrex {
	set duc [join [get [post $wiki {*}$format / action query / list usercontribs / uclimit 1 / ucuser $user / ucprop ids|timestamp|title|sizediff|flags] query usercontribs]]
	unset -nocomplain minor new top uc
	set flags {}
	dict with duc {
		set date "[string map {Mai. Mai {  } { }} [
			utc -> $timestamp %Y-%m-%dT%TZ {%H:%M, %e. %b. %Y} {}
		]]"
		if [exists minor] {lappend flags K}
		if [exists new] {lappend flags N}
		if [exists top] {lappend flags a}
		set uc "\{\{Benutzerin:Maimaid/Meine Mentees/Vorlage|user=$user|revid=$revid|time=$date|title=$title|diff=[
			tdot $sizediff
		][
			expr {![empty flags] ? "|flags=[join $flags ,]" : {}}
		]\}\}"
	}
	set nrex [string map [list $templ "\n* $uc\n"] $rex]
	set menteenconts [string map [list $rex $nrex] $menteenconts]
}
set menteenconts [string map [list \n\n\n \n\n\n \n\n \n\n\n] $menteenconts]
if {$menteenconts ne $menteeoconts} {
	puts [edit $menteepage {Bot: Aktualisierung} $menteenconts]
	puts [get [post $wiki {*}$format / action purge / titles user:Maimaid]]
}
