#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot dwf.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

#set db [read [set f [open portal.db r]]] ; close $f
#foreach {portaldb portallemma} $db {
#	lappend dblist $portaldb [read [set f [open portal/$portaldb.db r]]] ; close $f
#}

set t1 [clock seconds]
lassign {} ollog llogid
while 1 {
	set llog [lreverse [get [post $wiki {*}$logevents / lelimit 400] query logevents]]
	if {$llog ne $ollog} {
		set ollog $llog
		foreach log $llog {if {[dict get $log logid] ni $llogid} {
#			set lparam [dict get $log params]
			if [catch {set curid [dict get $log params curid]}] {incr s} else {set s 0}
			if !$s {
				if ![exists ocurid] {set ocurid $curid}
				for {set id [incr ocurid]} {$id <= $curid} {incr id} {
					if [catch {
						set rv [page [post $wiki {*}$query / revids $id / prop revisions]]
						set rv [join [list [lreplace $rv end-1 end] [join [dict get $rv revisions]]]]
						dict with rv {
#Arbeitsbereich
#if {[expr [clock seconds] - $t1] > 3600} {exit}
if {$title eq {Wikipedia:Spiele/Drei Wünsche frei/Erfüllte Wünsche}} {
	set line [regexp -line -inline {\* \d.*} [contents t {Wikipedia:Spiele/Drei Wünsche frei/Erfüllte Wünsche} 0]]
	set snak [lrange [regexp -inline -- {\[\[(?!Datei:|File:):?([^\]]*)\].*?(\d{1,2}. (?:Januar|Jänner|Februar|Feber|März|April|Mai|Juni|Juli|August|September|Oktober|November|Dezember) \d{4})} $line] 1 2]
	set 3wt [string trim [lindex [split [lindex $snak 0] #|] 0]]
	set 3wo "\{\{Drei Wünsche frei|[lindex $snak 1 end]\}\}"
	puts $3wt:$3wo
	if {![missing $3wt] && "Diskussion:$3wt" ni [template {Drei Wünsche frei} 1]} {
		puts [edit Diskussion:$3wt {Bot: Hinweisbaustein zu [[Wikipedia:Spiele/Drei Wünsche frei|Drei Wünsche frei]] hinzugefügt} {} / prependtext $3wo\n\n / minor]
	}
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] 3WF:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl ; #set token [login $wiki]
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: 3WF} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]
}
#Arbeitsbereich
						}
					}] {continue}
				}
				set ocurid $curid
			}
		}}
		unset -nocomplain llogid
		foreach log $llog {lappend llogid [dict get $log logid]}
	}
}

