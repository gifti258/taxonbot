#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]

set db [get_db commonswiki]
mysqlreceive $db "
	select page_title
	from page, categorylinks
	where cl_from = page_id and page_namespace = 14 and cl_to = 'Category_redirects'
	order by page_title
;" cpt {
	lappend lcpt [sql -> $cpt]
}
mysqlclose $db
set db [get_db commonswiki]
mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Commonscat'
	order by page_title
;" pt {
	lappend lpt [sql -> $pt]
}
foreach pt $lpt {
	set oconts [conts t $pt x]
	set lline [split $oconts \n]
	foreach oline $lline {
		set nline [string trim $oline]
		if {[string first ommonscat $nline] > -1} {
			if {[string range $nline end-1 end] ne "\}\}"} {puts \n$pt:\n...Linefehler ; continue}
			if [regexp -nocase -- {\{\{Commonscat\}\}} $nline] {
				set oclink {}
			} else {
				regexp -nocase -- {\{\{Commonscat(.*?)\}\}} [string map {{{{PAGENAME}}} §PN§ {{{SEITENNAME}}} §PN§} $nline] -- oclink
				if {[string first \{ $oclink] > -1} {puts \n$pt:\n...Klammerfehler ; continue}
				set oclink [string trim $oclink]
				if {[string index $oclink 0] eq {|}} {set oclink [string trimleft $oclink |]}
			}
			set oclink [split $oclink |]
			if {$oclink eq {}} {set oclink $pt}
			if {$oclink in $lcpt} {
				puts \n$pt\n$oline\n$nline\n$oclink
			}
		}
	}
#	if {[incr i] > 1500} {exit}
}
