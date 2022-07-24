#!/usr/bin/tclsh8.7
#exit

source api.tcl
set lang de ; source langwiki.tcl ; #set token [login $wiki]

#after 900000

set movepage {Benutzer:Shi Annan/A - Verschieben}
set movepageconts [conts t $movepage x]
set lline [split $movepageconts \n]
foreach line $lline {
	if {[string index $line 0] eq {*}} {
		set blankline [string trim [string map {* {} \[ {} \] {}} $line]]
		set sblank [split $blankline >]
		set srcpage [string trim [lindex $sblank 0]]
		set tgtpage [string trim [lindex $sblank 2]]
		if {![missing $srcpage] && [missing $tgtpage]} {
			puts $srcpage:$tgtpage
			puts [get [post $wiki {*}$token {*}$format / action move / from $srcpage / to $tgtpage / reason {Verschiebung im Auftrag von [[:Benutzer:Shi Annan]]} / movetalk 1 / noredirect 1]]\n
			after 5000
		}
	}
}
puts [get [post $wiki {*}$format / action purge / titles $movepage / forcerecursivelinkupdate]]

