#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot purge.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set f [open purge.out w] ; close $f
puts [utc <- seconds {} %Y-%m-%d-%T {}]\n

set c1 [conts t Benutzer:AsuraBot/Purges 1]
set ll1 [dict values [regexp -all -inline -line -- {^\* \[\[[:]?(.*?)[|\]].*$} $c1]]
puts Purge1:[get [post $wiki {*}$format / action purge / titles [join $ll1 |]]]

set c2 [conts t Benutzer:AsuraBot/Purges 2]
set ll2a [dict values [regexp -all -inline -line -- {^\* \[\[[:]?(.*?)[|\]].*$} $c2]]
puts \nPurge2:[get [post $wiki {*}$format / action purge / titles [join $ll2a |] / forcelinkupdate 1]]
set db [get_db dewiki]
mysqlreceive $db {
	select page_title
	from page
	where page_title like 'Adminkandidaturen/%' and page_namespace = 4
;} pt {
	lappend ll2b Wikipedia:[sql -> $pt]
}
mysqlclose $db
foreach c {0 1 2 3 4 5 6 7 8} {
puts \nPurge-AK$c:[get [post $wiki {*}$format / action purge / titles [join [lrange $ll2b [append c 00] [incr c 99]] |] / forcelinkupdate 1]]
}
set db [get_db dewiki]
mysqlreceive $db {
	select page_title
	from page
	where page_title like 'Adminwiederwahl/%' and page_namespace = 4
;} pt {
	lappend ll2c Wikipedia:[sql -> $pt]
}
mysqlclose $db
puts \nPurge-AWW:[get [post $wiki {*}$format / action purge / titles [join $ll2c |] / forcelinkupdate 1]]

set c3 [conts t Benutzer:AsuraBot/Purges 3]
set ll3 [dict values [regexp -all -inline -line -- {^\* \[\[[:]?(.*?)[|\]].*$} $c3]]
foreach l3 $ll3 {
	if {[string first Hauptseite/ $l3] == -1} {lappend nll3 $l3}
}
set db [get_db dewiki]
mysqlreceive $db {
	select pl_title
	from pagelinks
	where pl_from = 8395013 and pl_from_namespace = 2 and pl_namespace = 4 and pl_title like 'Hauptseite/%' and pl_title != 'Hauptseite/Heute' and pl_title != 'Hauptseite/morgen'
;} pt {
	lappend nll3 Wikipedia:[sql -> $pt]
}
mysqlclose $db
puts \nPurge-HS:[get [post $wiki {*}$format / action purge / titles [join $nll3 |] / forcerecursivelinkupdate 1]]\n

set c4 [conts t Benutzer:AsuraBot/Purges 4]
set ll4 [dict values [regexp -all -inline -line -- {^\* \[\[[:]?(.*?)[|\]].*$} $c4]]
set lpid {}
foreach l4 $ll4 {
	lappend lpid [scat [join $l4] -14]
}
lassign {} plpid lplpid
foreach pid [join $lpid] {
	incr i
	lappend plpid $pid
	if {$i == 500} {
		lappend lplpid $plpid
		lassign {0 {}} i plpid
	}
}
lappend lplpid $plpid
foreach plpid $lplpid {
	puts Purge4:[get [post $wiki {*}$format / action purge / pageids [join $plpid |] / forcelinkupdate 1]]
}

