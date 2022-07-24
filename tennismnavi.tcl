#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang meta ; source langwiki.tcl ; #set token [login $wiki]

meta_lang

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set html [getHTML https://query.wikidata.org/sparql?query=[curl::escape [format {
	select ?enwiki ?dewiki ?item ?itemLabel
		where {
			?item	wdt:P31	wd:Q5;
					wdt:P21	wd:Q6581097;
					wdt:P106 wd:Q10833314
			service wikibase:label { bd:serviceParam wikibase:language 'de,en,%s'. }
			optional { ?dearticle
				schema:about ?item;
				schema:name ?dewiki;
				schema:isPartOf <https://de.wikipedia.org/>
			}
      	optional { ?enarticle
				schema:about ?item;
				schema:name ?enwiki;
				schema:isPartOf <https://en.wikipedia.org/>
      	}
		}
} [join $llang ,]]]]

foreach {-- res} [regexp -all -inline -- {<result>(.*?)</result>} $html] {
	set sres [split $res \n]
	lassign {} item de en d
	foreach {key val --} [lrange $sres 1 end-1] {
		if {[string first 'item' 		$key] > -1} {set item	[lindex [split [lindex [split $val <>] 2] /] end]}
		if {[string first dewiki 		$key] > -1} {set de		[lindex [split $val <>] 2]}
		if {[string first enwiki 		$key] > -1} {set en		[lindex [split $val <>] 2]}
		if {[string first itemLabel	$key] > -1} {set d		[lindex [split $val <>] 2]}
	}
	lappend dmplayer $item [list de $de en $en d $d]
}

