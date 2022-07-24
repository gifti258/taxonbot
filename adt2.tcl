#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#catch {if {[exec pgrep -cxu taxonbot adt2.tcl] > 3} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

proc m2q ym {
	set y [utc ^ $ym %d.%m.%Y %Y {}]
	set m [utc ^ $ym %d.%m.%Y %N {}]
			if	{$m in { 1  2  3}} {
		return $y/Q1
	} elseif	{$m in { 4  5  6}} {
		return $y/Q2
	} elseif	{$m in { 7  8  9}} {
		return $y/Q3
	} elseif	{$m in {10 11 12}} {
		return $y/Q4
	}
}

proc vdata {vpage index} {
	set lemmaindex [lsearch -glob [set sconts [split [conts t $vpage $index] |=]] *LEMMA*]
	foreach {key diff} {vdate - vpage +} {
		lappend vdata $key [string trim [lindex $sconts [expr $lemmaindex $diff 1]]]
	}
	return $vdata
}

proc chronpage0 tyear {
	return [format {<noinclude>
{{Navigationsleiste Chronologien der Artikel des Tages}}
</noinclude>
<div style="border:1px solid #666666; background:#f9f9f9; padding:0.5em 0.6em;">
__NOTOC__

=== Januar %s ===
</div>
<br />
<div style="border:1px solid #666666; background:#f9f9f9; padding:0.5em 0.6em;">
Anmerkung: Der Zusatz „erneut“ bedeutet, dass der Artikel vorher schon einmal Artikel des Tages war.
</div>
[[Kategorie:Wikipedia:Hauptseite/Artikel des Tages|Chronologie %s]]
<noinclude>
<!--
-->
</noinclude>
} $tyear $tyear
	]
}

set i -1
set chrondate			[utc -> seconds {} {%d.%m.%Y} {}]
set chrondate60		[utc -> seconds {} {%d.%m.%Y} {61 days}]
set adtdate_scan		[clock scan [set adtdate $chrondate] 	-format %d.%m.%Y]
set adtdate60_scan	[clock scan [set adtdate $chrondate60] -format %d.%m.%Y]
puts $adtdate_scan
puts $adtdate60_scan
set tdate				[utc -> seconds {} {%e. %B %Y} {}]
set tday					[utc -> seconds {} %e {}]
set tmonth				[utc -> seconds {} %B {}]
set tyear				[utc -> seconds {} %Y {}]
set nyear				[utc -> seconds {} %Y {90 days}]
set clox					[utc -> seconds {} %H:%M {}]
set adtday				"Wikipedia:Hauptseite/Artikel des Tages/[utc -> seconds {} %A {}]"
set adtpage0			"Wikipedia Diskussion:Hauptseite/Artikel des Tages"
set adtpage				$adtpage0/Vorschläge

