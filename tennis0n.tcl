#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

package require http
package require tls
package require tdom

varassign [conts t Portal:Tennis/Tennisspieler x] {opconts npconts}
set spconts [split $npconts \n]
set ldate [dict values [regexp -all -inline -line -- {^.*Stand: (.*?)\).*$} $npconts]]
set op100 [dict values [regexp -all -inline -- {<br />\n(\d\d.*?)\n\|} $npconts]]
set op100mp [lindex $op100 0]
set op100fp [lindex $op100 1]

read_file tennis0dm.db ldmp
read_file tennis0df.db ldfp
read_file tennis0c.db lcp

puts $ldate

set html [getHTML https://www.atptour.com/en/rankings/singles?rankRange=1-5000]
set ndatemp [
	utc ^ [dict values [
		regexp -inline {<li data-value="(.*?)" class="current">} $html
	]] %Y-%m-%d {%e. %B %Y} {}
]
set body [[[dom parse -html [
	dict values [regexp -inline -- {<tbody>(.*)\t</tbody>} $html]
]] documentElement] asList]
if {		[lindex $ldate 0] ne $ndatemp
		&& [clock scan $ndatemp -format {%e. %B %Y} -locale de] < [clock seconds]} {
	foreach bodymp [lrange [lindex $body 2] 0 end-1] {
		unset -nocomplain datamp
		lappend datamp [string trimright [string trim [lindex $bodymp 2 0 2 0 1]] T]
		switch [lindex $bodymp 2 1 2 0 1 1] {
			move-down	{lappend datamp -[string trim [lindex $bodymp 2 1 2 1 2 0 1]]}
			move-none	{lappend datamp /}
			move-up		{lappend datamp +[string trim [lindex $bodymp 2 1 2 1 2 0 1]]}
		}
		lappend datamp [lindex $bodymp 2 2 2 0 2 0 2 0 1 3]
		lappend datamp [string toupper [lindex [split [lindex $bodymp 2 3 2 0 1 1] /] 4]]
		lappend datamp [lindex $bodymp 2 3 2 0 1 3]
		lappend ldatamp $datamp
	}

	varassign -1 {iline i}
	foreach line $spconts {
		if {[incr iline] == 8} {set picline $line}
		if {[string index $line 0] eq {#}} {
			lappend ocontsmp $line
			set datamp [lindex $ldatamp [incr i]]
			foreach {-- didmp delink delabel enlink enlabel} $ldmp {
				if {$didmp eq [lindex $datamp 3]} {
					set nline #\{\{[lindex [redir 10 [lindex $datamp 2]] 1]|
					if ![empty delink] {
						append nline $delink|
					} elseif ![empty enlink] {
						append nline $enlink|
					} else {
						append nline [lindex $datamp 4]|
					}
					if ![empty delabel] {
						append nline $delabel\}\}
					} elseif ![empty enlabel] {
						append nline $enlabel\}\}
					} else {
						append nline [lindex $datamp 4]\}\}
					}
					lappend ncontsmp $nline
					break
				}
			}
			if !$i {
				foreach {idp size fi} $lcp {
					if {$idp eq [lindex $datamp 3]} {
						set npicline [regsub -- {(\[\[)(.*?)(\]\].*?\|Herren.*?\(Stand: )(.*?)(\))} $picline \\1Datei:$fi|rechts|$size\\3$ndatemp\\5]
						set npconts [string map [list $picline $npicline] $npconts]
						break
					}
				}
			}
		}
		if {$i == 9} {break}
	}

	set npconts [string map [list [join $ocontsmp \n] [join $ncontsmp \n]] $npconts]

	foreach datamp $ldatamp {
		set datamp0 [lindex $datamp 0]
		if {$datamp0 > 10 && $datamp0 <= 100 && [lindex $datamp 2] in {AUT GER LIE SUI}} {
			foreach {-- didmp delink delabel enlink enlabel} $ldmp {
				if {$didmp eq [lindex $datamp 3]} {
					set nline $datamp0.&nbsp\;
					if ![empty delink] {
						set link $delink
					} elseif ![empty enlink] {
						set link $enlink
					} else {
						set link [lindex $datamp 4]
					}
					if ![empty delabel] {
						set label $delabel
					} elseif ![empty enlabel] {
						set label $enlabel
					} else {
						set label [lindex $datamp 4]
					}
					if {$link ne $label} {
						append nline \[\[$link|$label\]\]
					} else {
						append nline \[\[$link\]\]
					}
					lappend np100mp $nline
					break
				}
			}
		}
	}
	set npconts [string map [list $op100mp [join $np100mp ",\n"]] $npconts]
}

