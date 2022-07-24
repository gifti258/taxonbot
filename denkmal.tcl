#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl

#package require http
#package require tls
#package require tdom
#package require htmlparse

set lcat_b	[dcat sql {Liste (Baudenkmale in Brandenburg)} 0]
set lcat_s	[dcat sql {Liste (Kulturdenkmale in Sachsen)} 0]
set lcat_sa	[dcat sql {Liste (Kulturdenkmale in Sachsen-Anhalt)} 0]

foreach {lcat lline} [list $lcat_b {Commonscat Denkmalliste_Brandenburg_Tabellenzeile} $lcat_s {Commonscat Denkmalliste_Sachsen_Tabellenzeile} $lcat_sa {Commonscat Denkmalliste_Sachsen-Anhalt_Tabellenzeile}] {
	set lldl {}
	foreach line $lline {
		lassign {} ldl_o ldl
		set db [get_db dewiki]
		set ldl_o [
			mysqlsel $db "
				select page_title from page
				where page_title in ($lcat) and !page_namespace and page_title not in (
					select page_title from page join templatelinks on tl_from = page_id
					where page_title in ($lcat) and !page_namespace and !page_is_redirect and !tl_from_namespace and tl_namespace = 10 and tl_title = '$line'
				) and !page_namespace and !page_is_redirect
			;" -flatlist
		]
		mysqlclose $db
		set db [get_db dewiki]
		set ldl [
			mysqlsel $db "
				select page_title from page join templatelinks on tl_from = page_id
				where page_title in ($lcat) and !page_namespace and !page_is_redirect and !tl_from_namespace and tl_namespace = 10 and tl_title = '$line'
			;" -flatlist
		]
		mysqlclose $db
		lappend lldl $ldl_o $ldl
	}
	lappend llldl $lldl
}

foreach lldl $llldl {
	foreach ldl $lldl {
		set rldl {}
		foreach dl $ldl {
			lappend rldl "* \[\[Datei:Notification-icon-Wikidata-logo.svg|20px|verweis=:d:[get_q $dl 0]\]\] \[\[[sql -> $dl]\]\]"
		}
		lappend lrldl $rldl
	}
}

lassign {} ld_b ld_s ld_sa ldiff_b ldiff_s ldiff_sa qdiff_b qdiff_s qdiff_sa

puts 1
foreach {listid abbr} {1 b 5 s 9 sa} {
	lassign {} de_data d_data
	set rldl [lindex $lrldl $listid]
	foreach ldl $rldl {
		set q [lindex [split $ldl {:]}] 3]
		set pt [lindex [split $ldl {[]}] 6]
		if [catch {
			set commonscat [string trim [lindex [split [
				regexp -inline -line -nocase -- {^.*\{\{Commonscat.*\}\}.*$} [conts t $pt x]
			] |\}] 1]]
		}] {continue}
		lappend de_data $q $pt $commonscat
	}
	set lwd wd:[string map {{ } { wd:}} [dict values [regexp -all -inline -- {:d:(Q\d{1,})} $rldl]]]
	set lwdh [expr [llength $lwd] / 2]
	set lwd1 [lrange $lwd 0 $lwdh]
	set lwd2 [lrange $lwd [incr lwdh] end]
	unset -nocomplain llwd
	if {$listid == 5} {
		lappend llwd [lrange $lwd 0 399] [lrange $lwd 400 799] [lrange $lwd 800 1199] [lrange $lwd 1200 end]
	} else {
		set llwd [list $lwd]
	}
	set lresult {}
	foreach plwd $llwd {
		while 1 {if ![catch {
			set rquery [getHTML https://query.wikidata.org/sparql?query=[curl::escape [format {
				select ?item ?commonscat
				where {
					values ?item {%s}
					optional {?item wdt:P373 ?commonscat.}
				}
			} $plwd]]]
			if {[string first {URI Too Large} $rquery] > -1} {
				puts {URI Too Large} ; exit
			}
		}] {break}}
		lappend lresult [dict values [regexp -all -inline -- {<result>(.*?)</result>} $rquery]]
	}
	foreach result [join $lresult] {
		set d_commonscat {}
		regexp -- {entity/(Q\d{1,})} $result -- q
		regexp -- {<literal>(.*?)</literal>} $result -- d_commonscat
		lappend d_data $q $d_commonscat
	}
	foreach {q pt commonscat} $de_data {
#		set d_commonscat {}
#		if {$q in $d_data} {
			set d_commonscat [dict get $d_data $q]
#		} else {continue}
#		puts $q:$pt:$commonscat:$d_commonscat
		lappend ddata_$abbr $q [list pt $pt commonscat $commonscat d_commonscat $d_commonscat]
	}
	set ddata_$abbr
	foreach {q data} [set ddata_$abbr] {
		dict with data {
			if {![empty d_commonscat] && $d_commonscat ne $commonscat} {
				puts $q:$commonscat:$d_commonscat
				lappend ldiff_$abbr "|-\n| \[\[:d:$q\]\]\n| \[\[$pt\]\]\n| \[\[:c:Category:$commonscat\]\]\n| \[\[:c:Category:[join $d_commonscat]\]\]"
			}
		}
	}
	set ldiff_$abbr "\{| class=\"wikitable zebra\"\n|-\n! QID\n! Liste\n! de:Commonscat-Link\n! wikidata:Commonscat-Link\n[join [set ldiff_$abbr] \n]\n|\}"
}

