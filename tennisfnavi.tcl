#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang meta ; source langwiki.tcl ; #set token [login $wiki]

meta_lang

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
	lassign {} de en d item
	foreach {key val --} [lrange $sres 1 end-1] {
		if {[string first 'item' 		$key] > -1} {set item	[lindex [split [lindex [split $val <>] 2] /] end]}
		if {[string first dewiki 		$key] > -1} {set de		[lindex [split $val <>] 2]}
		if {[string first enwiki 		$key] > -1} {set en		[lindex [split $val <>] 2]}
		if {[string first itemLabel	$key] > -1} {set d		[lindex [split $val <>] 2]}
	}
	lappend dfplayer $item [list de $de en $en d $d]
}

catch {exec wget -O tennisWTAs.pdf -- http://wtafiles.wtatennis.com/pdf/rankings/Singles_Numeric.pdf}
exec pdftotext -raw tennisWTAs.pdf
read_file tennisWTAs.txt tennisWTAs

catch {exec wget -O tennisWTAd.pdf -- http://wtafiles.wtatennis.com/pdf/rankings/Doubles_Numeric.pdf}
exec pdftotext -raw tennisWTAd.pdf
read_file tennisWTAd.txt tennisWTAd

read_file tennisWTA.db tennisWTA
set ltennisWTA [join [split $tennisWTA \n]]

set stennisWTAs [split $tennisWTAs \n]
set rankdates [clock format [clock scan [lindex $stennisWTAs 0] -format {%e %B %Y} -locale en_GB] -format %Y-%m-%d]
set rankoffsets [lindex $stennisWTAs end 0]

set stennisWTAd [split $tennisWTAd \n]
set rankdated [clock format [clock scan [lindex $stennisWTAd 0] -format {%e %B %Y} -locale en_GB] -format %Y-%m-%d]
set rankoffsetd [lindex $stennisWTAd end 0]

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

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
