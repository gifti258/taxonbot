#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set today [utc ^ seconds {} %d.%m.%Y {}]

read_file tennisIOC.db tennisIOC

lassign {-1 -1 {}} rms rmd otbody
foreach {sd param land} {s ?page tennisWTAs.db d ?t=doubles&page tennisWTAd.db} {
	for {set page 1} {$page <= 35} {incr page} {
		set html [getHTML https://www.tennisexplorer.com/ranking/wta-women/$param=$page]
		regexp -- {\d\d\.\d\d\.\d{4}} $html ddate
		if {$ddate ne $today} {
			exec pkill tennismnavi.tcl
			exit
		}
		if {$sd eq {s} && ![incr rms]} {exec rm tennisWTAs.db}
		if {$sd eq {d} && ![incr rmd]} {exec rm tennisWTAd.db}
		regexp -- {<tbody class\="flags">(.*?)</tbody>} $html -- tbody
		if {$tbody eq $otbody} {break}
		set otbody $tbody
		set ltr [regexp -all -inline -- {<tr .*?</tr>} $tbody]
		foreach tr $ltr {
			set nat [
				dict get [lreverse $tennisIOC] [
					dict values [
						regexp -inline -- {"/ranking/wta-women/\?(?:t\=doubles\&)?country\=(.*?)"> <} $tr
					]
				]
			]
			regexp -- {<a href\="/player/(.*?)/(?:\?type\=doubles)?">(.*?)</a>} $tr -- surname cname
			set player $cname
			foreach surname [split $surname -] {
				if ![regexp -- {[0-9]} $surname] {
					set player [string trim [string map -nocase [list $surname {}] $player]]
					lappend player [string toupper $surname 0]
				}
			}
			if {[lindex $player 0] eq {-}} {
				set player "[lrange $player 1 end-2] [join [lrange $player end-1 end] -]"
			}
			regexp -- {<td class\="rank first">(.*?)\.</td>} $tr -- rank
			regexp -- {<td class\="prevrank"><div class\="(odown|oup)">([0-9]{1,4})</div></td>} $tr -- o prank
			if ![exists o] {
				set prank 0
			} elseif {$o eq {odown}} {
				set prank [expr 0 - $prank]
			}
			unset -nocomplain o
			append_file $land [list $nat $cname $player $rank $prank]
		}
	}
}
