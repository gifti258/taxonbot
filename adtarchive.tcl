#!/usr/bin/tclsh8.7

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set adtpage0 {Wikipedia Diskussion:Hauptseite/Artikel des Tages}
set ladtpage [dict values [regexp -all -inline -- {\[\[../(.*?)\|} [
	conts t $adtpage0/Index x
]]]
set dsect {}
set wday		"Wikipedia:Hauptseite/Artikel des Tages/[utc -> seconds {} %A {}]"
set tday		[utc -> seconds {} %e {}]
set tmonth	[utc -> seconds {} %B {}]
set tyear	[utc -> seconds {} %Y {}]
set today	[utc -> seconds {} %d.%m.%Y {}]
set todayB	[utc -> seconds {} {%e. %B %Y} {}]
set today50	[utc -> seconds {} %d.%m.%Y {50 days}]
set todayM	[utc -> seconds {} {%B %Y} {}]
set chron	"Wikipedia:Hauptseite/Artikel des Tages/Chronologie $tyear"
set lchron	"Wikipedia:Hauptseite/Artikel des Tages/Chronologie [expr $tyear - 1]"

proc chronpage0 adtline {
	global todayM tyear
	return [format {<noinclude>
{{Navigationsleiste Chronologien der Artikel des Tages}}
</noinclude>
<div style="border:1px solid #666666; background:#f9f9f9; padding:0.5em 0.6em;">
__NOTOC__
=== %s ===%s

</div>
<br />
<div style="border:1px solid #666666; background:#f9f9f9; padding:0.5em 0.6em;">
Anmerkung: Der Zusatz „erneut“ bedeutet, dass der Artikel vorher schon einmal Artikel des Tages war.
</div>
[[Kategorie:Wikipedia:Hauptseite/Artikel des Tages|Chronologie %s]]
<noinclude>
<!--
-->
</noinclude>} $todayM $adtline $tyear]
}

set conts [conts t $wday x]
set ltempl [regexp -all -inline -- {\{\{.*?\}\}} [
	string map [list \{\{\{ {} \}\}\} {}] $conts
]]
foreach templ $ltempl {
puts $templ
	if {
				[string first "\{\{Wikipedia:Hauptseite/Artikel des Tages"	$templ] >	-1
			&& [string first "\{\{Wikipedia:Hauptseite/Artikel des Tages/"	$templ] ==	-1
		} {
		set ptempl [parse_templ $templ]
		set adtpage [dict get $ptempl LEMMA]
		set adttpage Diskussion:$adtpage
		set adttconts [conts t $adttpage 0]
		set vtempl [matchtemplate $adttpage {Vorlage:AdT-Vorschlag Hinweis}]
		set wtempl [matchtemplate $adttpage {Vorlage:War AdT}]
		if {$vtempl && !$wtempl} {
			regsub -- {\{\{AdT-Vorschlag Hinweis.*?\}\}} $adttconts "\{\{War AdT|1=$todayB\}\}" adttconts
#			set conts1 [conts t $chron 1]
#puts $conts1
			if {$tday == 1} {
				set adtline "\n* $today \[\[$adtpage\]\]"
				if {$tmonth eq {Januar}} {
					set chrontemp {Vorlage:Navigationsleiste Chronologien der Artikel des Tages}
					set chrontempconts [conts t $chrontemp x]
					set chrontempconts [string map [list \n\}\} "&nbsp;&#124;\n\[\[$chron|$tyear\]\]\n\}\}"] [conts t $chrontemp x]]
					set ctzuq "Bot: Erweiterung um die \[\[$chron|Chronologie $tyear\]\]"
					puts [edit $chrontemp $ctzuq $chrontempconts / minor]
					set conts1 [chronpage0 $adtline]
					set czuq "Bot: heutiger Artikel des Tages: \[\[$adtpage\]\]"
					puts [edit $chron $czuq $conts1]
				} else {
					set conts1 [conts t $chron 1]
					set conts1 "=== $todayM ===$adtline\n\n$conts1"
					set czuq "Bot: heutiger Artikel des Tages: \[\[$adtpage\]\]"
					puts [edit $chron $czuq $conts1 / section 1 / minor]
				}
			} else {
				set conts1 [conts t $chron 1]
				regsub -- {\*} $conts1 "* $today \[\[$adtpage\]\]\n*" conts1
				set czuq "Bot: heutiger Artikel des Tages: \[\[$adtpage\]\]"
				puts [edit $chron $czuq $conts1 / section 1 / minor]
			}
		} else {
			regsub -line -- {\{\{AdT-Vorschlag Hinweis.*} $adttconts {} adttconts
			regexp -line -nocase -- {\{\{War AdT.*} $adttconts wtempl
			set pwtempl [parse_templ $wtempl]
			foreach {key val} $pwtempl {
				if {[incr ikey] > 1} {
					append bwtempl |$key=$val
				}
			}
			set bwtempl "\{\{War AdT$bwtempl|$ikey=$todayB\}\}"
			set adttconts [string map [list $wtempl $bwtempl] $adttconts]
#			set conts1 [conts t $chron 1]
			if {$tday == 1} {
				set adtline "\n* $today \[\[$adtpage\]\] (erneut)"
				if {$tmonth eq {Januar}} {
					set chrontemp {Vorlage:Navigationsleiste Chronologien der Artikel des Tages}
					set chrontempconts [conts t $chrontemp x]
					set chrontempconts [string map [list \n\}\} "&nbsp;&#124;\n\[\[$chron|$tyear\]\]\n\}\}"] [conts t $chrontemp x]]
					set ctzuq "Bot: Erweiterung um die \[\[$chron|Chronologie $tyear\]\]"
					puts [edit $chrontemp $ctzuq $chrontempconts / minor]
					set conts1 [chronpage0 $adtline]
					set czuq "Bot: heutiger Artikel des Tages: \[\[$adtpage\]\] (erneut)"
					puts [edit $chron $czuq $conts1]
				} else {
					set conts1 [conts t $chron 1]
					set conts1 "=== $todayM ===$adtline\n\n$conts1"
					set czuq "Bot: heutiger Artikel des Tages: \[\[$adtpage\]\] (erneut)"
					puts [edit $chron $czuq $conts1 / section 1 / minor]
				}
			} else {
				set conts1 [conts t $chron 1]
				regsub -- {\*} $conts1 "* $today \[\[$adtpage\]\] (erneut)\n*" conts1
				set czuq "Bot: heutiger Artikel des Tages: \[\[$adtpage\]\] (erneut)"
				puts [edit $chron $czuq $conts1 / section 1 / minor]
			}
		}
		set zuq "Bot: Artikel des Tages $todayB"
		puts [edit $adttpage $zuq [string trimleft $adttconts] / section 0 / minor]
	}
}

foreach adtpage $ladtpage {
	set lsect [get [
		post $wiki {*}$parse / page $adtpage0/$adtpage / prop sections
	] parse sections]
	foreach sect $lsect {
		dict with sect {
			if {$level == 2} {
				unset -nocomplain lemmadate sectconts
				regexp -- {\d{1,2}\.\d{2}.\d{4}} $line lemmadate
				if ![exists lemmadate] {set lemmadate {}}
				set sectconts [conts t $adtpage0/$adtpage $index]
				set ltempl [regexp -all -inline -- {\{\{.*?\}\}} [
					string map [list \{\{\{ {} \}\}\} {}] $sectconts
				]]
				foreach templ $ltempl {
					if {[string first {Hauptseite/Artikel des Tages} $templ] > -1} {
						set ptempl [parse_templ $templ]
						dict with ptempl {
							if {$LEMMA ni [dict keys $dsect]} {
								dict lappend dsect $LEMMA sdate $DATUM from $fromtitle index $index line $line lemmadate $lemmadate
							}
						}
					}
				}
			}
		}
	}
}

#set lkey [dict keys $dsect]
#lassign {} larch darch larchconts lueconts conts
#set db [get_db dewiki]
#mysqlreceive $db {
#	select page_title from page join templatelinks on tl_from = page_id
#	where page_namespace = 1 and tl_from_namespace = 1 and tl_namespace = 10
#		and tl_title = 'AdT-Vorschlag_Hinweis'
#;} pt {
#	set npt [sql -> $pt]
#	lappend lpt $npt

foreach {lemma data} $dsect {
	set refc 0
	catch {
#		set sectdata [dict get $dsect $npt]
		dict with data {
			set scandate [clock scan $lemmadate -format %e.%m.%Y]
		}
		if {[clock scan $today -format %d.%m.%Y] > $scandate} {
			set refy [clock format $scandate -format %Y]
			foreach ref [list 04.$refy 07.$refy 10.$refy 01.[expr $refy + 1]] {
				if {$scandate < [clock scan 01.$ref -format %d.%m.%Y]} {
					set archtgt $refy/Q[incr refc]
					break
				} else {
					incr refc
				}
			}
			dict lappend darch larch $scandate $index [set sectconts [conts t $from $index]]
			dict lappend darch $from $sectconts
		}
	}
}
#	if {$npt ni $lkey} {
#		regsub -line {\{\{AdT-Vorschlag Hinweis.*} [conts t Diskussion:$npt 0] {} nconts
#		if {[string trim $nconts] eq {}} {set nconts {}}
#		set obszuq {Bot: Löschung des obsoleten AdT-Vorschlags}
#		puts [edit Diskussion:$npt $obszuq $nconts / section 0 / minor]
#	}
#}
#mysqlclose $db

if [exists darch] {
	dict with darch {
		set lsortlarch [lsort -integer -stride 3 -index 0 [
			lsort -integer -stride 3 -index 1 $larch
		]]
		foreach {-- -- conts} $lsortlarch {
			lappend larchconts $conts
		}
		set q "$adtpage0/Archiv/Vorschläge/$archtgt"
		set iarch [llength $larchconts]
		set zuq "Bot: Archivierung von $iarch Abschnitt[expr {$iarch > 1 ? "en" : {}}]"
		puts [edit $q $zuq {} / appendtext \n\n[join $larchconts \n\n]]
		foreach {key lval} [lrange $darch 2 end] {
			set conts [conts t $key x]
			foreach val $lval {
				set conts [string map [list \n$val\n {}] $conts]
			}
		}
		set lueconts {}
		foreach {lemma ddata} $dsect {
puts "$lemma:\n$ddata"
			dict with ddata {
				if {		[sql -> $from] eq "$adtpage0/[lindex $ladtpage 1]"
						&& [clock scan $lemmadate -format %e.%m.%Y] <= [clock scan $today50 -format %d.%m.%Y]} {
					lappend lueconts [conts t $from $index]
				}
			}
		}
		set iue [llength $lueconts]
		if ![empty lueconts] {
			set conts [string map [
				list {= Ende der Liste} "[join $lueconts \n\n]\n\n= Ende der Liste"
			] $conts]
		}
		switch $iue {
			0			{set appendue ""}
			1			{set appendue " + Übertragung $iue neuen Vorschlags"}
			default	{set appendue " + Übertragung $iue neuer Vorschläge"}
		}
		set zuq "Bot: Archivierung von $iarch Abschnitt[expr {$iarch > 1 ? "en" : {}}]$appendue"
		puts [edit $key $zuq $conts]
		set conts [conts t "$adtpage0/[lindex $ladtpage 1]" x]
		foreach ueconts $lueconts {
			set conts [string map [list \n$ueconts\n {}] $conts]
		}
		set zuq "Bot: Übertragung neuer Vorschläge nach \[\[$adtpage0/Vorschläge\]\]"
		puts [edit $adtpage0/[lindex $ladtpage 1] $zuq $conts]
	}
}

set ltc [dict values [regexp -all -line -inline -- {\[\[(.*)\]\]} [conts t $chron x]]]
set llc [dict values [regexp -all -line -inline -- {\[\[(.*)\]\]} [conts t $lchron x]]]
set lcc [join [list [lrange $ltc 0 end-1] [lrange $llc 0 end-1]]]
foreach cc [lrange $lcc 0 4] {
	lappend lpcc Diskussion:$cc
}
puts [get [post $wiki {*}$format / action purge / titles [join $lpcc |] / forcerecursivelinkupdate 1]]

exec ./adtneu.tcl >> adtneu.out 2>@1
