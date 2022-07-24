#!/usr/bin/tclsh8.7
#exit

set editafter 5

source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]

puts [edit user:TaxonBot/Test5 Test Test-Tokens-7]

exit

set lins [insource {noord\-hollandsarchief\.nl\/beelden\/beeldbank\/detail\/[^ ]*[-]/} 6]
#set lins [insource {\<tt\>/} $argv]
#set lins [insource [format {\<font color\=%s/} $argv] 4]
#set lins [insource {Friedrich Graf\/K/} x]

#set lpt [commonsdcat list {Noord-Hollands Archief} 6]

#puts $lpt

#exit

puts [set lenlins [llength $lins]]

foreach ins $lins {
	puts \n----\n[incr i]:$ins
	set c [conts t $ins x]
	set sc [split $c \n]
	foreach line $sc {
		if {[string first /beeldbank/ $line] > -1} {
			puts $line
			regexp -- {detail/(.*?)/media} $line -- hex
#			puts $hex
			if {[string first - $hex] == -1} {continue}
			set nhex [string map {- {}} [string toupper $hex]]
#			puts $nhex
			set nline [string map [list $hex $nhex media/undefined media/] $line]
			puts $nline
			puts [edit $ins {Bot: weblink repair} [string map [list $line $nline] $c] / minor]
#			gets stdin
			continue
		}
	}
}

