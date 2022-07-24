#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot NeueArtikel1.tc] > 1} {exit}}

source api2.tcl
set lang kat ; source langwiki.tcl
source procs.tcl

set lportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (NeueArtikel)} x]
foreach portal $lportal {lappend clportal [string map {{ } _ ~ ~~~~~ / ~ ! ´´´´} $portal]}
foreach portal [glob -directory NeueArtikel -tails *] {
	if {$portal ni $clportal} {
		puts "rm: NeueArtikel/$portal"
		exec rm NeueArtikel/$portal
	}
}
#set lportal {{Portal:Hannover/Neue Artikel}}
foreach portal $lportal {
	regexp -- {\{\{(Benutzer:MerlBot/InAction\|NeueArtikel\|.*?)\}\}} [
		string map {Commonscat| Commonscat@} [contents t $portal x]
	] -- temp
	lassign {{} {} {} {} 29 0} lparam 2 IGNORECAT listformat maxTage allow
	foreach 1 [split $temp |] {if {[string first = $1] > -1} {append 2 { } [split $1 =]} else {lappend 2 $1 {}}}
	foreach 1 $2 {lappend lparam [string trim $1]}
	set keys [dict keys $lparam]
	if {{SHORTLIST} in $keys} {lappend lparam listformat SHORTLIST} else {lappend lparam listformat LIST}
	if {{maxTage} in $keys} {
		if {[dict get $lparam maxTage] eq {}} {set lparam [dict replace $lparam maxTage 29]}
	} else {
		lappend lparam maxTage 29
	}
	dict with lparam {
		lassign {} l0cat l0icat lcat licat lxcat
		puts \n$portal
		if {$CAT eq {SCAT}} {
			set lcat [SCAT $portal/SCAT]
		} else {
			foreach 1 [split $CAT ,] {lappend l0cat Kategorie:[string trim $1]}
			set lcat [portalcat $l0cat]
		}
		foreach 1 [split $IGNORECAT ,] {lappend l0icat Kategorie:[string trim $1]}
		if ![empty l0icat] {set licat [portalcat $l0icat]}
		set lxcat [list catdb $lcat icatdb $licat param $lparam]
		set f [open NeueArtikel/[string map {{ } _ ~ ~~~~~ / ~ ! ´´´´} $portal] w] ; puts $f $lxcat ; close $f
	}
}

