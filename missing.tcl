#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set misspage {Wikipedia:Vermisste Wikipedianer}
set t7 [clock format [clock add [clock seconds] -1 days] -format %Y%m%d -timezone :Europe/Berlin]
set ty [clock format [clock add [clock seconds] -1 days] -format %Y%m%d -timezone :Europe/Berlin]
set lsect [get [post $wiki {*}$parse / page $misspage / prop sections] parse sections]
lassign {} lmissing lerl
foreach sect $lsect {
	dict with sect {
		if {$level == 2} {
			contents t $misspage $index
			set luser [string trim [
				dict values [regexp -all -inline -- {/(.*?)\|} [set topic [regexp -all -line -inline -- {==.*?==} $contents]]]
			]]
			set rawlreporter [string trim [
				regexp -all -inline -nocase -- {\[\[(Benutzer|Benutzer Diskussion|Benutzerin|Benutzerin Diskussion|User|User talk)??\: ?(.*?)[\|\]&]} $contents
			]]
			set lreporter {}
			foreach {-- -- reporter} $rawlreporter {
				if {[string first / $reporter] == -1} {
					lappend lreporter $reporter
				}
			}
			set lreporter [lsort -unique $lreporter]
			foreach user $luser {
				for {set x 1} {$x <= [llength $lreporter]} {incr x} {
					lremove lreporter $user
					lremove lreporter w:de:Bader
				}
			}
			set ts [clock format [clock scan [
				string map {. {}} [join [regexp -inline -- {\d\d:\d\d, \d{1,2}. \w{3,4}\.? \d{4}} $contents]]
			] -format {%R, %e %b %Y} -locale de] -format %Y%m%d]
			if {[string first \{\{erledigt| [string tolower $contents]] > -1 || [string first erl. $topic] > -1 || [string first erledigt $topic] > -1} {
				set erl 1
			} else {
				set erl 0
			}
			if $erl {
				set erlline [regexp -nocase -inline -- {\{\{erledigt\|.*?\}\}} $contents]
				regexp -nocase -- {\[\[(Benutzer|Benutzer Diskussion|Benutzerin|Benutzerin Diskussion|User|User talk)??\: ?(.*?)[\|\]&]} $erlline -- -- erluser
				set erlts [clock format [clock scan [
					string map {. {}} [join [regexp -inline -- {\d\d:\d\d, \d{1,2}. \w{3,4}\.? \d{4}} $erlline]]
				] -format {%R, %e %b %Y} -locale de] -format %Y%m%d]
				if {$erlts == $ty} {
					foreach reporter $lreporter {
						if {{missing} ni [dict keys [join [get [post $wiki {*}$query / list users / ususers $reporter] query users]]]} {
							if {$reporter ne [string trim $erluser] && $reporter ni $luser} {
								set txterl "== Vermisstenmeldung erledigt ==\nHallo [string map {_ {}} $reporter],<br />Du hattest Dich auf \[\[Wikipedia:Vermisste Wikipedianer#$line|Wikipedia:Vermisste Wikipedianer\]\] zum dort vermissten Benutzer geäußert. Dieser Abschnitt wurde nun als erledigt markiert. Vielen Dank, ~~~~"
								puts [edit BD:$reporter {/* Vermisstenmeldung erledigt */} {} / appendtext \n\n$txterl]
							}
						}
					}
				}
				continue
			}
			if {$ts == $t7} {lappend lmissing $luser $line $erl}
		}
	}
}
foreach {luser line erl} $lmissing {
	foreach user $luser {
		if {{missing} ni [dict keys [join [get [post $wiki {*}$query / list users / ususers $user] query users]]] && !$erl} {
			set llink [links BD:$user 4]
			if {{Wikipedia:Vermisste Wikipedianer} ni $llink && {Wikipedia:VW} ni $llink && {Wikipedia:-(} ni $llink} {
				set txtmiss "== Du wirst vermisst! ==\nHallo [string map {_ {}} $user],<br />ein Wikipedianer hat Dich auf \[\[Wikipedia:Vermisste Wikipedianer#$line|Wikipedia:Vermisste Wikipedianer\]\] eingetragen, weil einer oder mehrere Benutzer Dich vermissen. Falls Du wieder aktiv bist, würden sich diese Benutzer sicherlich über eine kurze Rückmeldung dort freuen. Vielen Dank, ~~~~"
				puts [edit BD:$user {/* Du wirst vermisst! */} {} / appendtext \n\n$txtmiss]
			}
		}
	}
}
