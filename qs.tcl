#!/usr/bin/tclsh8.7

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set ts [clock format [clock add [clock seconds] -3 hours] -format %Y%m%d-%H]

set db [read [set f [open qs-rc/qs-rc$ts r]]] ; close $f
set db [lrange [lsort -unique [split $db \n]] 1 end]

foreach item $db {
	puts \n$item:
	set result {}
	set pcats [pagecat $item]
	if {[redirect $item] || [missing $item] || {Kategorie:Begriffsklärung} in $pcats || {Kategorie:Wikipedia:Schnelllöschen} in $pcats || {Kategorie:Wikipedia:Löschkandidat} in $pcats} {continue}
	lappend result $item
#	if ![llength [pagecat $item]] {
#		puts 0-Kategorie
#		lappend result $item
#	}
}
set qsdict [list [read [set f [open qs-rc/@qsdict r]]]] ; close $f
set qsdict [lsort -unique [join [lappend qsdict $result]]]
foreach item $qsdict {
	puts $item
}












#set qsdict [dict remove $qsdict {MacOS}]
#set f [open qs-rc/@qsdict w]]] ; puts $f $qsdict ; close $f
#set f [open qs-rc/@qsdict w] ; puts $f $result ; close $f
