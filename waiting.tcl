#!/usr/bin/tclsh8.7
#exit

set editafter 1
#if {[exec pgrep -cxu taxonbot test3.tcl] > 1} {exit}

source api.tcl
set lang de ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl

fconfigure stdout -buffering none

puts -nonewline .
while 1 {
	after 1000
	puts -nonewline .
	flush stdout
}
