#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang meta ; source langwiki.tcl ; #set token [login $wiki]
package require http ; package require tls ; package require tdom

meta_lang

set lang d ; source langwiki.tcl ; #set token [login $wiki]

set lpt [d_query_wir {Q1037 Q889884}]
foreach pt $lpt {
	set offset 1
	puts -$pt
	while {$offset} {
		if [catch {
			if [redirect $pt] {set offset 0 ; break}
			if {{enwiki} ni [dict keys [set sitelinks [
				get [post $wiki {*}$get {*}$format / action wbgetentities / ids $pt / props sitelinks] entities $pt sitelinks
			]]]} {
				lassign {} llabels label lsitelinks ldesc lllabelvp27 lllabelvp19 lllabelvp20 lvp106
				set dlabels [
					get [post $wiki {*}$get {*}$format / action wbgetentities / ids $pt / props labels
				] entities $pt labels]
				if {{en} in [dict keys $dlabels]} {
					set label \[\[[dict get $dlabels en value]\]\]
				} else {
					foreach w $llang {catch {lappend llabels $w [dict get $dlabels $w]}}
					if ![empty llabels] {
						set label \[\[[dict get [lindex $llabels 1] value]\]\]
					} else {
						set label \[\[[dict get [lindex $dlabels 1] value]\]\]
					}
				}
				if [empty label] {set label "<small>''- kein Wikidata-Label -''</small>"}
				foreach w $lw {catch {lappend lsitelinks $w [dict get $sitelinks $w]}}
				set csitelinks [llength [dict keys $lsitelinks]]
				puts $pt:$label
				set lkclaims [dict keys [
					set claims [
						get [post $wiki {*}$get {*}$format / action wbgetclaims / entity $pt] claims
					]
				]]
				set vp18 {}
				if {{P18} in $lkclaims} {
					set lp18 [dict get $claims P18]
					foreach p18 $lp18 {
						if {[dict get $p18 mainsnak snaktype] in {novalue somevalue}} {lappend lvp18 {} ; continue}
						set vp18 \[\[File:[dict get $p18 mainsnak datavalue value]|center|120px\]\]
						if ![empty vp18] {continue} else {break}
					}
				} else {
					set vp18 {}
				}
				set ddesc [
					get [post $wiki {*}$get {*}$format / action wbgetentities / ids $pt / props descriptions] entities $pt descriptions
				]
				if {{en} in [dict keys $ddesc]} {
					set desc [dict get $ddesc en value]
				} else {
					foreach dw $llang {catch {lappend ldesc $dw [dict get $ddesc $dw]}}
					if ![empty ldesc] {set desc [dict get [lindex $ldesc 1] value]} else {set desc {}}
				}
				set desc [string map [list ", " ",<br />" " and " "<br />and "] $desc]
				if {{P27} in $lkclaims} {
					foreach p27 [dict get $claims P27] {
						if {[dict get $p27 mainsnak snaktype] eq {somevalue}} {lappend lllabelvp27 {} ; continue}
						lassign {} dlabelvp27 llabelvp27
						set vp27 [dict get $p27 mainsnak datavalue value id]
						set dlabelvp27 [get [
							post $wiki {*}$get {*}$format / action wbgetentities / ids $vp27 / props labels
						] entities $vp27 labels]
						if {{en} in [dict keys $dlabelvp27]} {
							lappend lllabelvp27 \[\[[dict get $dlabelvp27 en value]\]\]
						} else {
							foreach w $llang {catch {lappend llabelvp27 $w [dict get $dlabelvp27 $w]}}
							lappend lllabelvp27 \[\[[dict get [lindex $llabelvp27 1] value]\]\]
						}
					}
					set labelvp27 [join $lllabelvp27 {,<br />}]
				} else {
					set labelvp27 {}
				}
				if {{P106} in $lkclaims} {
					foreach p106 [dict get $claims P106] {
						set lp2521 [get [post $wiki {*}$get {*}$format / action wbgetclaims / entity [set fid [dict get $p106 mainsnak datavalue value id]]] claims P2521]
						set llvp106 {}
						foreach p2521 $lp2521 {
							set p2521f [dict get $p2521 mainsnak datavalue value]
							dict with p2521f {
								if {$language eq {en}} {
									lappend llvp106 $text
								}
							}
						}
						if ![empty llvp106] {
							lappend lvp106 [join $llvp106]
						} else {
							puts "weiblicher Bezeichner für $fid fehlt" ; gets stdin
						}
					}
					set vp106 [join [lsort -unique $lvp106] {, }]
				} else {
					set vp106 {}
				}
				if {{P569} in $lkclaims} {
					set ltimep569 {}
					set lp569 [dict get $claims P569]
					foreach p569 $lp569 {
						if {[dict get $p569 mainsnak snaktype] in {novalue somevalue}} {lappend ltimep569 {} ; continue}
						set vp569 [dict get $p569 mainsnak datavalue value]
						if {[string index $vp569 5] eq {-}} {
							set vp569 [string map {{time -} {time +}} $vp569]
							set vuz { BC}
						} else {
							set vuz {}
						}
						set timep569 [string trimleft [lindex [split [dict get $vp569 time] +T] 1] 0]
						set stimep569 [split $timep569 -]
						if {[lindex $stimep569 1] eq {00}} {
							if {[lindex $stimep569 2] eq {00}} {
								set timep569 [lindex $stimep569 0]
							} else {
								set timep569 [lindex $stimep569 0]-[lindex $stimep569 1]
							}
						}
						set calp569 [lindex [split [dict get $vp569 calendarmodel] /] end]
						if {$calp569 eq {Q1985786}} {
							lappend ltimep569 [append timep569 "$vuz<br /><small>(Julian)</small>"]
						} else {
							lappend ltimep569 $timep569$vuz
						}
					}
					set timep569 [join $ltimep569 {<br />}]
				} else {
					set timep569 {}
				}
				if {{P570} in $lkclaims} {
					set ltimep570 {}
					set lp570 [dict get $claims P570]
					foreach p570 $lp570 {
						if {[dict get $p570 mainsnak snaktype] in {novalue somevalue}} {lappend ltimep570 {} ; continue}
						set vp570 [dict get $p570 mainsnak datavalue value]
						if {[string index $vp570 5] eq {-}} {
							set vp570 [string map {{time -} {time +}} $vp570]
							set vuz { BC}
						} else {
							set vuz {}
						}
						set timep570 [string trimleft [lindex [split [dict get $vp570 time] +T] 1] 0]
						set stimep570 [split $timep570 -]
						if {[lindex $stimep570 1] eq {00}} {
							if {[lindex $stimep570 2] eq {00}} {
								set timep570 [lindex $stimep570 0]
							} else {
								set timep570 [lindex $stimep570 0]-[lindex $stimep570 1]
							}
						}
						set calp570 [lindex [split [dict get $vp570 calendarmodel] /] end]
						if {$calp570 eq {Q1985786}} {
							lappend ltimep570 [append timep570 "$vuz<br /><small>(Julian)</small>"]
						} else {
							lappend ltimep570 $timep570$vuz
						}
					}
					set timep570 [join $ltimep570 {<br />}]
				} else {
					set timep570 {}
				}
				if {{P19} in $lkclaims} {
					foreach p19 [dict get $claims P19] {
						if {[dict get $p19 mainsnak snaktype] eq {somevalue}} {lappend lllabelvp19 {} ; continue}
						lassign {} dlabelvp19 llabelvp19
						set vp19 [dict get $p19 mainsnak datavalue value id]
						set dlabelvp19 [get [
							post $wiki {*}$get {*}$format / action wbgetentities / ids $vp19 / props labels
						] entities $vp19 labels]
						if {{en} in [dict keys $dlabelvp19]} {
							lappend lllabelvp19 \[\[[dict get $dlabelvp19 en value]\]\]
						} else {
							foreach w $llang {catch {lappend llabelvp19 $w [dict get $dlabelvp19 $w]}}
							lappend lllabelvp19 \[\[[dict get [lindex $llabelvp19 1] value]\]\]
						}
					}
					set labelvp19 [join $lllabelvp19 {,<br />}]
				} else {
					set labelvp19 {}
				}
				if {{P20} in $lkclaims} {
					foreach p20 [dict get $claims P20] {
						if {[dict get $p20 mainsnak snaktype] eq {somevalue}} {lappend lllabelvp20 {} ; continue}
						lassign {} dlabelvp20 llabelvp20
						set vp20 [dict get $p20 mainsnak datavalue value id]
						set dlabelvp20 [get [
							post $wiki {*}$get {*}$format / action wbgetentities / ids $vp20 / props labels
						] entities $vp20 labels]
						if {{en} in [dict keys $dlabelvp20]} {
							lappend lllabelvp20 \[\[[dict get $dlabelvp20 en value]\]\]
						} else {
							foreach w $llang {catch {lappend llabelvp20 $w [dict get $dlabelvp20 $w]}}
							lappend lllabelvp20 \[\[[dict get [lindex $llabelvp20 1] value]\]\]
						}
					}
					set labelvp20 [join $lllabelvp20 {,<br />}]
				} else {
					set labelvp20 {}
				}
				set entity \[\[:d:$pt|$pt\]\]
				if {![empty desc] && ![empty vp106]} {set border \n----\n} else {set border {}}
				dict lappend dndefpt $csitelinks [list $label $desc$border[join $vp106] $vp18 $labelvp27 $timep569 $timep570 $labelvp19 $labelvp20 $entity]
			}
		}] {
			continue
		} else {
			break
		}
	}
}
set odsitelinks [lsort -stride 2 -index 0 -integer -decreasing $dndefpt]
foreach {sitelinks site} $odsitelinks {
	lappend lsite $site
	if {[llength [join $lsite]] <= 7500} {dict lappend dsitelinks $sitelinks $site} else {break}
}
set th "\{| class=\"wikitable sortable\" style=\"width: 100%;\"\n! ser. !! Wikis !! Name !! Description / Occupation !! Picture !! Nationality !! Date<br />of birth !! Date<br />of death !! Location<br />of birth !! Location<br />of death !! Wikidata<br />object"
set i 0
foreach {ll lndefpt} [join $dsitelinks] {
	foreach ndefpt $lndefpt {
		append tb "\n|-\n| style=\"text-align: right;\" | [incr i]\n| style=\"text-align: right;\" | $ll"
		append tb "\n| [join $ndefpt "\n| "]"
	}
}
set tf "|\}"
if {$i >= 1000} {
	set ncount \{\{0|.\}\}[tdot $i]
} elseif {$i >= 100} {
	set ncount \{\{0|00\}\}$i
} elseif {$i >= 10} {
   set ncount \{\{0|000\}\}$i
} else {
   set ncount \{\{0|0000\}\}$i
}
set tab <noinclude>$th$tb\n$tf</noinclude><includeonly>$ncount</includeonly>

set lang en ; source langwiki.tcl ; #set token [login $wiki]
puts [edit {user:Gereon K./Women Rwanda} {Bot: Update Wikidata list} $tab / minor]

