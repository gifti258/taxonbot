#!/usr/bin/tclsh8.7
#exit

set editafter 1

source api.tcl
set lang de ; source langwiki.tcl
set token [login $wiki]

set lins [insource {\<sup\>\<\/sup\>/} 0]
puts [llength $lins]

foreach ins $lins {
	unset -nocomplain e
	set conts [conts t $ins x]
	regsub -all -- {\<\!--.*?--\>} $conts {} conts
	if {[string first "<sup></sup>" $conts] > -1} {
		puts \n[incr i]:$ins
	} else {
		continue
	}
	set e [regexp -all -- {\<sup\>\</sup\>} $conts]
	puts $e
	set ix 0
	for {set z 1} {$z <= $e} {incr z} {
		set ix [string first "<sup></sup>" $conts $ix]
		puts $ix
		incr ix
	}
#	if {[string first <!-- $conts] > -1} {
#		puts [incr j]:$ins
#	}
}
