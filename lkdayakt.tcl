#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

#if {[utc -> seconds {} %H {}] ni {00 03 06 09 12 15 18 21}} {exit}

#proc blcheck line {
#	return [regexp -- {\( ?-LA|-LA ?\)|\( ?BKL|BKL ?\)|\( ?bleiben|bleiben ?\)|\( ?bleibt|bleibt ?\)|\( ?Bleibt|Bleibt ?\)|BNR|\( ?entfernt|entfernt ?\)|\( ?Entfernt|Entfernt ?\)|\( ?erl.|erl. ?\)|\( ?Erl.|Erl. ?\)|\( ?erledigt|erledigt ?\)|\( ?Erledigt|Erledigt ?\)|\( ?gelöscht|gelöscht ?\)|\( ?Gelöscht|Gelöscht ?\)|\( ?geloescht|geloescht ?\)|\( ?Geloescht|Geloescht ?\)|\( ?gel.|gel. ?\)|geSLAt|\( ?LA entfernt|LA entfernt ?\)|\( ?LAE|LAE ?\)|\( ?LAZ|LAZ ?\)|\( ?SLA|SLA ?\)|\( ?URV|URV ?\)|\( ?Wiedergänger|Wiedergänger ?\)|\( ?WL|WL ?\)|\( ?zurückgez|\( ?Zurückgez} $line]
#}

