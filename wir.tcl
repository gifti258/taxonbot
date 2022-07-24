#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang meta ; source langwiki.tcl ; #set token [login $wiki]

set langconts [conts t {List of Wikipedias/Table} x]
set llang [dict values [regexp -all -inline -- {\| \[\[\:(.*?)\:\|} $langconts]]
foreach lan $llang {
   lappend lw [string map {- _} $lan]wiki
}

set occ		[lindex $argv 0 0]
set lqocc	[lindex $argv 0 1]
set lnqocc	[lindex $argv 0 2]
if [empty lnqocc] {set lnqocc Q0}
foreach ll {lqocc lnqocc} {
	set nl {}
	for {set f 1} {$f <= 25} {incr f} {lappend nl [subst $$ll]}
	set $ll [lrange [join $nl] 0 24]
}
foreach ll {qocc nqocc} {
	for {set f 1} {$f <= 25} {incr f} {
		set $ll$f [lindex [subst $\l$ll] [expr $f - 1]]
	}
}
for {set f 1} {$f <= 25} {incr f} {
	lappend sqlqocc '[subst $\qocc$f]'
}

if {$occ eq {Autorinnen}} {
	set ld {}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]

	foreach pgid {9950746 9951066 9951068 9954103 9954120} {
		lappend ld [dict values [regexp -all -inline -- {:d:(Q.*?)\|} [conts id $pgid x]]]
	}
	set ld [join $ld]
}
if {$occ eq {Musikerinnen}} {
	set ld {}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]

	foreach pgid {9952823 9962621 9950903 9950985 9962329 9992687} {
		lappend ld [dict values [regexp -all -inline -- {:d:(Q.*?)\|} [conts id $pgid x]]]
	}
	set ld [join $ld]
}
if {$occ eq {Schriftstellerinnen}} {
	set ld {}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]

	foreach pgid {9950746 9951066 9951068 9992687} {
		lappend ld [dict values [regexp -all -inline -- {:d:(Q.*?)\|} [conts id $pgid x]]]
	}
	set ld [join $ld]
}
if {$occ eq {Sozialwissenschaftlerinnen}} {
	set ld {}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]

	foreach pgid {9950153 9950994 9954430 9954880} {
		lappend ld [dict values [regexp -all -inline -- {:d:(Q.*?)\|} [conts id $pgid x]]]
	}
	set ld [join $ld]
}
if {$occ eq {Sportlerinnen}} {
	set ld {}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]

	foreach pgid {9952121 9952131 9952106 9951593 9951617 9952132 9952122 9952101 9952102 9954181 9951601 9951584 9951598 9952138 9956349 9952116 9951604 9951589 9952225 9951639 9951592 9951599 9951574 9954238 9951060 9951630 9951567 10426255} {
		lappend ld [dict values [regexp -all -inline -- {:d:(Q.*?)\|} [conts id $pgid x]]]
	}
	set ld [join $ld]
}
if {$occ eq {weitere Wissenschaftlerinnen}} {
	set ld {}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]

	foreach pgid {9950081 9950082 9950153 9950994 9951018 9954430 9954880 10040500 10041104 10041726} {
		lappend ld [dict values [regexp -all -inline -- {:d:(Q.*?)\|} [conts id $pgid x]]]
	}
	set ld [join $ld]
}

set lang d ; source langwiki.tcl ; #set token [login $wiki]

set db [get_db wikidatawiki]
mysqlreceive $db "
	select page_id
	from page e, pagelinks f
	where f.pl_from = e.page_id and e.page_id in (
		select page_id
		from page c, pagelinks d
		where d.pl_from = c.page_id and c.page_id in (
			select page_id
			from page a, pagelinks b
			where b.pl_from = a.page_id and !a.page_namespace and !b.pl_from_namespace and !b.pl_namespace and b.pl_title = 'Q5'
		) and !c.page_namespace and !d.pl_from_namespace and !d.pl_namespace and d.pl_title = 'Q6581072'
	) and !e.page_namespace and !f.pl_from_namespace and !f.pl_namespace and f.pl_title in ([join $sqlqocc ,])
;" fpt {
	lappend lfpt $fpt
}
mysqlclose $db
set db [get_db wikidatawiki]
mysqlreceive $db "
	select page_title
	from page g, pagelinks h
	where h.pl_from = g.page_id and g.page_id in ([join $lfpt ,]) and !g.page_namespace and !h.pl_from_namespace and h.pl_namespace = 120 and h.pl_title = 'P106'
