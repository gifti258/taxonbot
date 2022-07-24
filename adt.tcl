#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

exit

set editafter 1
catch {if {[exec pgrep -cxu taxonbot adt.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set ydate						[utc -> seconds {} %d.%m.%Y {-1 day}]
set ydate_scan	[clock scan $ydate -format %d.%m.%Y]
set adtdate						[utc -> seconds {} %d.%m.%Y {}]
set yy							[utc -> seconds {} %Y {-1 day}]
set ym		[string trim	[utc -> seconds {} %N {-1 day}]]
set tdate	[string trim	[utc -> seconds {} {%e. %B %Y} {}]]
set td 							[utc -> seconds {} %A {}]
if {$ym in {1 2 3}} {set q Q1} elseif {$ym in {4 5 6}} {set q Q2} elseif {$ym in {7 8 9}} {set q Q3} else {set q Q4}
set adtday		"Wikipedia:Hauptseite/Artikel des Tages/$td"
set adtpage		"Wikipedia Diskussion:Hauptseite/Artikel des Tages/Vorschläge"
set zadtpage	"Wikipedia Diskussion:Hauptseite/Artikel des Tages/Zukunft"
set tgtpage		"Wikipedia Diskussion:Hauptseite/Artikel des Tages/Archiv/Vorschläge/$yy/$q"
set adt [string trim [join [dict values [regexp -inline -- {LEMMA.*?=(.*?)\n} [conts t $adtday x]]]]]
set olsect [
	list [
		get [post $wiki {*}$parse / page $adtpage / prop sections] parse sections
	] [
		get [post $wiki {*}$parse / page $zadtpage / prop sections] parse sections
	]
]
foreach sect [join $olsect] {
	dict with sect {
		if {$level > 1} {
			lappend lsect $sect
		}
	}
}
set nconts [set oconts [conts t $adtpage x]]
lassign {0 {} 0} i aconts offindex
foreach sect $lsect {
	dict with sect {
		if {$index < $offindex} {break}
		set adtv {}
		if {[string first $ydate: $line] > -1} {
			set nconts [string map [list \n[conts t $adtpage $index]\n {}] $nconts]
			append aconts \n[conts t $adtpage $index]\n
			incr i
		} else {
			regexp -line -- [format {==.*?%s.*?\[\[(.*?)[|\]]} $adtdate] [conts t $adtpage $index] -- adtv
			if {![empty adtv] && $adtv ne $adt} {
				lappend ladtv $adtv
			}
		}
		set offindex $index
	}
}
puts $ladtv ; exit
#puts $ladtv:$aconts ; exit
if ![empty aconts] {
	set erltx {:<small>Archivierung dieses Abschnittes wurde gewünscht von: \1</small>}
	regsub -nocase -all -line -- {\{\{erledigt\|(?:1=)?(.*?)\}\}} $aconts \n$erltx aconts
	if {$oconts eq [conts t $adtpage x]} {
		set tgtsummary "Bot: Archivierung von $i Abschnitt[expr {$i > 1 ? {en} : {}}] von \[\[$adtpage\]\]"
		set adtsummary "Bot: Archivierung von $i Abschnitt[expr {$i > 1 ? {en} : {}}] nach \[\[$tgtpage\]\]"
		while 1 {if [catch {set token [login $wiki]}] {after 15000 ; continue} else {break}}
#		puts [edit $tgtpage $tgtsummary {} / appendtext [expr {[missing $tgtpage] ? {{{Archiv}}} : {}}]\n$aconts]
#		puts [edit $adtpage $adtsummary $nconts]
	}
}
set adtdiskconts [conts t [set adtdisk Diskussion:$adt] x]
if {[matchtemplate $adtdisk {Vorlage:AdT-Vorschlag Hinweis}] && [matchtemplate $adtdisk {Vorlage:War AdT}]} {
	regexp -nocase -- {\{\{AdT-Vorschlag.*?Datum=(.*?)\|.*?\}\}} $adtdiskconts vadt vdadt
	regexp -nocase -- {\{\{War AdT.*?\}\}} $adtdiskconts wadt
	if {[string first $tdate $wadt] == -1} {
		set madt [regexp -all -- {\=} $wadt]
		regsub -nocase -- {(\{\{War AdT.*?)(\}\})} $adtdiskconts \\1|[incr madt]=$tdate\\2 nadtdiskconts
	}
	if {[string trim $vdadt] eq $tdate} {
		set nadtdiskconts [string trim [string map [list $vadt {}] $nadtdiskconts]]
	}
	set typus 1
} elseif [matchtemplate $adtdisk {Vorlage:AdT-Vorschlag Hinweis}] {
	regexp -nocase -- {\{\{AdT-Vorschlag.*?Datum=(.*?)\|.*?\}\}} $adtdiskconts vadt vdadt
	if {[string trim $vdadt] eq $tdate} {
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
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
while 1 {if [catch {set token [login $wiki]}] {after 15000 ; continue} else {break}}
if {$typus != 4} {
	puts $typus:[edit $adtdisk "Bot: Artikel des Tages $tdate" $nadtdiskconts / minor]
} else {
	puts $typus:nochange
}
if [exists ladtv] {
	foreach adtv $ladtv {
		set vadtv {}
		set adtvdiskconts [conts t [set adtvdisk Diskussion:$adtv] x]
		if [matchtemplate $adtvdisk {Vorlage:AdT-Vorschlag Hinweis}] {
			regexp -nocase -- {\{\{AdT-Vorschlag.*?Datum=(.*?)\|.*?\}\}} $adtvdiskconts vadtv vdadtv
		}
		if ![empty vadtv] {
			if {[string trim $vdadtv] eq $tdate} {
				set nadtvdiskconts [string trim [string map [list $vadtv {}] $adtvdiskconts]]
			}
			puts [edit $adtvdisk "Bot: obsoleter AdT-Vorschlag" $nadtvdiskconts / minor]
		}
	}
}
set lang test ; source langwiki.tcl ; #set token [login $wiki]
puts [edid 63277 {Log: AdT} {} / appendtext "\n* '''[utc <- seconds {} %Y-%m-%dT%TZ {}] AdT-Archiv: Task finished!'''"]






exit

set lsect [regexp -inline -all -- {^==.*?\n=} [set nconts [set oconts [conts id 6474197 x]]]]
puts $lsect


exit
foreach sect $lsect {
	lappend csect [incr i] $sect
}
puts $csect
foreach {i sect} $csect {
	if {[string first $ydate: $sect] > -1} {
		puts $i:$sect
	}
}
puts [regexp -inline -- [format {%s.*?%s} [dict get $csect 15] [dict get $csect 16]] $nconts]
puts [dict get $csect 15]

exit

set lincltitle {}
set tdate  [string trim	[clock format            [clock seconds]         -format {%e. %B %Y} -timezone :Europe/Berlin -locale de]]
set ydate0 [string trim	[clock format [clock add [clock seconds] -1 day] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de]]
set ydate 					[clock format [clock add [clock seconds] -1 day] -format %d.%m.%Y    -timezone :Europe/Berlin]
set clock0 					[clock format 				 [clock seconds] 			 -format %H 			-timezone :Europe/Berlin]
foreach {pgid z} {6474197 0 1912033 1} {
	while 1 {try {set csect [regexp -line -all -- {^=} [set nconts [set oconts [conts id $pgid x]]]]} on 0 {} {break}}
	for {set sect 2} {$sect <= $csect} {incr sect} {
		try {set nsconts [set osconts [conts id $pgid $sect]]} on 1 {} {decr sect ; continue}
		if {		 [string first $ydate: [set top [regexp -inline -- {^==(.*?)==.*} $osconts]]] > -1
				&& ![regexp -nocase -- {\{\{Erl} $osconts]															} {
			set nsconts "$osconts\n\n\{\{Erledigt|1=Gestriger AdT-Abschnitt. ${~}\}\}"
			set nconts [string map [list $osconts $nsconts] $nconts]
		}
		if ![regexp -nocase -- {\{\{Erl} $nsconts] {lappend ltop [string trim [lindex $top 1]]}
		unset -nocomplain sconts nsconts
	}
	if {$nconts ne $oconts && $clock0 eq {00}} {
		puts [edid $pgid {Bot: gestrigen AdT-Abschnitt als "erledigt" markiert} $nconts / minor]
	}
	foreach top $ltop {
		if {[string first <s> $top] == -1} {
			set title {}
			set title {*}[dict values [regexp -inline -- {\[\[(.*?)\]\]} $top]]
			set title [string trim $title]
			if ![empty title] {
				set date {}
				catch {
					set date [string trim [clock format [
						clock scan [regexp -inline -- {\d\d.\d\d.20\d\d:} $top] -format %d.%m.%Y:
					] -format {%e. %B %Y} -locale de]]
				}
				if {![empty date] && $date ni [list $ydate0 $tdate] && $title ni $lincltitle} {
					set top [string map "\[ {} \] {}" $top]
					lappend nltop $title $date $top $z "\{\{AdT-Vorschlag Hinweis|Datum=$date|Abschnitt=$top[
						expr {$z ? {|Zukunft=1} : {}}
					]\}\}"
					lappend lincltitle $title
				}
			}
		}
	}
	unset -nocomplain ltop
}
foreach {disk date top z templ} $nltop {
	if {$date in [list $ydate0 $tdate]} {continue}
	while 1 {try {
		if ![missing Diskussion:$disk] {
			set ndconts [set odconts [conts t Diskussion:$disk x]]
		} else {
			lassign {} odconts ndconts
		}
	} on 0 {} {break}}
	set otempl {}
	regexp -- {\{\{AdT-Vorschlag Hinweis.*?\}\}} $odconts otempl
	if [empty otempl] {
		puts [edit Diskussion:$disk {Bot: Hinweis auf AdT-Vorschlag eingefügt} {} / prependtext $templ\n / minor]
	} elseif {[string first $date $otempl] == -1 || [string first $top $otempl] == -1 || ([string first Zukunft $otempl] > -1 && !$z)} {
		puts [edit Diskussion:$disk {Bot: Hinweis auf AdT-Vorschlag angepasst} [string map [list $otempl $templ] $odconts] / minor]
	}
}
if {$clock0 ne {00}} {
	set db [get_db dewiki]
	mysqlreceive $db "
		select page_title
		from page, templatelinks
		where tl_from = page_id and page_namespace = 1 and tl_from_namespace = 1 and tl_namespace = 10 and tl_title = 'AdT-Vorschlag_Hinweis'
	;" pt {
		lappend lpt [sql -> $pt]
	}
	mysqlclose $db
	foreach pt $lpt {
		if {$pt ni $lincltitle} {
			while 1 {try {set ndconts [set odconts [conts t Diskussion:$pt x]]} on 0 {} {break}}
			set otempl {}
			regexp -- {\{\{AdT-Vorschlag Hinweis.*?\}\}} $odconts otempl
			set ndconts [string map [list $otempl\n\n {} $otempl\n {} $otempl {}] $ndconts]
			puts [edit Diskussion:$pt {Bot: obsoleten AdT-Vorschlag entfernt} $ndconts / minor]
		}
	}
}