foreach {-- -- -- -- -- -- -- -- ndatefp0 rankfp0 --} $ldfp {
	if {$rankfp0 == 1} {
		set ndatefp [string trim [clock format [
			clock scan $ndatefp0 -format {%b %e, %Y}
		] -format {%e. %B %Y} -locale de]]
		break
	}
}

if {		[lindex $ldate 1] ne $ndatefp
		&& [clock scan $ndatefp -format {%e. %B %Y} -locale de] < [clock seconds]} {
	foreach {-- didfp delink delabel enlink enlabel namefp nation datefp rankfp --} $ldfp {
		if {	![empty datefp] && ![empty namefp]
				&& [clock scan $datefp -format {%b %e, %Y}]
				eq [clock scan $ndatefp0 -format {%b %e, %Y}]} {
			if {$rankfp >= 1 && $rankfp <= 10} {
				if {$rankfp == 1} {set cidfp $didfp}
				set nline #\{\{[lindex [redir 10 $nation] 1]|
				if ![empty delink] {
					append nline $delink|
				} elseif ![empty enlink] {
					append nline $enlink|
				} else {
					append nline $namefp|
				}
				if ![empty delabel] {
					append nline $delabel\}\}
				} elseif ![empty enlabel] {
					append nline $enlabel\}\}
				} else {
					append nline $namefp\}\}
				}
				lappend ltop10fp $rankfp $nline
			}
			if {$rankfp > 10 && $rankfp <= 100 && $nation in {AUT GER LIE SUI}} {
				set nline100 $rankfp.&nbsp\;
				if ![empty delink] {
					set link $delink
				} elseif ![empty enlink] {
					set link $enlink
				} else {
					set link $namefp
				}
				if ![empty delabel] {
					set label $delabel
				} elseif ![empty enlabel] {
					set label $enlabel
				} else {
					set label $namefp
				}
				if {$link ne $label} {
					append nline100 \[\[$link|$label\]\]
				} else {
					append nline100 \[\[$link\]\]
				}
				lappend np100fp $rankfp $nline100
			}
		}
	}
	set nltop10fp [lsort -stride 2 -index 0 -integer $ltop10fp]
	set np100fp [lsort -stride 2 -index 0 -integer $np100fp]

	set picline [lindex $spconts 20]
	foreach {idp size fi} $lcp {
		if {$idp eq $cidfp} {
			set npicline [regsub -- {(\[\[)(.*?)(\]\].*?\|Damen.*?\(Stand: )(.*?)(\))} $picline \\1Datei:$fi|rechts|$size\\3$ndatefp\\5]
			set npconts [string map [list $picline $npicline] $npconts]
			break
		}
	}
	for {set i 21} {$i <= 30} {incr i} {
		lappend oltop10fp [lindex $spconts $i]
	}
	set npconts [string map [
		list [join $oltop10fp \n] [join [dict values $nltop10fp] \n] $op100fp [join [dict values $np100fp] ",\n"]
	] $npconts]
}

if {$npconts ne $opconts} {
	puts [edit Portal:Tennis/Tennisspieler {Bot: Aktualisierung} $npconts]
}



