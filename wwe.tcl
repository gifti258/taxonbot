#!/usr/bin/tclsh8.7
#exit

set editafter 5

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
#set db [get_db dewiki]

#package require http
#package require tls
#package require tdom

namespace import tcl::mathop::+
namespace import tcl::mathop::-

set page "Benutzer:Siphonarius/Tippspiel WWE/Saison 2019/20"
set lsect [get [post $wiki {*}$parse / page $page / prop sections] parse sections]

foreach sect $lsect {
	dict with sect {
		if {[string first [sql <- $argv] $anchor] > -1} {
			set index $index
			break
		} else {
			set index err
		}
	}
}
if {$index eq {err}} {exit}

set nconts [set oconts [string map {---- {}} [conts t $page $index]]]
set lusermax [dict values [regexp -all -inline -- {Benutzer:(.*?)[|\]]} [conts t $page 4]]]
foreach user $lusermax {
	if ![empty user] {
		lappend busermax \[\[Benutzer:$user|$user\]\]
	}
}
set luser0 [dict values [regexp -all -inline -- {Benutzer:(.*?)[|\]]} $nconts]]
set sconts [split [string map {==\n \uffff \n\n \uffff} $oconts] \uffff]
foreach subsect $sconts {
	if {[string range $subsect 0 3] eq {Tipp}} {lappend ltip $subsect}
}
foreach tip $ltip {
	set lresline {}
	puts \n$tip
	input res "\nErgebnis: "
	lassign [list [split $tip \n] -1 {}] stip tipoffset lres
	if {[lindex $res 0] eq {ü}} {
		lassign [list [split [lindex $res 1] {}] 1] srestip ü
		set tipid Ü
	} else {
		lassign [list [split [lindex $res 2] {}] 0] srestip ü
		incr tipid
	}
	foreach line $stip {
		if {$line eq [lindex $stip 0]} {
			if {[string first {Tipp Ü} $line] > -1} {
				incr ü
			} elseif {[string first Singles $line] > -1} {
				set lp [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $line]]
				lassign [list [lindex [split [lindex $lp 0] |] end] [lindex [split [lindex $lp 1] |] end]] p1 p2
			} elseif {[string first {Tag Team} $line] > -1} {
				set stt [split [string map [list { gegen } \uffff { (c)} {}] $line] \uffff]
				regexp -- {\[\[.*} [lindex $stt 0] p1
				lassign [list [string map {[ {} ] {}} $p1] [string map {[ {} ] {}} [lindex $stt 1]]] p1 p2
			} elseif {[string first Triple $line] > -1} {
				set lp [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $line]]
				lassign [list [lindex [split [lindex $lp 0] |] end] [lindex [split [lindex $lp 1] |] end] [lindex [split [lindex $lp 2] |] end]] p1 p2 p3
			}
			set fall [lindex $res 1]
			switch $fall {
				co			{set resfall { per Countout}}
				dco		{set resfall {Double Countout}}
				dq			{set resfall { per Disqualification}}
				nc			{set resfall {No Contest}}
				p			{set resfall { per Pin}}
				s			{set resfall { per Submission}}
				stip		{set resfall { per Stipulation}}
				default	{set resfall {}}
			}
			set px p[lindex $res 0]
			set result [expr {
				[lindex $res 0] == 0 ? {} : [lindex $res 0] <= 3 ? [set $px] : {}
			}]$resfall
#			set result [expr {
#				[lindex $res 0] == 1 ? $p1 : [lindex $res 0] == 2 ? $p2 : {}
#			}]$resfall
			lappend lresline $line
		} elseif {$line eq [lindex $stip 1] && !${ü}} {
			set resline [string map [list 1= 1=$result] $line]
			lappend lresline $resline
		} elseif {[string first {* ...} [string map {*... {* ...}} $line]] > -1} {
			continue
		} else {
			regexp -- {Benutzer:(.*?)[|\]]} $line -- user
			regsub -- {\*[ ]?} $line "* '''[expr {
				[set restip [lindex $srestip [incr tipoffset]]] eq {d} ? {DQ} : "$restip\P"
			}]''' " resline
			lappend lresline $resline
			if {$user ni $lres} {
				if {$restip eq {d}} {
					lappend lres DQ
				} else {
					lappend lres $user $restip
					puts $user:$restip
				}
			}
		}
	}
	foreach user $luser0 {
		if {$user ni [dict keys $lres]} {
			lappend lres $user 0
		}
	}
	set nresline [join $lresline \n]
	puts \n$nresline
	set nconts [string map [list $tip $nresline] $nconts]
	dict lappend dres $tipid {*}$lres
}
foreach {tipid lres} $dres {
	incr itip
	foreach {user res} $lres {
		lappend luser $user
		lappend $user $res
	}
}
foreach user [lsort -unique $luser] {
	set buser "\[\[Benutzer:$user|$user\]\]"
	set leftbuser "style=\"text-align: left\" | $buser"
	lappend llevaltline $buser [list $leftbuser {*}[set $user] [+ {*}[set $user]]]
}
set slevaltline [lsort -decreasing -integer -stride 2 -index {1 end} $llevaltline]
lassign {0 {} { } 1} sum0 llevaltline blankf rank0
if {[llength $slevaltline] < 20} {
	set blankr { }
} else {
	set blankr {}
}
foreach {buser levaltline} $slevaltline {
puts $levaltline
	if {[set sum [lindex $levaltline end]] != $sum0} {
		set sum0 $sum
		lappend llevaltline [list rank [incr rank $rank0] user $buser valrank $blankf[incr valrank]$blankr resline $levaltline]
		set rank0 1
	} else {
		lappend llevaltline [list rank $rank user $buser valrank "data-sort-value=\"[incr valrank]\" |" resline $levaltline]
		incr rank0
	}
	if {$rank <= 3} {dict lappend dvalfoot $rank $buser}
	lappend lrank $buser $rank
}
set fmax 0
foreach levaltline $llevaltline {
	set nresline {}
	dict with levaltline {
#		if {[llength $resline] > 12} {
			lassign [list [lrange $resline 0 end-2] 0] resline-2 ival
			foreach val ${resline-2} {
				if {[incr ival] > 10} {
					lappend nresline " $val"
				} else {
					lappend nresline $val
				}
			}
			if {[lindex $resline end] >= 10} {
				lappend nresline [lindex $resline end-1] " [lindex $resline end]"
			} else {
				lappend nresline [lindex $resline end-1] "  [lindex $resline end]"
			}
#		}
		set nvaltline "| [join [list $valrank {*}$nresline] { || }]"
		set first [string first \] $nvaltline]
		if {$first > $fmax} {set fmax $first}
		lappend lnvaltline [string first \] $nvaltline] $nvaltline
	}
}
foreach {first valtline} $lnvaltline {
	lassign [list [- $fmax $first] {}] diff blank
	for {set i 0} {$i < $diff} {incr i} {
		append blank { }
	}
	set nvaltline [string map [list {]]} \]\]$blank] $valtline]
	lappend elnvaltline $nvaltline
}
set valtbody [join $elnvaltline \n|-\n]\n|\}
lassign [list [- $fmax 13] {}] diff tblank
for {set i 0} {$i < $diff} {incr i} {
	append tblank { }
}
set ltip {}
for {set i 1} {$i < $itip} {incr i} {append ltip " $i !!"}
set valtt "\{| class=\"wikitable sortable\" style=\"width: 100%; text-align: center;\"\n|-\n! Pl. !! Tipper$tblank !!$ltip Ü !! Ges.\n|-"

set valtop {
;Auswertung

Aufgrund der Addition der Punkte komme ich auf folgendes Ergebnis:

<div class="NavFrame" style="clear:both; padding: 2px; border: 1px solid #AAAAAA; text-align: center; border-collapse: collapse; font-size: 95%;">
<div style="height: 1.6em; font-weight: bold; font-size: 100%; background: #EFEFEF;">Ergebnisse</div>
<div class="NavContent" style="font-size:100%;">
}
lassign {0 0 0} 1 2 3
dict with dvalfoot {
	if {[llength $1] == 1 && [llength $2] == 2} {
		set valfoot "\n<br /><big>Damit ist '''[lindex $1 0]''' Sieger vor [lindex $2 0] und [lindex $2 1] auf dem geteilten 2. Platz.</big>"
	} elseif {[llength $1] == 2 && [llength $3] == 1} {
		set valfoot "\n<br /><big>Damit teilen sich '''[lindex $1 0]''' und '''[lindex $1 1]''' den Sieg vor [lindex $3 0] auf dem 3. Platz.</big>"
	} elseif {[llength $1] == 2 && [llength $3] > 3} {
		set valfoot "\n<br /><big>Gewonnen haben damit '''[lindex $1 0]''' und '''[lindex $1 1]'''.</big>"
	}
}
append valfoot "<br /><br />gez. -- ~~~~ <br /><small>''(Angaben ohne Gewähr)''</small>\n\n</div>\n</div>"

set wconts [conts t $page 4]
regexp -- {e\n\|-\n(.*)\n<!--} $wconts -- wtab
lassign [list [split [string map {|- \uffff} $wtab] \uffff] -1] swtab i
foreach val [lsort -unique -decreasing [dict values $lrank]] {
	lappend lval $val [incr i]
}
foreach buser $busermax {
	if {$buser ni $lrank} {
		lappend lrank $buser 0
	}
}
foreach {buser rank} $lrank {
	foreach line $swtab {
		if {[string first $buser $line] > -1} {
			switch $rank {
				1			{
								regsub -- {&nbsp;} $line {style="background:#F7F6A8;" | <u>'''1'''</u>} line
								dict lappend dü $rank $buser
							}
				2			{
								regsub -- {&nbsp;} $line {style="background:#DCE5E5;" | <u>2</u>} line
								dict lappend dü $rank $buser
							}
				3			{
								regsub -- {&nbsp;} $line {style="background:#FFDA89;" | <u>3</u>} line
								dict lappend dü $rank $buser
							}
				0			{
								regsub -- {&nbsp;} $line {} line
							}
				default	{regsub -- {&nbsp;} $line "style=\"background:#DFFFDF;\" | $rank" line}
			}
			set wpcell [lindex $line end]
			set wp [lindex [split [string map {' {}} $wpcell] \}] end]
			if !$rank {
				set nwp $wp
			} else {
				set nwp [+ $wp [dict get $lval $rank]]
			}
			if {$nwp >= 10} {
				set line [string map [list $wpcell '''$nwp'''] $line]
			} else {
				set line [string map [list $wpcell '''\{\{0\}\}$nwp'''] $line]
			}
			lappend lwtab $nwp $buser [string trim $line]
		}
	}
}
lassign {0 0 1} wpü wp0 wrank0
foreach {wp buser line} [lsort -stride 3 -decreasing -integer [lsort -index 1 -stride 3 -increasing $lwtab]] {
puts $wp:$buser:$line
	if !${wpü} {set wpü $wp}
	if {$wp0 != $wp} {
		regsub -line -- {\!.*} $line "! [incr wrank]" line
		if {$wp == ${wpü}} {dict lappend dü 0 $buser}
	} else {
		regsub -line -- {\!.*} $line "!" line
		if {$wp == ${wpü}} {dict lappend dü 0 $buser}
		incr wrank
	}
	set wp0 $wp
	lappend nwtab $line
}
set nwconts [string map [list $wtab [join $nwtab \n|-\n]] $wconts]

set üconts [conts t $page 3]
lassign {{} {} {} {} {<br />}} 1 2 3 0 br
foreach line [split ${üconts} \n] {
	if {[string first $argv $line] > -1} {
		dict with dü {
			set nü [join [list [join $1 $br] [join $2 $br] [join $3 $br] [join $0 $br]] { || }]
		}
		set nline [string map [list {||  ||  ||  ||} "|| ${nü}"] $line]
		break
	}
}

set xconts [conts t $page x]
set nxconts [string map [list $oconts $nconts ---- $valtop\n$valtt\n$valtbody\n$valfoot $wtab [join $nwtab \n|-\n] $line $nline] $xconts]

puts $nxconts ; gets stdin

puts [edit $page "Bot: + Auswertung $argv" $nxconts]
