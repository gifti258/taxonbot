#!/usr/bin/tclsh8.7
#catch {if {[exec pgrep -cxu taxonbot miniwb.tcl] > 1} {exit}}
exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

if {[utc -> seconds {} %B {}] in {Mai}} {
if [string match *true* [conts id 11741106 x]] {puts "\n*** Bot gesperrt ***\n" ; exit}

set page Wikipedia:Miniaturenwettbewerb
set nconts [set oconts [conts t $page x]]
regexp -- {\?\n(\|-.*?)\|\}} $nconts -- otab
set sotab [split [set otab [string trim $otab]] \n]
foreach {1 2 3 4 5 6 7} $sotab {
	set 6 "| [regexp -all -- {\[\[} $5]"
	lappend sntab $1 $2 $3 $4 $5 $6 $7
}
set ntab [join $sntab \n]
set nconts [string map [list $otab $ntab] $nconts]
if {[conts t $page x] eq $oconts} {
	puts [edit $page {Bot: Stimmenauszählung} $nconts / minor]
} else {
	exec ./miniwb.tcl >> miniwb.out 2>@1 &
}

}

