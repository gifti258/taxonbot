#!/usr/bin/tclsh8.7
#exit

set editafter 1

source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

proc get_rand {} {
	while 1 {
		if {[set rand [string trimleft [string range [expr rand()] end-3 end] 0]] <= 5000} {
			return [expr $rand + 10000]
		}
	}
}

if {[string index $argv 0] eq {+}} {
	set us [string trim [string trimleft [join $argv] +]]
	puts $us:

	set lpt [mysqlsel $db "
		select page_title from page join pagelinks on pl_from = page_id
		where page_namespace = 4 and pl_from_namespace = 4 and pl_namespace = 2 and pl_title = '[sql <- $us]'
	;" -flatlist]
	set verilist Wikipedia:[lsearch -inline $lpt Benutzerverifizierung/Benutzernamen-Ansprachen/*]
	set verilist_summ "-\[\[user:$us|$us\]\]; Benutzerkonto-Verifizierung erledigt"
} elseif {[string index $argv 0] eq {-}} {
	set us [string trim [string trimleft [join $argv] -]]
	puts $us:

	set lpt [mysqlsel $db "
		select page_title from page join pagelinks on pl_from = page_id
		where page_namespace = 4 and pl_from_namespace = 4 and pl_namespace = 2 and pl_title = '[sql <- $us]'
	;" -flatlist]
	set verilist Wikipedia:[lsearch -inline $lpt Benutzerverifizierung/Benutzernamen-Ansprachen/*]

	unset -nocomplain ix
	foreach sc [get [post $wiki {*}$parse / page BD:$us / prop sections] parse sections] {
		dict with sc {
			if {$line in {Benutzername {Dein Benutzername} {Problem mit dem Benutzernamen}}} {
				set ix $index
				break
			}
		}
	}
	if ![exists ix] {
		set verilist_summ "-\[\[user:$us|$us\]\]; Benutzerkonto-Verifizierung unnötig"
	} else {
		set sccont [contents t BD:$us $ix]
		regexp -- {(\[\[Kategorie:Benutzer:Verifizierung angefordert (\d{4}-\d{2}).*?\]\]\n\n)} $sccont -- catline cat
		input pkt "unnötig nach: (Punkt/e) "
		if {[string length $pkt] > 1} {
			set pkt "Punkte [join [split $pkt {}] {, }]"
		} else {
			set pkt "Punkt $pkt"
		}
		set sccont_new "[string map [list $catline {}] $sccont]\n\{\{Verifizierung unnötig|nach \[\[WP:VER\]\] $pkt ~~~\}\}\n\{\{erledigt|~~~\}\}"
		puts \n[edit BD:$us {OTRS: Benutzerkonto-Verifizierung unnötig} $sccont_new / section $ix / minor true]\n
		set verilist_summ "-\[\[user:$us|$us\]\]; Benutzerkonto-Verifizierung unnötig"
	}
} else {
	set summary {Benutzerseite eines unbeschränkt [[WP:BS|gesperrten Benutzers]]}
	set us [join $argv]
	puts $us:

	set lpt [mysqlsel $db "
		select page_title from page join pagelinks on pl_from = page_id
		where page_namespace = 4 and pl_from_namespace = 4 and pl_namespace = 2 and pl_title = '[sql <- $us]'
	;" -flatlist]
	set verilist Wikipedia:[lsearch -inline $lpt Benutzerverifizierung/Benutzernamen-Ansprachen/*]

	puts [get [post $wiki {*}$format {*}$token / action block / user $us / allowusertalk false / reason {Trotz Aufforderung nicht [[WP:VER|verifiziertes Benutzerkonto]]}]]

	if ![missing user:$us] {
		after [get_rand]
		puts [edit user:$us $summary {#WEITERLEITUNG [[{{ers:DISK}}]]}]

		after [get_rand]
		puts [get [post $wiki {*}$format {*}$token / action protect / title user:$us / protections edit=sysop|move=sysop / reason $summary]]
	} else {
		after [get_rand]
		puts [get [post $wiki {*}$format {*}$token / action protect / title user:$us / protections create=sysop / reason $summary]]
	}

	after [get_rand]
	puts [edit BD:$us $summary {{{GBN}}}]

	after [get_rand]
	puts [get [post $wiki {*}$format {*}$token / action protect / title BD:$us / protections edit=sysop|move=sysop / reason $summary]]
}

after 3000
set cvl [conts t $verilist x]
regsub -all -- {^(\|)(\{\{)} $cvl {\1 \2} ncvl
regsub -- "\\|-\n\\| \{\{Benutzer\\| ??$us.*?(\\|-|\\|\})" $ncvl \\1 nncvl
if ![exists verilist_summ] {
	set verilist_summ "-\[\[user:$us|$us\]\]; Benutzerkonto nicht verifiziert"
}
if {$nncvl ne $cvl} {
	source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
	puts [edit $verilist "Bot: $verilist_summ" $nncvl]\n
}