lassign {} worklist1 worklist2
set lk Wikipedia:Löschkandidaten
set lkcontents [contents t $lk x]
set kk {Wikipedia:WikiProjekt Kategorien}
set kkcontents [contents t $kk x]
regexp -- {<!--MB-QSWORKLIST-TODO-->\n(.*?)\n<!--MB-QSWORKLIST-TODO-->} $lkcontents -- worklist1
foreach lkline [split $worklist1 \n] {
	lappend lline $lkline $lk[join [dict values [regexp -inline -- {\[\[(.*?)\|} $lkline]]]
}
regexp -- {<!--MB-QSWORKLIST-TODO-->\n(.*?)\n<!--MB-QSWORKLIST-TODO-->} $kkcontents -- worklist2
foreach kkline [set sworklist2 [split $worklist2 \n]] {
	if {[string first * $kkline] > -1} {
		lappend lline $kkline $kk[join [dict values [regexp -inline -- {\[\[(.*?)\|} $kkline]]]
	}
}
set nworklist1 {}
foreach {kline dpage} $lline {
	lassign {0 0 0 0 0 0 0 {} {}} t kla bla mla vla lla la akt1 akt2
#	set ldpage $lk[join [dict values [regexp -inline -- {\[\[(.*?)\|} $lkline]]]
	contents t $dpage x
	set lsect [get [post $wiki {*}$parse / page $dpage / prop sections] parse sections]
	set ulevel {}
	foreach sect $lsect {
		dict with sect {
			if {$level == 1} {
				incr t
			} else {
				switch $t {
					1	{
							if {$level == 3} {
								if {![blcheck $ulevel] && ![blcheck $line] && [string first {KEIN LA} [string toupper $line]] == -1} {incr kla}
							} else {
								if {![blcheck $line] && [string first {KEIN LA} [string toupper $line]] == -1} {incr kla}
							}
						}
					2	{
							if {$level == 3} {
								if {![blcheck $ulevel] && ![blcheck $line]} {incr bla}
							} else {
								if ![blcheck $line] {incr bla}
							}
						}
					3	{
							if {$level == 3} {
								if {![blcheck $ulevel] && ![blcheck $line]} {incr mla}
							} else {
								if ![blcheck $line] {incr mla}
							}
						}
					4	{
							if {$level == 3} {
								if {![blcheck $ulevel] && ![blcheck $line]} {incr vla}
							} else {
								if ![blcheck $line] {incr vla}
							}
						}
					5	{
							if {$level == 3} {
								if {![blcheck $ulevel] && ![blcheck $line]} {incr lla}
							} else {
								if ![blcheck $line] {incr lla}
							}
						}
					6	{
							if {$level == 3} {
								if {![blcheck $ulevel] && ![blcheck $line]} {incr la}
							} else {
								if ![blcheck $line] {incr la}
							}
						}
				}
#				puts $t:$level:$index:$line
				if {$level == 2} {set ulevel $line}
			}
		}
	}
#	puts $ldpage
#	puts "kla $kla bla $bla mla $mla vla $vla lla $lla la $la\n"
	if $la {lappend akt1 "$la Löschantr[expr {$la == 1 ? "ag" : "äge"}]"}
	if $lla {lappend akt1 "$lla Listen-LA"}
	if $vla {lappend akt1 "$vla Vorlagen-LA"}
	if $mla {lappend akt1 "$mla Metaseiten-LA"}
	if $bla {lappend akt1 "$bla Benutzerseiten-LA"}
	if $kla {set akt2 "$kla Kategoriediskussion[expr {$kla == 1 ? "" : "en"}]"}
	set akt1total [expr $la + $lla + $vla + $mla + $bla]
	incr total [expr $akt1total + $kla]
	regexp -- {(.*?\]\])} $kline -- nkline
	if {$akt1total > 0} {
		set nakt "<small> (noch [join $akt1 {, }])</small>"
		lappend nworklist1 [append nkline $nakt]
	} elseif {[string first \{\{Löschkandidaten|erl=\}\} $contents] > -1 && !$kla} {
		set nakt "<small> (keine offene Diskussion mehr, aber LD-Seite noch nicht als erledigt markiert)</small>"
		lappend nworklist1 [append nkline $nakt]
	}
	regexp -- {(.*?\]\])} $kline -- nkline
	if {$kla && $kline in $sworklist2} {
		set nakt "<small> (noch $akt2)</small>"
		lappend nworklist2 [string map [list \[\[/ \[\[$kk/] [append nkline $nakt]]
	}
}
if {[contents t $lk x] eq $lkcontents && [contents t $kk x] eq $kkcontents} {
	regexp -- {<!--MB-QSWORKLIST-TODO2-->\n(.*?)\n<!--MB-QSWORKLIST-TODO2-->} $lkcontents -- worklist2
# momentan in Arbeit / ab hier
if [empty nworklist1] {puts 1 ; set nworklist1 {{''– keine abzuarbeitenden Löschdiskussionen offen –''}}}
puts $nworklist1
	set nlkcontents [string map [list $worklist1 [join $nworklist1 \n] $worklist2 [join $nworklist2 \n]] $lkcontents]
#	set nlkcontents [regsub -- (?q)$worklist1 $lkcontents [join $nworklist1 \n]]
#	set nlkcontents [regsub -- (?q)$worklist2 $lkcontents [join $nworklist2 \n]]
puts $nlkcontents
# momentan in Arbeit / bis hier
	puts [edit $lk "Bot: Aktualisiere LK-Übersicht ($total offene Diskussionen)" $nlkcontents / minor]
} else {
	puts {Error: Edit Conflict}
#	exec ./lkdayakt.tcl
}

set tabpage Navigationsleiste_Redundanz/Tabelle
set oconts [conts t Vorlage:$tabpage x]
set nconts [string map {{{{0}}} 0} $oconts]
set db [get_db dewiki]
mysqlreceive $db "
	select pl_title
	from pagelinks join page on page_id = pl_from
	where page_title = '$tabpage' and page_namespace = 10 and pl_from_namespace = 10 and pl_namespace = 4
;" plt {
	lassign {0 0 0} cwhile csect cerl
	while 1 {
		incr cwhile
		if ![catch {
			foreach section [get [post $wiki {*}$format / action parse / page Wikipedia:$plt / prop sections] parse sections] {
				dict with section {
					if {$level >= 3} {
						if {$level == 3} {incr csect}
						if {[string first Vorlage:Erledigt\} [get [post $wiki {*}$format / action parse / page Wikipedia:$plt / prop templates / section $index] parse templates]] > -1} {incr cerl}
					}
				}
			}
		}] {break}
		if {$cwhile == 10} {puts ----Abbruch---- ; exit}
	}
	set c [expr $csect - $cerl]
	if {$c < 10} {set c "\{\{0\}\}$c"}
	set month [lindex [split $plt /_] 1]
	set plt [sql -> $plt]
	regsub -- "$plt\\\|$month.*?\\\}" $nconts "$plt|$month\]\]\\\&nbsp;($c) \}" nconts
}
mysqlclose $db
if {$nconts ne $oconts} {
	puts [edit Vorlage:$tabpage {Bot: Aktualisierung ausstehender Redundanzen} $nconts / minor]
}
