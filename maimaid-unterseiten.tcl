#!/usr/bin/tclsh8.7
exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
#source procs.tcl
#source library.tcl
#set db [get_db dewiki]

set c [conts t Benutzerin:Maimaid/Entwurfsliste x]
set bc [conts t Benutzerin:Maimaid/Blacklist x]
set sbc [split $bc \n]

foreach bc $sbc {
	lappend tbc [string trim $bc { *}]
}

set lso [subpageof Maimaid 2]

proc 0len size {
	global leno
	set lensize [string length $size]
	set 0 {}
	set len0 [expr $leno - $lensize]
	for {set i 0} {$i < $len0} {incr i} {
		append 0 0
	}
	if {$leno > 3 && $lensize <= 3}	{append 0 .}
	if {$leno > 6 && $lensize <= 6}	{append 0 .}
	return $0
}

foreach so $lso {
	set so1 [lindex $so 1]
	if {$so1 in $tbc} {continue}
	set so0 [lindex $so 0]
	if ![exists leno] {set leno [string length $so0]}
	set 0 [0len [lindex $so 0]]
	lappend res "[expr {![empty 0] ? "\{\{0|$0\}\}" : {}}][tdot $so0] Byte: \[\[$so1\]\]"
}

set elist "* [join $res "\n* "]"

if {$elist ne $c} {
	puts [edit Benutzerin:Maimaid/Entwurfsliste "Bot: Aktualisierung" $elist / minor]
}