;" p106fpt {
	lappend lp106fpt $p106fpt
}
mysqlclose $db
set dndefpt {}
foreach p106fpt $lp106fpt {
set offset 1
puts -$p106fpt
	while {$offset} {
		if [catch {
			if {[redirect $p106fpt] || $p106fpt eq {Q784759}} {set offset 0 ; break}
			if {{dewiki} ni [dict keys [set sitelinks [
				get [post $wiki {*}$get {*}$format / action wbgetentities / ids $p106fpt / props sitelinks] entities $p106fpt sitelinks
			]]] && [string first Q5\} [dict get [set claims [
					get [post $wiki {*}$get {*}$format / action wbgetclaims / entity $p106fpt] claims
				]] P31]] > -1
			&&	 ([string first $qocc1\} [dict get $claims P106]] > -1
			||   [string first $qocc2\} [dict get $claims P106]] > -1
			||   [string first $qocc3\} [dict get $claims P106]] > -1
			||   [string first $qocc4\} [dict get $claims P106]] > -1
			||   [string first $qocc5\} [dict get $claims P106]] > -1
			||   [string first $qocc6\} [dict get $claims P106]] > -1
			||   [string first $qocc7\} [dict get $claims P106]] > -1
			||   [string first $qocc8\} [dict get $claims P106]] > -1
			||   [string first $qocc9\} [dict get $claims P106]] > -1
			||   [string first $qocc10\} [dict get $claims P106]] > -1
			||   [string first $qocc11\} [dict get $claims P106]] > -1
			||   [string first $qocc12\} [dict get $claims P106]] > -1
			||   [string first $qocc13\} [dict get $claims P106]] > -1
			||   [string first $qocc14\} [dict get $claims P106]] > -1
			||   [string first $qocc15\} [dict get $claims P106]] > -1
			||   [string first $qocc16\} [dict get $claims P106]] > -1
			||   [string first $qocc17\} [dict get $claims P106]] > -1
			||   [string first $qocc18\} [dict get $claims P106]] > -1
			||   [string first $qocc19\} [dict get $claims P106]] > -1
			||   [string first $qocc20\} [dict get $claims P106]] > -1
			||   [string first $qocc21\} [dict get $claims P106]] > -1
			||   [string first $qocc22\} [dict get $claims P106]] > -1
			||   [string first $qocc23\} [dict get $claims P106]] > -1
			||   [string first $qocc24\} [dict get $claims P106]] > -1
			||   [string first $qocc25\} [dict get $claims P106]] > -1)
			&&	!([string first $nqocc1\} [dict get $claims P106]] > -1
			||   [string first $nqocc2\} [dict get $claims P106]] > -1
			||   [string first $nqocc3\} [dict get $claims P106]] > -1
			||   [string first $nqocc4\} [dict get $claims P106]] > -1
			||   [string first $nqocc5\} [dict get $claims P106]] > -1
			||   [string first $nqocc6\} [dict get $claims P106]] > -1
			||   [string first $nqocc7\} [dict get $claims P106]] > -1
			||   [string first $nqocc8\} [dict get $claims P106]] > -1
			||   [string first $nqocc9\} [dict get $claims P106]] > -1
			||   [string first $nqocc10\} [dict get $claims P106]] > -1
			||   [string first $nqocc11\} [dict get $claims P106]] > -1
			||   [string first $nqocc12\} [dict get $claims P106]] > -1
			||   [string first $nqocc13\} [dict get $claims P106]] > -1
			||   [string first $nqocc14\} [dict get $claims P106]] > -1
			||   [string first $nqocc15\} [dict get $claims P106]] > -1
			||   [string first $nqocc16\} [dict get $claims P106]] > -1
			||   [string first $nqocc17\} [dict get $claims P106]] > -1
			||   [string first $nqocc18\} [dict get $claims P106]] > -1
			||   [string first $nqocc19\} [dict get $claims P106]] > -1
			||   [string first $nqocc20\} [dict get $claims P106]] > -1
			||   [string first $nqocc21\} [dict get $claims P106]] > -1
			||   [string first $nqocc22\} [dict get $claims P106]] > -1
			||   [string first $nqocc23\} [dict get $claims P106]] > -1
			||   [string first $nqocc24\} [dict get $claims P106]] > -1
			||   [string first $nqocc25\} [dict get $claims P106]] > -1)} {
				lassign {} llabels label lsitelinks ldesc lllabelvp27 lllabelvp19 lllabelvp20 lvp106
				set dlabels [get [
					post $wiki {*}$get {*}$format / action wbgetentities / ids $p106fpt / props labels
				] entities $p106fpt labels]
				if {{de} in [dict keys $dlabels]} {
					set label \[\[[dict get $dlabels de value]\]\]
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
				if {!$csitelinks || ($occ in {Musikerinnen Sportlerinnen} && $p106fpt in $ld)} {set offset 0 ; break}
				puts $p106fpt
				set lkclaims [dict keys $claims]
				set vp18 {}
				if {{P18} in $lkclaims} {
					set lp18 [dict get $claims P18]
					foreach p18 $lp18 {
						if {[dict get $p18 mainsnak snaktype] in {novalue somevalue}} {lappend lvp18 {} ; continue}
						set vp18 \[\[Datei:[dict get $p18 mainsnak datavalue value]|center|120px\]\]
						if ![empty vp18] {continue} else {break}
					}
				} else {
					set vp18 {}
				}
				set ddesc [
						get [post $wiki {*}$get {*}$format / action wbgetentities / ids $p106fpt / props descriptions] entities $p106fpt descriptions
				]
				if {{de} in [dict keys $ddesc]} {
					set desc [dict get $ddesc de value]
				} else {
					foreach dw $llang {catch {lappend ldesc $dw [dict get $ddesc $dw]}}
					if ![empty ldesc] {set desc [dict get [lindex $ldesc 1] value]} else {set desc {}}
				}
				set desc [string map [list ", " ",<br />" " and " "<br />and " " und " "<br />und "] $desc]
				if {{P27} in $lkclaims} {
					foreach p27 [dict get $claims P27] {
						if {[dict get $p27 mainsnak snaktype] eq {somevalue}} {lappend lllabelvp27 {} ; continue}
						lassign {} dlabelvp27 llabelvp27
						set vp27 [dict get $p27 mainsnak datavalue value id]
						set dlabelvp27 [get [
							post $wiki {*}$get {*}$format / action wbgetentities / ids $vp27 / props labels
						] entities $vp27 labels]
						if {{de} in [dict keys $dlabelvp27]} {
							set vlabelvp27 [dict get $dlabelvp27 de value]
							set lang de ; source langwiki.tcl ; #set token [login $wiki]
							if ![missing Vorlage:$vlabelvp27] {
								lappend lllabelvp27 \{\{$vlabelvp27\}\}
							} else {
								lappend lllabelvp27 \[\[$vlabelvp27\]\]
							}
							set lang d ; source langwiki.tcl ; #set token [login $wiki]
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
								if {$language eq {de}} {
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
							set vuz { v.u.Z.}
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
							lappend ltimep569 [append timep569 "$vuz<br /><small>(julian.)</small>"]
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
							set vuz { v.u.Z.}
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
							lappend ltimep570 [append timep570 "$vuz<br /><small>(julian.)</small>"]
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
						if {{de} in [dict keys $dlabelvp19]} {
							lappend lllabelvp19 \[\[[dict get $dlabelvp19 de value]\]\]
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
						if {{de} in [dict keys $dlabelvp20]} {
							lappend lllabelvp20 \[\[[dict get $dlabelvp20 de value]\]\]
						} else {
							foreach w $llang {catch {lappend llabelvp20 $w [dict get $dlabelvp20 $w]}}
							lappend lllabelvp20 \[\[[dict get [lindex $llabelvp20 1] value]\]\]
						}
					}
					set labelvp20 [join $lllabelvp20 {,<br />}]
				} else {
					set labelvp20 {}
				}
				set entity \[\[:d:$p106fpt|$p106fpt\]\]
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
set th "\{| class=\"wikitable sortable\" style=\"width: 100%;\"\n! lfd. !! Wikis !! Name !! Beschreibung / Tätigkeit !! Bild !! Staats-<br />angehörigkeit !! Geburtsdatum !! Sterbedatum !! Geburtsort !! Sterbeort !! Wikidata-<br />Objekt"
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

set lang de ; source langwiki.tcl ; #set token [login $wiki]
puts $occ:
puts [edit Wikipedia:WikiProjekt_Frauen/Frauen_in_Rot/Fehlende_Artikel_nach_Tätigkeit/$occ {Bot: Update Wikidata-Liste} $tab / minor]
