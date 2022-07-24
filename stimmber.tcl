#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#package require http
#package require tls
#package require tdom

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

#contents t {WP:Checkuser/Wahl/September 2016/Perrak} x

#puts $contents

input start "start (ME(S)Z): "
input page "page: "
set page [string map {bk Wikipedia:Bürokratenkandidaturen osk Wikipedia:Oversightkandidaturen ak Wikipedia:Adminkandidaturen mini Wikipedia:Miniaturenwettbewerb sw Wikipedia:Schreibwettbewerb} $page]

set a [expr 365 * 24 * 60 * 60]
set m [expr 62 * 60 * 60]
set ts [clock scan $start -format %Y%m%d%H%M%S]
#set luser [links $page 2|3]

set db [get_db dewiki]
mysqlreceive $db "
	select pl_title
	from pagelinks join page on page_id = pl_from
	where page_title = '[sql <- [string map {Wikipedia: {}} $page]]' and page_namespace = 4 and pl_from_namespace = 4 and pl_namespace in (2,3)
;" plt {
puts $plt
	lappend luser user:[sql -> [lindex [split $plt /] 0]]
}
mysqlclose $db
#foreach 1 $luser {
#	if {[string first / $1] > -1} {lremove luser $1}
#}

set 1s {}
foreach 1 [lsort -unique $luser] {
if {$1 eq {user:Ijbond}} {continue}
	if {[string first / $1] > -1} {continue}
	if [redirect $1] {
		puts "\nRedirect: $1 to [set 1 [dict get [join [get [post $wiki {*}$query / titles $1 / redirects] query redirects]] to]]"
	}
	set 1 [string map -nocase {User: {} {User talk:} {} Benutzer: {} Benutzerin: {} {Benutzer Diskussion:} {} {Benutzerin Diskussion:} {}} $1]
	if {$1 in $1s} {continue}
	puts \n$1
	lappend 1s $1
	set uc1 [get [post $wiki {*}$query / list usercontribs / ucuser $1 / ucdir newer / uclimit 1] query usercontribs]
	if {[expr $ts - [clock scan [dict get [join $uc1] timestamp] -format %Y-%m-%dT%TZ -timezone :Europe/Berlin]] < $m} {
		puts "\a----\nnicht stimmberechtigt" ; gets stdin
		continue
	}
	set uc [get [post $wiki {*}$query / list usercontribs / ucuser $1 / ucnamespace 0 / ucstart $start / uclimit 200] query usercontribs]
	lassign {0 {} 0} i l sber
	foreach 2 $uc {
		dict with 2 {
			lappend l [list [incr i] [clock scan $timestamp -format %Y-%m-%dT%TZ -timezone :Europe/Berlin]]
		}
	}
	if {$i == 200} {
		if {[expr $ts - [dict values [lindex $l 49]]] < $a} {incr sber}
	}
	if !$sber {puts "\a----\nnicht stimmberechtigt" ; gets stdin}
}
