#!/usr/bin/tclsh8.7
#exit

#catch {if {[exec pgrep -cxu taxonbot adt2.tcl] > 1} {exit}}
catch {if {[exec pgrep -cxu taxonbot adt3.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

set lvetopage [string tolower [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} [conts id 3396115 1]]]]
set lspokencat [string tolower [cat {Kategorie:Wikipedia:Gesprochener Artikel} 0]]

#if {$argv eq {e}} {set id 983688} elseif {$argv eq {l}} {set id 3352903}
foreach pgid {983688 3352903} {
	if {$pgid == 983688} {
		puts "Starte Exzellenz-Verwaltung"
	} else {
		puts "Starte Lesenswert-Verwaltung"
	}
	set nconts [set conts [conts id $pgid x]]
	set lline [split $conts \n]
	foreach line [string map {{2002 AA29|2002 AA<sub>29</sub>} {2002 AA29} {2003 YN107|2003 YN<sub>107</sub>} {2003 YN107}} $lline] {
		if {[string index $line 0] eq {#}} {
#if {$line ne {# '''[[Homeland (Fernsehserie)]]'''}} {continue}
			lassign {0 {} {} {}} dates talkconts ldate
			if {[string first {2002 AA29} $line] > -1} {
				set page {2002 AA29}
			} elseif {[string first {2003 YN107} $line] > -1} {
				set page {2003 YN107}
			} else {
				regexp -- {\[\[(.*?)\]\]} $line -- page
			}
			set dates [lindex [regexp -all -inline -- {<small>(.*?)</small>} $line] end]
			set nrs [regexp -all -- {\d} $dates]
			if {[string first | $page] > -1} {puts $page:pipe ; continue}
			if [redirect $page] {
				puts $page:redirect
				set oconts $conts
				set npage [sql -> [mysqlsel $db "
					select rd_title from redirect join page on rd_from = page_id
					where page_title = '[sql <- $page]' and !page_namespace
				" -flatlist]]
				set nconts [string map [list $page $npage] $nconts]
				if {$oconts eq $nconts} {
					puts "Redirect auf $npage geändert\n"
				} else {
					unset -nocomplain npage oconts ; continue
				}
				unset -nocomplain npage oconts
			}
			if [catch {set talkconts [conts t Diskussion:$page 0]}] {continue}
			set lrex [lsort -decreasing [regexp -all -inline -- {\{\{.*?\}\}} $talkconts]]
			foreach rex $lrex {
				set parsetempl [parse_templ $rex]
				dict with parsetempl {
					switch $TEMPLATE {
						{War AdW} {
							switch [llength $1] {
								1 {set wdate1 "$1 [lrange $2 1 2]"}
								2 {set wdate1 "$1 [lindex $2 end]"}
								3 {set wdate1 $1}
							}
							lappend ldate [utc ^ $wdate1 {%e. %B %Y} {%d.%m.%Y} {}]−[utc ^ $2 {%e. %B %Y} {%d.%m.%Y} {}]
						}
						{War AdT} {
							if {[expr ([llength $parsetempl] - 2) / 2] != [expr $nrs / 8]} {
#								puts "unterschiedliche Mengen"
							}
							foreach date [dict values [lrange $parsetempl 2 end]] {
								lappend ldate [utc ^ $date {%e. %B %Y} {%d.%m.%Y} {}]
							}
						}
						{AdT-Vorschlag Hinweis}	{
							lappend ldate ''[utc ^ $Datum {%e. %B %Y} {%d.%m.%Y} {}]''
						}
					}
				}
			}
			set lowpage [string tolower $page]
			set sveto { <small>([[WP:ADT/V/HAV|Veto]])</small>}
			if {$page eq {2002 AA29}} {
				set page {2002 AA29|2002 AA<sub>29</sub>}
			} elseif {$page eq {2003 YN107}} {
				set page {2003 YN107|2003 YN<sub>107</sub>}
			}
			set nline "#[expr {$lowpage in $lspokencat ? { {{Gesprochen}}} : {}}][expr {[empty ldate] ? " '''\[\[$page\]\]'''" : [string first ' $ldate] > -1 ? " ''\[\[$page\]\]''" : " \[\[$page\]\]"}][expr {$lowpage in $lvetopage ? $sveto : {}}][expr {![empty ldate] ? " − <small>[join $ldate { + }]</small>" : {}}]"
			set nconts [string map [list $line $nline] $nconts]
		}
	}
	if {[conts id $pgid x] eq $conts} {
		puts [edid $pgid {Bot: Aktualisierung} $nconts / minor]
	}
}
