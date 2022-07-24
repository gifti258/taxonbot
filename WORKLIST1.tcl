#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot WORKLIST1.tcl] > 1} {exit}}

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]

set lportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (WORKLIST)} x]
foreach portal $lportal {lappend clportal [string map {{ } _ ~ ~~~~~ / ~ ! ´´´´} $portal]}
foreach portal [glob -directory WORKLIST -tails *] {
	if {$portal ni $clportal && $portal ni [glob -directory WORKLIST -tails @*]} {
		puts "rm: WORKLIST/$portal"
		exec rm WORKLIST/$portal
	}
}
#set lportal {{Portal:Norwegen/Überarbeiten}}
foreach portal $lportal {
	if {$portal eq {Benutzer:Entbert/Werkstatt}} {continue}
	lassign {} lparam 2 CAT IGNORECAT
	regsub -all -- {\{\{Commonscat\|(.*?)\}\}} [contents t $portal x] Commonscat:\\1 contents
	regexp -- {\{\{(Benutzer:MerlBot/InAction\|WORKLIST\|.*?)\}\}} $contents -- temp
	set temp [string map {style= style: align= align:} $temp]
	foreach 1 [split $temp |] {if {[string first = $1] > -1} {append 2 { } [split $1 =]} else {lappend 2 $1 {}}}
	foreach 1 $2 {lappend lparam [string trim $1]}
	set listform [dict values [regexp -inline -- {(SHORTLIST|CLIST|TABLE)} $lparam]]
	if ![empty listform] {lappend lparam listformat $listform} else {lappend lparam listformat LIST}
	if {{LISTS} ni [dict keys $lparam]} {lappend lparam LISTS ALL}
	if {{ALWAYSSHOW} ni [dict keys $lparam]} {lappend lparam ALWAYSSHOW {}}
	if {{EMPTY} ni [dict keys $lparam]} {lappend lparam EMPTY {''Zurzeit keine''}}
	if {{LH} ni [dict keys $lparam]} {lappend lparam LH {}}
	dict with lparam {
		lassign {} l0cat l0icat lcat licat lxcat
		puts \n$portal
		if {$CAT eq {SCAT}} {
			set lcat [SCAT $portal/SCAT]
		} else {
			foreach 1 [split $CAT ,] {lappend l0cat Kategorie:[string trim $1]}
			if {$l0cat eq {Kategorie:!Hauptkategorie}} {
				set lcat $l0cat
			} else {
				set lcat [portalcat $l0cat]
			}
		}
		foreach 1 [split $IGNORECAT ,] {lappend l0icat Kategorie:[string trim $1]}
		if ![empty l0icat] {set licat [portalcat $l0icat]}
		set lxcat [list catdb $lcat icatdb $licat param $lparam]
		set f [open WORKLIST/[string map {{ } _ ~ ~~~~~ / ~ ! ´´´´} $portal] w] ; puts $f $lxcat ; close $f
	}
}
