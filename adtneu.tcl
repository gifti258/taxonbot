#!/usr/bin/tclsh8.7

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set lveto [dict values [regexp -all -inline -line -- {\[\[(.*)\]\]} [conts id 3396115 1]]]
set adtpage0 {Wikipedia Diskussion:Hauptseite/Artikel des Tages}
set ladtpage [dict values [regexp -all -inline -- {\[\[../(.*?)\|} [
	conts t $adtpage0/Index x
]]]
set dsect {}
set today [utc -> seconds {} %d.%m.%Y {}]

foreach adtpage $ladtpage {
	set lsect [get [
		post $wiki {*}$parse / page $adtpage0/$adtpage / prop sections
	] parse sections]
	foreach sect $lsect {
		dict with sect {
			if {$level == 2} {
				unset -nocomplain sectconts
				set sectconts [conts t $adtpage0/$adtpage $index]
				set ltempl [regexp -all -inline -- {\{\{.*?\}\}} [
					string map [list \{\{\{ {} \}\}\} {}] $sectconts
				]]
				foreach templ $ltempl {
					if {[string first {Hauptseite/Artikel des Tages} $templ] > -1} {
						set ptempl [parse_templ $templ]
						dict with ptempl {
							if {$LEMMA ni [dict keys $dsect]} {
								dict lappend dsect $LEMMA sdate $DATUM from $fromtitle index $index line $line
							}
						}
					}
				}
			}
		}
	}
}

set lkey [dict keys $dsect]
set db [get_db dewiki]
mysqlreceive $db {
	select page_title from page join templatelinks on tl_from = page_id
	where page_namespace = 1 and tl_from_namespace = 1 and tl_namespace = 10
		and tl_title = 'AdT-Vorschlag_Hinweis'
;} pt {
	unset -nocomplain date
	set npt [sql -> $pt]
#puts $npt
	lappend lpt $npt
	set caught 0
	catch {
		set sectdata [dict get $dsect $npt]
#puts $sectdata
		dict with sectdata {
			regexp -- {\d{1,2}\.\d{2}.\d{4}} $line date
		}
#	puts $date
		set scandate [clock scan $date -format %e.%m.%Y]
#puts $scandate:$sectdata
	}
if 0 {
	if {[clock scan $today -format %d.%m.%Y] > $scandate} {
		puts "$npt: $scandate $sect"
		dict lappend darch larch $scandate $index [set sectconts [conts t $from $index]]
		dict lappend darch $from $sectconts
	}
}
	if {$npt ni $lkey} {
		regsub -line {\{\{AdT-Vorschlag Hinweis.*} [conts t Diskussion:$npt 0] {} nconts
		if {[string trim $nconts] eq {}} {set nconts {}}
		set obszuq {Bot: Löschung des obsoleten AdT-Vorschlags}
		puts [edit Diskussion:$npt $obszuq $nconts / section 0 / minor]
	}
}
mysqlclose $db

if 0 {
dict with darch {
	foreach arch $larch {puts $arch}
	set lsortlarch [lsort -integer -stride 3 -index 0 [
		lsort -integer -stride 3 -index 1 $larch
	]]
	foreach {-- -- conts} $lsortlarch {
		incr iarch
		lappend larchconts $conts
	}
	puts [join $larchconts \n\n]
	set q {Wikipedia Dikussion:Hauptseite/Artikel des Tages/Archiv/Vorschläge/2020/Q4}
	set zuq "Bot: Archivierung von $iarch Abschnitt[expr {$iarch > 1 ? "en" : {}}]"
	puts [edit $q $zuq {} / appendtext [join $larchconts \n\n]]
	foreach {key lval} [lrange $darch 2 end] {
		puts $key:$lval
		set conts [conts t $key x]
		foreach val $lval {
			set conts [string map [list \n$val\n {}] $conts]
		}
		puts $conts
		set zuq "Bot: Archivierung von $iarch Abschnitt[expr {$iarch > 1 ? "en" : {}}]"
		puts [edit $key $zuq $conts]
	}
}

exit
}

foreach {lemma data} $dsect {
#puts $lemma:$data
	if {$lemma in $lveto} {continue}
	set talklemma "Diskussion:$lemma"
	lassign {} talk0 ttempl
	if [catch {
		if ![missing $talklemma] {
			regexp -nocase -- {\{\{AdT-Vorschlag Hinweis.*?\}\}} [
				set talk0 [conts t $talklemma 0]
			] ttempl
		}
	}] {puts Fehler:$data ; continue}
	set pttempl [parse_templ $ttempl]
	dict with data {
		if [empty sdate] {continue}
		set csdate [clock scan $sdate -format %e.%m.%Y]
		set pdate [utc ^ $sdate %e.%m.%Y {%e. %B %Y} {}]
		dict with pttempl {
			if [empty TEMPLATE] {
				if {$csdate <= [clock scan $today -format %e.%m.%Y]} {
					continue
				}
				regexp -- {[\d]?[\d]\.\d{2}\.\d{4}} $line tdate
				if {[clock scan $tdate -format %e.%m.%Y] == $csdate} {
					set adtappend [lindex [split $from /] end]
					if {$adtappend eq {Vorschläge}} {
						set line [string map {<s> {} </s> {}} $line]
					} else {
						set line [string map {<s> {} </s> {}} $line|Zukunft=$adtappend]
					}
					set tnote "\{\{AdT-Vorschlag Hinweis|Datum=$pdate|Abschnitt=$line\}\}\n"
					set tzq {Bot: Hinweis auf AdT-Vorschlag eingefügt}
					puts [edit $talklemma $tzq {} / prependtext $tnote / section 0 / minor]
				}
				continue
			}
			if {[clock scan $Datum -format {%e. %B %Y} -locale de] != $csdate} {
				regexp -- {[\d]?[\d]\.\d{2}\.\d{4}} $line tdate
				if {[clock scan $tdate -format %e.%m.%Y] == $csdate} {
					set adtappend [lindex [split $from /] end]
					if {$adtappend eq {Vorschläge}} {
						set line [string map {<s> {} </s> {}} $line]
					} else {
						set line [string map {<s> {} </s> {}} $line|Zukunft=$adtappend]
					}
					set tnote "\{\{AdT-Vorschlag Hinweis|Datum=$pdate|Abschnitt=$line\}\}\n"
					set ntalk0 [string map [list $ttempl $tnote] $talk0]
					set tzq {Bot: Hinweis auf AdT-Vorschlag aktualisiert}
					puts [edit $talklemma $tzq $ntalk0 / section 0 / minor]
				}
			}
		}
	}
	unset -nocomplain Datum sdate tdate
}