set yearadtpage [dict values [regexp -all -inline -- {\[\[../(.*?)\|} [conts t $adtpage0/Index x]]]
foreach year $yearadtpage {
	lappend dadtpage $adtpage0/$year [list oconts [set conts [conts t $adtpage0/$year x]] nconts $conts]
}
#while {[incr i] <= 5} {
#puts $i
#	set yearadtpage $adtpage0/[expr $nyear + $i][expr {$i == 5 ? {–...} : {}}]
#puts $yearadtpage
#	lappend dadtpage $yearadtpage [list oconts [set conts [conts t $yearadtpage x]] nconts $conts]
#}
set archpage	$adtpage0/Archiv/Vorschläge
set tdaypage	"Wikipedia:Hauptseite/Artikel des Tages/Heute"
set chronpage	"Wikipedia:Hauptseite/Artikel des Tages/Chronologie $tyear"
set adt			[vdata $adtday 0]

#foreach page [list $adtpage $zadtpage] {
#	set olsect [get [post $wiki {*}$parse / page $page / prop sections] parse sections]
#	foreach sect $olsect {
#		dict with sect {
#			if {$level > 1} {
#				set vdata [vdata $fromtitle $index]
#				lappend altlsect [list {*}$vdata {*}$sect]
#			}
#		}
#	}
#}

foreach {page --} $dadtpage {
	set olsect [get [post $wiki {*}$parse / page $page / prop sections] parse sections]
	foreach sect $olsect {
		dict with sect {
			if {$level > 1 && ![empty index]} {
				set vdata [vdata $fromtitle $index]
#puts $vdata
				lappend lsect [list {*}$vdata {*}$sect]
				try {
					if {[sql -> $fromtitle] eq "$adtpage0/$nyear" && [clock scan [dict get $vdata vdate] -format %d.%m.%Y] <= $adtdate60_scan} {
						lappend lsect60 [list {*}$vdata {*}$sect]
					}
				} on error {} {
					lassign {} lsect60 conts60
				}
			}
		}
	}
}

if {$argv eq {archive/außer Betrieb}} {
	puts ..archive..
	set adtdiskconts [conts t [set adtdisk Diskussion:[dict get $adt vpage]] x]
	set nadtdiskconts $adtdiskconts
	if {[matchtemplate $adtdisk {Vorlage:AdT-Vorschlag Hinweis}] && [matchtemplate $adtdisk {Vorlage:War AdT}]} {
		regexp -nocase -- {\{\{AdT-Vorschlag.*?Datum=(.*?)\|.*?\}\}} $adtdiskconts vadt vdadt
		regexp -nocase -- {\{\{War AdT.*?\}\}} $adtdiskconts wadt
		if {[string first $tdate $wadt] == -1} {
			set madt [regexp -all -- {\=} $wadt]
			regsub -nocase -- {(\{\{War AdT.*?)(\}\})} $adtdiskconts \\1|[incr madt]=$tdate\\2 nadtdiskconts
		}
		if {[string trimleft [string trim $vdadt] 0] eq $tdate} {
			set nadtdiskconts [string trim [string map [list $vadt {}] $nadtdiskconts]]
		}
		set typus 1
	} elseif [matchtemplate $adtdisk {Vorlage:AdT-Vorschlag Hinweis}] {
		regexp -nocase -- {\{\{AdT-Vorschlag.*?Datum=(.*?)\|.*?\}\}} $adtdiskconts vadt vdadt
		if {[string trimleft [string trim $vdadt] 0] eq $tdate} {
			set nadtdiskconts [string trim [string map [list $vadt "\{\{War AdT|1=$tdate\}\}"] $adtdiskconts]]
		} else {
			set nadtdiskconts [string trim [string map [list $vadt "$vadt\n\{\{War AdT|1=$tdate\}\}"] $adtdiskconts]]
		}
		set typus 2
	} elseif ![matchtemplate $adtdisk {Vorlage:War AdT}] {
		set nadtdiskconts [string trim "\{\{War AdT|1=$tdate\}\}\n$adtdiskconts"]
		set typus 3
	} else {
		set typus 4
	}
	if {$typus != 4} {
		puts $typus:[edit $adtdisk "Bot: Artikel des Tages $tdate" $nadtdiskconts / minor]
	} else {
		puts $typus:nochange
	}
	dict with adt {
		puts [edit $tdaypage "Bot: heutiger AdT: \[\[$vpage\]\]" "#WEITERLEITUNG \[\[$vpage\]\]" / minor]
		if [missing $chronpage] {
			puts [edit $chronpage {Bot: neue AdT-Chronologie} [chronpage0 $tyear]]
		}
		set chronconts [conts t $chronpage x]
		set chronsect1 [conts t $chronpage 1]
		set chronlinepart "\[\[$vpage\]\][expr {$typus == 1 ? { (erneut)} : {}}]"
		set chronline "* $chrondate $chronlinepart"
		if {$chrondate ni $chronsect1} {
			if {$tday == 1} {
				set nchronsect1 "=== $tmonth $tyear ===\n$chronline\n\n$chronsect1"
			} else {
				set chrontopic "=== $tmonth $tyear ==="
				set nchronsect1 [
					string map [list $chrontopic $chrontopic\n$chronline] $chronsect1
				]
			}
			set nchronconts [string map [list $chronsect1 $nchronsect1] $chronconts]
			puts [edit $chronpage "Bot: heutiger AdT: $chronlinepart" $nchronconts / minor]
		}
	}
	foreach sect $lsect {
		dict with sect {
			lappend lv $vpage
			lappend lvdisk Diskussion:$vpage
		}
	}
	while 1 {if ![catch {
		set lvhtemp [template2 {Vorlage:AdT-Vorschlag Hinweis} 1]
	}] {break}}
	foreach vhtemp $lvhtemp {
		if {$vhtemp ni $lvdisk} {
			set nvdiskconts [set vdiskconts [conts t $vhtemp x]]
			regexp -nocase -- {\{\{AdT-Vorschlag Hinweis.*?\}\}} $vdiskconts rxtemp
			set nvdiskconts [string map [list $rxtemp\n {} "$rxtemp \n" {} $rxtemp {}] $nvdiskconts]
			if {$nvdiskconts ne $vdiskconts} {
				puts [edit $vhtemp "Bot: Löschung des obsoleten AdT-Vorschlags" $nvdiskconts / minor]
			}
		}
	}
	set larchsect {}
	foreach sect $lsect {
 		dict with sect {
			catch {
				if {[clock scan $vdate -format %d.%m.%Y] < $adtdate_scan} {
					if {$fromtitle eq [sql <- $adtpage]} {
						lappend larchsect [m2q $vdate] [conts t $fromtitle $index]
					}
				}
			}
		}
	}
	if ![empty larchsect] {
		set newadtpage [set oldadtpage [conts t $adtpage x]]
		set newadt2page [set oldadt2page [conts t $adtpage0/$nyear x]]
		foreach sect $lsect60 {
			dict with sect {
				lappend conts60 [set conts0 [conts t $fromtitle $index]]
				set newadt2page [string map [list $conts0\n\n {} \n\n\n \n\n] $newadt2page]
			}
		}
		set newadtpage [string map [list [set c1 [conts t $adtpage 1]] $c1\n\n[join $conts60 \n\n]] $newadtpage]
		foreach {q archsect} $larchsect {
			set newadtpage [string map [list $archsect\n\n {} \n\n\n \n\n] $newadtpage]
			set erltx {:<small>Archivierung dieses Abschnittes wurde gewünscht von: \1</small>}
			regsub -nocase -all -line -- {\{\{erledigt\|(?:1=)?(.*?)\}\}} $archsect \n$erltx archsect
			dict lappend newaadtpage $q $archsect
			lappend lq $q
		}
		if {[conts t $adtpage x] eq $oldadtpage} {
			foreach q [lsort -unique $lq] {
				if ![missing $archpage/$q] {
					set archconts [string map [list \n\n\n \n\n] [conts t $archpage/$q x]\n\n[join [dict get $newaadtpage $q] \n\n]]
				} else {
					set archconts [string map [list \n\n\n \n\n] "\{\{Archiv\}\}\n\n[join [dict get $newaadtpage $q] \n\n]"]
				}
				lappend cq "[expr {[set c [llength [lsearch -all -exact $lq $q]]] == 1 ? "$c Abschnitt" : "$c Abschnitten"}] nach \[\[$archpage/$q\]\]"
				set acq "Bot: Archivierung von $c Abschnitt[expr {$c > 1 ? {en} : {}}] von \[\[$adtpage\]\]"
				puts [edit $archpage/$q $acq $archconts]
				catch {
					set links [get [post $wiki {*}$parse / title $archpage/$q / text [dict get $newaadtpage $q] / prop links / contentmodel wikitext] parse links]
					foreach line $links {
						dict with line {
							if !$ns {
								lappend lpt Diskussion:${*}
							}
						}
					}
					puts [get [post $wiki {*}$format / action purge / titles [join $lpt |] / forcerecursivelinkupdate 1]]
				}
			}
			puts [edit $adtpage "Bot: Archivierung von [join $cq {, }] + Übertragung neuer Vorschläge von \[\[$adtpage0/$nyear\]\]" [string map [list \n\n\n \n\n] $newadtpage]]
			if {$newadt2page ne $oldadt2page} {
				puts [edit $adtpage0/$nyear "Bot: Übertragung neuer Vorschläge nach \[\[$adtpage\]\]" [string map [list \n\n\n \n\n] $newadt2page]]
			}
		} else {
			puts {Edit conflict}
			exec ./adt2.tcl archive >> adt2.out 2>@1 &
		}
	}
	set lang test ; source langwiki.tcl ; #set token [login $wiki]
	puts [edid 63277 {Log: AdT} {} / appendtext "\n* '''[utc <- seconds {} %Y-%m-%dT%TZ {}] AdT-Archiv: Task finished!'''"]
}

set lang dea ; source langwiki.tcl ; #set token [login $wiki]
unset lsect
set lvpage {}
foreach {page --} $dadtpage {
	set olsect [get [post $wiki {*}$parse / page $page / prop sections] parse sections]
	foreach sect $olsect {
		dict with sect {
			if {$level > 1} {
				set vdata [vdata $fromtitle $index]
				if {[set vpage [dict get $vdata vpage]] ni $lvpage} {
					lappend lvpage $vpage
				} else {
					continue
				}
				lappend lsect [list {*}$vdata {*}$sect]
			}
		}
	}
}

if {$argv eq {notice}} {
	if {[string first 00:0 $clox] > -1} {exec ./adt3.tcl >> adt3.out 2>@1 &}
	puts ..notice..
	set lkand [dcat list {Wikipedia:Bewertete Seite} 0]
	foreach sect $lsect {
#puts $sect
		dict with sect {
			if {$vdate eq {TT.MM.JJJJ}} {continue}
			if {[string first \{\{AdT-Vorschlag [conts t $fromtitle $index]] == -1} {continue ; #AdT-Vorschlag fehlt}
			if {[empty vdate] || [string first $vdate $line] == -1} {puts "DATUM wurde nicht im Topic gefunden:\n$sect" ; continue}
			if {[empty vpage] || [string first $vpage $line] == -1} {puts "LEMMA wurde nicht im Topic gefunden:\n$sect" ; continue}
			set adtdisk Diskussion:$vpage
			if {[string first <s> $line] == -1 && $vpage in $lkand && [clock scan $vdate -format %d.%m.%Y] > $adtdate_scan} {
				if [catch {
					set ptempl [page [post $wiki {*}$query / prop templates / titles $adtdisk / tllimit 5000]]
					if {{templates} in [dict keys $ptempl]} {
						set ltempl [join [dict get $ptempl templates]]
					} else {
						set ltempl {}
					}
				}] {puts "$adtdisk: Fehler bei der Vorlagenauswertung" ; continue}
				set vdate_f [string trim [utc ^ $vdate %d.%m.%Y {%e. %B %Y} {}]]
				set vdate_y [string trim [utc ^ $vdate %d.%m.%Y %Y {}]]
				set notice "\{\{AdT-Vorschlag Hinweis|Datum=$vdate_f|Abschnitt=$line[expr {[sql <- $adtpage] ne $fromtitle ? "|Zukunft=$vdate_y" : {}}]\}\}"
				if {{Vorlage:AdT-Vorschlag Hinweis} ni $ltempl} {
					set summary "Bot: Dieser Artikel wurde für den $vdate_f zum Artikel des Tages vorgeschlagen, siehe \[\[[sql -> $fromtitle#$line]|Diskussion\]\]."
					puts [edit $adtdisk $summary {} / prependtext $notice\n / minor]
				} elseif {{Vorlage:AdT-Vorschlag Hinweis} in $ltempl} {
					set Zukunft {}
					set conts0 [conts t $adtdisk 0]
					varassign [conts t $adtdisk x] {oconts nconts}
					regexp -line -- {\{\{AdT-Vorschlag Hinweis.*\}\}} $conts0 rex
					set nconts [string map [list $rex $notice] $nconts]
					if {$nconts ne $oconts} {
#puts $adtdisk:[lindex [split $nconts \n] 0]
#set adtdisk user:TaxonBota/Test
						puts [edit $adtdisk {Bot: Vorschlag zum Artikel des Tages aktualisiert} $nconts / minor]
					}
				}
			}
		}
	}
	exec ./adt2.tcl veto >> adt2.out 2>@1 &
}

if {$argv eq {veto}} {
	if {[string first 00:0 $clox] > -1} {exec ./adt3.tcl >> adt3.out 2>@1 &}
	puts \n..veto..
	set db [get_db dewiki]
	mysqlreceive $db {
		select pl_title
		from pagelinks join page on page_id = pl_from
		where page_namespace = 5 and page_title = 'Hauptseite/Artikel_des_Tages/Verwaltung/Lesenswerte_Artikel' and pl_from_namespace = 5 and pl_namespace = 0
	;} plt {
		lappend lplt [sql -> $plt]
	}
	mysqlclose $db
	foreach sect $lsect {
		dict with sect {
			if {$vdate eq {TT.MM.JJJJ}} {continue}
			if {[string first \{\{AdT-Vorschlag [conts t $fromtitle $index]] == -1} {continue ; #AdT-Vorschlag fehlt}
			if {[empty vdate] || [string first $vdate $line] == -1} {puts "DATUM wurde nicht im Topic gefunden:\n$sect" ; continue}
			if {[empty vpage] || [string first $vpage $line] == -1} {puts "LEMMA wurde nicht im Topic gefunden:\n$sect" ; continue}
			if {[string toupper $vpage 0 0] in $lplt} {
				set ncontssect [set ocontssect [conts t $fromtitle $index]]
				if {[string first "\{\{Ist AdT-Veto" $ocontssect] == -1 && [string first "\{\{ist AdT-Veto" $ocontssect] == -1} {
					set ncontssect [string map [
						list ==\n "==\n\{\{Ist AdT-Veto|1=TaxonBota\}\}\n"
					] $ncontssect]
					dict with dadtpage [sql -> $fromtitle] {
						set nconts [string map [list $ocontssect $ncontssect] $nconts]
					}
				}
			}
		}
	}
	foreach {adtpage conts} $dadtpage {
		dict with conts {
			if {$oconts eq [conts t $adtpage x] && $nconts ne $oconts} {
				puts [edit $adtpage {Bot:Hauptautorenveto eingetragen} $nconts / minor]
			}
		}
	}
}

exec ./adt3.tcl >> adt3.out 2>@1 &