puts [edit {user:TaxonBot/Test} {Bot: Aktualisierung der Denkmal-Arbeitsliste} "== Commonscat fehlt ==\n=== Denkmallisten Brandenburg ===\n[join [lindex $lrldl 0] \n]\n\n=== Denkmallisten Sachsen ===\n[join [lindex $lrldl 4] \n]\n\n=== Denkmallisten Sachsen-Anhalt ===\n[join [lindex $lrldl 8] \n]\n\n== ohne Vorlage Tabellenzeile ==\n=== Denkmallisten Brandenburg ===\n[join [lindex $lrldl 2] \n]\n\n=== Denkmallisten Sachsen ===\n[join [lindex $lrldl 6] \n]\n\n=== Denkmallisten Sachsen-Anhalt ===\n[join [lindex $lrldl 10] \n]\n\n== Abweichende Commonscat-Links ==\n=== Denkmallisten Brandenburg ===\n$ldiff_b\n\n=== Denkmallisten Sachsen ===\n$ldiff_s\n\n=== Denkmallisten Sachsen-Anhalt ===\n$ldiff_sa"]


puts [edit {user:Z thomas/Denkmal-Arbeitslisten} {Bot: Aktualisierung der Denkmal-Arbeitsliste} "== Commonscat fehlt ==\n=== Denkmallisten Brandenburg ===\n[join [lindex $lrldl 0] \n]\n\n=== Denkmallisten Sachsen ===\n[join [lindex $lrldl 4] \n]\n\n=== Denkmallisten Sachsen-Anhalt ===\n[join [lindex $lrldl 8] \n]\n\n== ohne Vorlage Tabellenzeile ==\n=== Denkmallisten Brandenburg ===\n[join [lindex $lrldl 2] \n]\n\n=== Denkmallisten Sachsen ===\n[join [lindex $lrldl 6] \n]\n\n=== Denkmallisten Sachsen-Anhalt ===\n[join [lindex $lrldl 10] \n]\n\n== Abweichende Commonscat-Links ==\n=== Denkmallisten Brandenburg ===\n$ldiff_b\n\n=== Denkmallisten Sachsen ===\n$ldiff_s\n\n=== Denkmallisten Sachsen-Anhalt ===\n$ldiff_sa"]

exit

foreach {q data} $ddata {
	if {

#	puts [lindex $lrldl $listid]
	exit
	foreach dl [lindex $lrldl $listid] {
		puts :$dl
	}
}

foreach {listid abbr} {1 b 5 s 9 sa} {
	foreach dl [lindex $lrldl $listid] {
		unset -nocomplain commonscat
		set q [lindex [split $dl {:]}] 3]
		set pt [lindex [split $dl {[]}] 6]
		if [catch {
			set commonscat [string trim [lindex [split [
				regexp -inline -line -nocase -- {^.*\{\{Commonscat.*\}\}.*$} [conts t $pt x]
			] |\}] 1]]
		}] {continue}
			
		lappend ld_$abbr $q $pt $commonscat $d_commonscat
	}
}


exit

#puts $ld

unset token
source d.tcl
puts $token

foreach abbr {b s sa} {
	foreach {q pt commonscat} [set ld_$abbr] {
		puts \n$q:$pt:$commonscat
		unset -nocomplain d_commonscat
		set err 0
		try {set d_commonscat [d_get_lq $q P373]} on error err {set d_commonscat {}}
		puts err:$err
		if {![empty d_commonscat] && [join $d_commonscat] ne $commonscat} {
			puts :[join $d_commonscat]:$commonscat:
			lappend ldiff_$abbr "|-\n| \[\[:d:$q\]\]\n| \[\[$pt\]\]\n| \[\[:c:Category:$commonscat\]\]\n| \[\[:c:Category:[join $d_commonscat]\]\]"
			lappend qdiff_$abbr $q
		} else {
			puts [join $d_commonscat]
		}
	}
}

foreach abbr {b s sa} {
	set ldiff_$abbr "\{| class=\"wikitable zebra\"\n|-\n! QID\n! Liste\n! de:Commonscat-Link\n! wikidata:Commonscat-Link\n[join [set ldiff_$abbr] \n]\n|\}"
	set ldiff_$abbr
}

source s.tcl

#user:Z thomas/Denkmal-Arbeitslisten

puts [edit {user:Z thomas/Denkmal-Arbeitslisten} {Bot: Aktualisierung der Denkmal-Arbeitsliste} "== Commonscat fehlt ==\n=== Denkmallisten Brandenburg ===\n[join [lindex $lrldl 0] \n]\n\n=== Denkmallisten Sachsen ===\n[join [lindex $lrldl 4] \n]\n\n=== Denkmallisten Sachsen-Anhalt ===\n[join [lindex $lrldl 8] \n]\n\n== ohne Vorlage Tabellenzeile ==\n=== Denkmallisten Brandenburg ===\n[join [lindex $lrldl 2] \n]\n\n=== Denkmallisten Sachsen ===\n[join [lindex $lrldl 6] \n]\n\n=== Denkmallisten Sachsen-Anhalt ===\n[join [lindex $lrldl 10] \n]\n\n== Abweichende Commonscat-Links ==\n=== Denkmallisten Brandenburg ===\n$ldiff_b\n\n=== Denkmallisten Sachsen ===\n$ldiff_s\n\n=== Denkmallisten Sachsen-Anhalt ===\n$ldiff_sa"]



exit

puts $lccat_s

exit
#set lcat [deepcat {{Kategorie:Liste (Kulturdenkmale in Sachsen)}} 0]
puts $lcat_b:[llength $lcat_b]
puts $lcat_s:[llength $lcat_s]
puts $lcat_sa:[llength $lcat_sa]


