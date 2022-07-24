#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set push 0
set aktline {= Aktuelle Fälle =}

set newday	[utc -> seconds {} {%e. %B} {}]
set ts13		[clock scan [utc -> seconds {} %Y%m%d%H {-13 days}] -format %Y%m%d%H]
set year		[utc -> seconds {} %Y {}]
set month	[utc -> seconds {} %B {}]

set conts	[conts id 6535923 x]
set sconts	[split $conts \n]
set nconts	[conts id 6535923 0]

foreach line $sconts {
	set tline [string trim $line]
	if {[string index $tline 0] eq {=} && [string index $tline end] eq {=}} {
		incr sectnr
		if {$tline eq $aktline} {incr push ; continue}
		if $push {
			set tssect [clock scan "[string trim $tline {= }] $year" -format {%e. %B %Y} -locale de]
			if {$tssect > $ts13} {
				if ![exists aktnr] {
					set aktnr $sectnr
					append nconts "\n\n= Aktuelle Fälle =\n[conts id 6535923 $sectnr]"
					continue
				}
			}
			append nconts \n\n[conts id 6535923 $sectnr]
			continue
		}
		if {[string index $tline 1] ne {=}} {
			append nconts \n\n[conts id 6535923 $sectnr]
		} else {
			continue
		}
	}
}
append nconts "\n\n== $newday =="

if {[conts id 6535923 x] eq $conts} {
	puts [edid 6535923 {Bot: Tagesaktualisierung} $nconts / minor]
} else {
	exec ./lku.tcl >> lku.out 2>@1 &
}

exit


foreach line $sconts {
	set tline [string trim $line]
	if {[string index $tline 0] eq {=} && [string index $tline end] eq {=}} {
		lappend ltop [incr topnr] $tline
		if {$tline eq {= Aktuelle Fälle =}} {
			set aktnr $topnr
		}
	}
}

puts $ltop
puts $aktnr

exit

for {set sect 0} {$sect < 44} {incr sect} {
	set sectconts [conts id 6535923 $sect]
	set top [lindex [split $sectconts \n] 0]
	puts [incr topnr2]:$top
	unset -nocomplain sectconts top
}










exit

set oconts [conts id 6535923 x]
append nconts 		[conts id 6535923 0]
append nconts \n\n[conts id 6535923 1]
append nconts \n\n[conts id 6535923 2]
append nconts \n\n[conts id 6535923 3]
set newday	[utc -> seconds {} {%e. %B} {}]
set tsot		[clock scan [utc -> seconds {} %Y%m%d%H {-13 days}] -format %Y%m%d%H]
set year 	[utc -> seconds {} %Y {}]
set tsmonth [utc -> seconds {} %B {}]
lassign {{= Abzuarbeitende Fälle =} {= Aktuelle Fälle =}} todo actual
while 1 {
	if {[incr sect] < 4} {continue}
	if [catch {set sectconts [conts id 6535923 $sect]}] {break}
	if {[string range $sectconts 0 1] eq {==}} {
		set sectdate "[string trim [join [dict values [regexp -inline -- {^==(.*?)==} $sectconts]]]]"
		if {$tsmonth eq {Januar} && [string first Dezember $sectdate] > -1} {append sectdate " [expr $year - 1]"} else {append sectdate " $year"}
		set tssect [clock scan $sectdate -format {%e. %B %Y} -locale de]
		if {$tssect <= $tsot} {
			append todo \n$sectconts\n
		} else {
			append actual \n$sectconts\n
		}
	}
}
append nconts \n\n$todo
append nconts \n$actual
set summary {Bot: neuer Tagesabschnitt}
if {$nconts ne [format %s\n $oconts]} {append summary {, abzuarbeitende Fälle einsortiert}}
puts [edid 6535923 $summary "$nconts\n== $newday ==" / minor]
