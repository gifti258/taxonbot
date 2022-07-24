#!/usr/bin/tclsh8.7

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set date "$cal(year) I[expr {[string trimleft $cal(month) 0] > 6?{I}:{}}]"

set i -1

foreach block [set blocks [join [content [post $wiki {*}$get / titles [set title Benutzer:Luke081515Bot/Warteschlange/Auftraege]]]]] {
	lappend blocklists [lreplace [split $block |=] 0 0]
}

foreach blocklist $blocklists {
	if {[dict get $blocklist STATUS] in {e f n u}} {
		if {[incr j] > 5} {
			lappend archblocklists "{{[lindex $blocks [incr i]]}}"
		} else {
			lappend stayblocklists "{{[lindex $blocks [incr i]]}}"
		}
	} else {
		lappend stayblocklists "{{[lindex $blocks [incr i]]}}"
	}
}

if [exists archblocklists] {
   puts \n[edit $title/Archiv/$date {Archivierung} {} / prependtext [join $archblocklists \n]\n]
   puts \n[edit $title "Archivierung nach \[\[$title/Archiv/$date\]\]" [join $stayblocklists \n]]\n
}
