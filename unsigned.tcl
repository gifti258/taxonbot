#!/usr/bin/tclsh8.7

#set editafter 1
exit

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db dewiki]

#package require http
#package require tls
package require tdom

puts $argv

set text {}

	set ldiff [lreverse [regexp -all -line -inline -- {.*"diff-addedline".*} [get [
		post $wiki {*}$format / action compare / fromrev $argv / torelative prev
	] compare *]]]
	foreach diff $ldiff {
		set ldom [join [lindex [join [lindex [
			[[dom parse -html $diff] documentElement] asList
		] 2]] 2]]
puts ldom:$ldom
		if {[lindex $ldom 0] eq {#text}} {
			set text [lindex $ldom 1]
			break
		}
	}
	if ![empty text] {puts $text} else {exit}

set revlist [mysqlsel $db "
	select rev_user_text, rev_timestamp from revision
	where rev_id = $argv
;" -flatlist]

puts $revlist

exit