set htmlATPs [getHTML https://www.atptour.com/en/rankings/singles?rankRange=1-5000]

set htmlATPd [getHTML https://www.atptour.com/en/rankings/doubles?rankRange=1-5000]

read_file tennisATP.db tennisATP
set ltennisATP [join [split $tennisATP \n]]

regexp -- {<li data-value="(.*?)"} $htmlATPs -- rankdates
set htmlrexs [regexp -all -inline -- {<tr>(.*?)</tr>} $htmlATPs]

regexp -- {<li data-value="(.*?)"} $htmlATPd -- rankdated
set htmlrexd [regexp -all -inline -- {<tr>(.*?)</tr>} $htmlATPd]

foreach {htmlrex sd} [list $htmlrexs dtrs $htmlrexd dtrd] {
	foreach tr [dict values $htmlrex] {
		if {[string first rank-cell $tr] > -1} {
			regexp -- {"rank-cell">.*?(\d.*)\D} $tr -- rank
			if {[string first move-none $tr] > -1} {
				set prank 0
			} else {
				regexp -- {"move-text">.*?(\d.*)\D} $tr -- prank
				if {[string first move-down $tr] > -1} {
					set prank [expr 0 - $prank]
				}
			}
			regexp -- {.svg.*?([A-Z]{3})} $tr -- nat
			regexp -- {ga-label="(.*?)"} $tr -- player
			try {
				if {[set q [dict get $ltennisATP $player]] ne {Q}} {
					set dwd [dict get $dmplayer $q]
					if {[set player [dict get $dwd de]] eq {}} {set player [dict get $dwd d]}
				}
			} on 1 {} {
				puts caught:$player
				prepend_file tennisATP.db [format {{%s} Q} $player]
			}
			if {$sd eq {dtrs}} {
				if {[incr poss] <= 10} {
					dict lappend dtr * [list $rank $prank $nat $player]
				}
				dict lappend dtr $nat [list $rank $prank $nat $player]
			} elseif {$sd eq {dtrd}} {
				if {[incr posd] <= 10} {
					dict lappend dtr ** [list $rank $prank $nat $player]
				}
				dict lappend dtr $nat** [list $rank $prank $nat $player]
			}
		}
	}
}

set ltemp [scat {Vorlage:Navigationsleiste Bestplatzierte Tennisspieler (ATP)} 10]

foreach temp $ltemp {
	set ctemp [conts t Vorlage:$temp x]
	if {{Welt} in $temp} {
		if {{Einzel} in $temp} {set tempnat *} else {set tempnat **}
		regexp -- {(\| Stand.*?\n)\}} $ctemp -- olrank
	} elseif {{Doppel} in $temp} {
		regexp -- {([A-Z]{3})\|#.*?(\| Stand.*?\n)\}} $ctemp -- tempnat olrank
		append tempnat **
	} else {
		regexp -- {([A-Z]{3})\|#.*?(\| Stand.*?\n)\}} $ctemp -- tempnat olrank
	}
	puts $tempnat:$olrank
	set pos 0
	set lrank "| Stand      = [expr {[string first ** $tempnat] > -1 ? $rankdated : $rankdates}]\n"
	foreach {rank prank nat player} [join [dict get $dtr $tempnat]] {
		if {[incr pos] > 10} {break}
		regsub -- { \(Tennisspieler\)} $player {} altplayer
		if {$tempnat in {* **}} {
			append lrank "| Name$pos    [expr {$pos < 10 ? { } : {}}] = \{\{$nat|$player|$altplayer\}\}\n"
		} else {
			append lrank "| Name$pos    [expr {$pos < 10 ? { } : {}}] = $player[expr {$altplayer ne $player ? "\{\{!\}\}$altplayer" : {}}]\n"
		}
		append lrank "| Position$pos[expr {$pos < 10 ? { } : {}}] = $rank\n"
		append lrank "| Änderung$pos[expr {$pos < 10 ? { } : {}}] = $prank\n"
		puts $rank:$prank:$nat:$player:$altplayer
	}
	puts \n$lrank
	set nctemp [string map [list $olrank $lrank] $ctemp]
	if {$nctemp ne $ctemp} {
#		gets stdin
		puts [edit Vorlage:$temp {Bot: Aktualisierung} $nctemp / minor]
	}
}

set today [utc ^ seconds {} %d.%m.%Y {}]

read_file tennisIOC.db tennisIOC

lassign {-1 -1 {}} rms rmd otbody
foreach {sd param land} {s ?page tennisWTAs.db d ?t=doubles&page tennisWTAd.db} {
	for {set page 1} {$page <= 35} {incr page} {
		set html [getHTML https://www.tennisexplorer.com/ranking/wta-women/$param=$page]
		regexp -- {\d\d\.\d\d\.\d{4}} $html ddate
		if {$ddate ne $today} {exit}
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

set html [getHTML https://query.wikidata.org/sparql?query=[curl::escape [format {
	select ?enwiki ?dewiki ?item ?itemLabel
		where {
			?item	wdt:P31	wd:Q5;
					wdt:P21	wd:Q6581072;
					wdt:P106 wd:Q10833314
			service wikibase:label { bd:serviceParam wikibase:language 'de,en,%s'. }
			optional { ?dearticle
				schema:about ?item;
				schema:name ?dewiki;
				schema:isPartOf <https://de.wikipedia.org/>
			}
      	optional { ?enarticle
				schema:about ?item;
				schema:name ?enwiki;
				schema:isPartOf <https://en.wikipedia.org/>
      	}
		}
} [join $llang ,]]]]

foreach {-- res} [regexp -all -inline -- {<result>(.*?)</result>} $html] {
	set sres [split $res \n]
	lassign {} item de en d
	foreach {key val --} [lrange $sres 1 end-1] {
		if {[string first 'item' 		$key] > -1} {set item	[lindex [split [lindex [split $val <>] 2] /] end]}
		if {[string first dewiki 		$key] > -1} {set de		[lindex [split $val <>] 2]}
		if {[string first enwiki 		$key] > -1} {set en		[lindex [split $val <>] 2]}
		if {[string first itemLabel	$key] > -1} {set d		[lindex [split $val <>] 2]}
	}
	lappend dfplayer $item [list de $de en $en d $d]
}

read_file tennisWTA.db tennisWTA
set ltennisWTA [join [split $tennisWTA \n]]

read_file tennisWTAs.db tennisWTAs
set stennisWTAs [split $tennisWTAs \n]

read_file tennisWTAd.db tennisWTAd
set stennisWTAd [split $tennisWTAd \n]

lassign {{} 0 0} rankline poss posd
foreach {stennisWTA sd} [list $stennisWTAs lines $stennisWTAd lined] {
	foreach line $stennisWTA {
		set rawplayer	[lindex $line 1]
		set player		[lindex $line 2]
		try {
			if {[set q [dict get $ltennisWTA $rawplayer]] ne {Q}} {
				set dwd [dict get $dfplayer $q]
				if {[set player [dict get $dwd de]] eq {}} {
					set player [dict get $dwd d]
				}
			}
		} on 1 {} {
			puts caught:$rawplayer
			prepend_file tennisWTA.db [format {{%s} Q} $rawplayer]
		}
		set line [string map [list [lrange $line 1 2] [list $player]] $line]
		set nat [lindex $line 0]
		dict with rankline {
			if {$sd eq {lines}} {
				if {[incr poss] <= 10} {
					dict lappend dline * $line
				}
				dict lappend dline $nat $line
			} elseif {$sd eq {lined}} {
				if {[incr posd] <= 10} {
					dict lappend dline ** $line
				}
				dict lappend dline $nat** $line
			}
		}
	}
}

set ltemp [scat {Vorlage:Navigationsleiste Bestplatzierte Tennisspielerinnen (WTA)} 10]

foreach temp $ltemp {
	set ctemp [conts t Vorlage:$temp x]
	if {{Welt} in $temp} {
		if {{Einzel} in $temp} {set tempnat *} else {set tempnat **}
		regexp -- {(\| Stand.*?\n)\}} $ctemp -- olrank
	} elseif {{Doppel} in $temp} {
		regexp -- {([A-Z]{3})\|#.*?(\| Stand.*?\n)\}} $ctemp -- tempnat olrank
		append tempnat **
	} else {
		regexp -- {([A-Z]{3})\|#.*?(\| Stand.*?\n)\}} $ctemp -- tempnat olrank
	}
	puts $tempnat:$olrank
	set pos 0
	set lrank "| Stand      = [expr {[string first ** $tempnat] > -1 ? $rankdated : $rankdates}]\n"
	foreach {nat player rank prank} [join [dict get $dline $tempnat]] {
		if {[incr pos] > 10} {break}
		regsub -- { \(Tennisspielerin\)} $player {} altplayer
		if {$tempnat in {* **}} {
			append lrank "| Name$pos    [expr {$pos < 10 ? { } : {}}] = \{\{$nat|$player|$altplayer\}\}\n"
		} else {
			append lrank "| Name$pos    [expr {$pos < 10 ? { } : {}}] = $player[expr {$altplayer ne $player ? "\{\{!\}\}$altplayer" : {}}]\n"
		}
		append lrank "| Position$pos[expr {$pos < 10 ? { } : {}}] = $rank\n"
		append lrank "| Änderung$pos[expr {$pos < 10 ? { } : {}}] = $prank\n"
		puts $rank:$prank:$nat:$player:$altplayer
	}
	puts \n$lrank
	set nctemp [string map [list $olrank $lrank] $ctemp]
	if {$nctemp ne $ctemp} {
#		gets stdin
		puts [edit Vorlage:$temp {Bot: Aktualisierung} $nctemp / minor]
	}
}





exit
		if {[string first rank-cell $tr] > -1} {
			regexp -- {"rank-cell">.*?(\d.*)\D} $tr -- rank
			if {[string first move-none $tr] > -1} {
				set prank 0
			} else {
				regexp -- {"move-text">.*?(\d.*)\D} $tr -- prank
				if {[string first move-down $tr] > -1} {
					set prank [expr 0 - $prank]
				}
			}
			regexp -- {.svg.*?([A-Z]{3})} $tr -- nat
			regexp -- {ga-label="(.*?)"} $tr -- player
			if {[set q [dict get $ltennisATP $player]] ne {Q}} {
				set dwd [dict get $dmplayer $q]
				if {[set player [dict get $dwd de]] eq {}} {set player [dict get $dwd d]}
			}
			if {$sd eq {dtrs}} {
				if {[incr poss] <= 10} {
					dict lappend dtr * [list $rank $prank $nat $player]
				}
				dict lappend dtr $nat [list $rank $prank $nat $player]
			} elseif {$sd eq {dtrd}} {
				if {[incr posd] <= 10} {
					dict lappend dtr ** [list $rank $prank $nat $player]
				}
				dict lappend dtr $nat** [list $rank $prank $nat $player]
			}
		}
	}
}

set ltemp [scat {Vorlage:Navigationsleiste Bestplatzierte Tennisspielerinnen (WTA)} 10]



exit

foreach temp $ltemp {
	set ctemp [conts t Vorlage:$temp x]
	if {{Welt} in $temp} {
		if {{Einzel} in $temp} {set tempnat *} else {set tempnat **}
		regexp -- {(\| Stand.*?\n)\}} $ctemp -- olrank
	} elseif {{Doppel} in $temp} {
		regexp -- {([A-Z]{3})\|#.*?(\| Stand.*?\n)\}} $ctemp -- tempnat olrank
		append tempnat **
	} else {
		regexp -- {([A-Z]{3})\|#.*?(\| Stand.*?\n)\}} $ctemp -- tempnat olrank
	}
	set pos 0
	set lrank "| Stand      = [expr {$tempnat eq {**} ? $rankdated : $rankdates}]\n"
	if {[string first ** $tempnat] > -1} {set stennisWTA $stennisWTAd} else {set stennisWTA $stennisWTAs}
	foreach line $stennisWTA {
		lassign {} rank prank nat player
		set rank [lindex $line 0]
		if {[string first ( [lindex $line 1]] > -1} {
			set prank [string trim [lindex $line 1] ()]
		} elseif {[string first ** $tempnat] > -1} {
			set prank $rankoffsetd
		} else {
			set prank $rankoffsets
		}
		set line [lreverse [regsub -- {([A-Z]{3})} [lreverse $line] |\\1]]
		regexp -- {\|([A-Z]{3})} $line -- nat
		if {$nat ne $tempnat && [string first * $tempnat] == -1} {continue}
		if {$tempnat eq {GER**} && $nat ne {GER}} {continue}
		if {!(
					[string is integer $rank]
				&& [string is upper $nat]
				&& [string length $nat] == 3)
			} {continue}
		regexp -- {([A-Z].*?) \|} $line -- player
		if {[set q [dict get $ltennisWTA $player]] eq {Q}} {continue}
		if {[incr pos] > 10} {break}
		set dwd [dict get $dfplayer $q]
		if {[set player [dict get $dwd de]] eq {}} {set player [dict get $dwd d]}
		regsub -- { \(Tennisspielerin\)} $player {} altplayer
		if {$tempnat in {* **}} {
			append lrank "| Name$pos    [expr {$pos < 10 ? { } : {}}] = \{\{$nat|$player|$altplayer\}\}\n"
		} else {
			append lrank "| Name$pos    [expr {$pos < 10 ? { } : {}}] = $player[expr {$altplayer ne $player ? "\{\{!\}\}$altplayer" : {}}]\n"
		}
		append lrank "| Position$pos[expr {$pos < 10 ? { } : {}}] = $rank\n"
		append lrank "| Änderung$pos[expr {$pos < 10 ? { } : {}}] = [expr $prank - $rank]\n"
	}
	puts $lrank
	set nctemp [string map [list $olrank $lrank] $ctemp]
	if {$nctemp ne $ctemp} {
		gets stdin
		puts [edit Vorlage:$temp {Bot: Aktualisierung} $nctemp / minor]
	}
}












exit





#puts [regexp -all -inline -- {<result>(.*?)</result>} $html]

#puts [split $html \n]

#exit

#set lfplayer [wdcat enwiki list {Female tennis players by nationality} 0]

set urlWTAs http://wtafiles.wtatennis.com/pdf/rankings/Singles_Numeric.pdf
#catch {exec wget -O tennisWTAs.pdf -- $urlWTAs}
#exec pdftotext -raw tennisWTAs.pdf
read_file tennisWTAs.txt tennisWTAs

set stennisWTAs [split $tennisWTAs \n]
#puts $stennisWTAs
set rankoffset [lindex $stennisWTAs end 0]

foreach line $stennisWTAs {
	lassign {} rank prank nat player
#	puts $line
#	regexp -- {[A-Z]{3}} [lreverse $line] nat
#	set line [lreverse [regsub -- {([A-Z]{3})} [lreverse $line] [string tolower \\1]]]
#	puts $nat
	set rank [lindex $line 0]
	if {[string first ( [lindex $line 1]] > -1} {
		set prank [string trim [lindex $line 1] ()]
	} else {
		set prank $rankoffset
	}
	set line [lreverse [regsub -- {([A-Z]{3})} [lreverse $line] |\\1]]
	regexp -- {\|([A-Z]{3})} $line -- nat
#	if {$nat ne {BUL}} {continue}
	if {!(
				[string is integer $rank]
			&& [string is upper $nat]
			&& [string length $nat] == 3)
		} {continue}
	regexp -- {([A-Z].*?) \|} $line -- player
set pplayer "\{$player\} "
	set player [split $player ,]
	set player "[string trim [lindex $player 1]] [string trim [lindex $player 0]]"
	lassign {} sr aplayer resplayer
	set sr [lsearch -all -inline -regexp [string toupper $lfplayer] $player]
#puts [string toupper [sql -> [lindex [redir 0 $player] 1]]]
	if [empty sr] {
		foreach name $player {
#			puts $player
#			set player {}
			append aplayer " [string tolower $name 1 end]"
		}
		set player [string trim $aplayer]
#puts $player
#		puts [string trim $player]
		set sr [lsearch -all -inline -regexp [string toupper $lfplayer] [string toupper [sql -> [lindex [redir 0 $player] 1]]]]
	}
	if [empty sr] {
		set sr "ohne sr"
	lappend lpplayer $pplayer
	} else {
		set sr [join $sr]
		dict with sr {
			if ![empty DE] {
				set resplayer $DE
			} elseif ![empty EN] {
				set resplayer $EN
			} else {
				set resplayer $D
			}
			append pplayer $ITEM ; lappend lpplayer $pplayer
		}
	}
	lassign {} aplayer
	if ![empty resplayer] {
		foreach name $resplayer {
			append aplayer " [string tolower $name 1 end]"
		}
		if {[string first - $aplayer] > -1 && $nat ni {KOR TPE}} {
puts $aplayer
			set minindex [regexp -all -indices -- {-} $aplayer]
puts $minindex
		}
		set resplayer [string trim $aplayer]
	} else {
		set resplayer $player
	}
	puts $rank:$prank:$nat:$player:$resplayer
}

#puts [string toupper $lfplayer]
#if {[string first ß $lfplayer] > -1} {puts 1}
#puts $testplayer

puts [edit user:Doc_Taxon/Test4 {} [join $lpplayer \n]]
exit

puts [redir 0 {Karolina Pliskova}]
puts [redir 0 {Karolína Plíšková}]


foreach player $testplayer {
	lassign {} sr
#	puts \n$player
	set sr [lsearch -all -inline -regexp [string toupper $lfplayer] $player]
puts [string toupper [sql -> [lindex [redir 0 $player] 1]]]
	if [empty sr] {
		foreach name $player {
#			puts $player
#			set player {}
			append aplayer " [string tolower $name 1 end]"
		}
		set player [string trim $aplayer]
puts $player
		set aplayer {}
		puts [string trim $player]
		set sr [lsearch -all -inline -regexp [string toupper $lfplayer] [string toupper [sql -> [lindex [redir 0 $player] 1]]]]
	} else {puts $sr}
	if [empty sr] {incr j} else {puts $sr}
}

puts $j
