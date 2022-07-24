#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

if {[exec pgrep -cxu taxonbot qs-rc.tcl] > 1} {exit}

source api2.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

lassign {} ollog llogid
while 1 {
	set llog [lreverse [get [post $wiki {*}$logevents / lelimit 1500] query logevents]]
	if {$llog ne $ollog} {
		set ollog $llog
		foreach log $llog {if {[dict get $log logid] ni $llogid} {
			set lparam [dict get $log params]
			if [catch {set curid [dict get $log params curid]}] {incr s} else {set s 0}
			if !$s {
				if ![exists ocurid] {set ocurid $curid}
				for {set id [incr ocurid]} {$id <= $curid} {incr id} {
					if [catch {
						set rv [page [post $wiki {*}$query / revids $id / prop revisions]]
						set rv [join [list [lreplace $rv end-1 end] [join [dict get $rv revisions]]]]
						dict with rv {
#Arbeitsbereich
if ![ns $title] {
	set ts [clock format [clock scan $timestamp -format %Y-%m-%dT%TZ] -format %Y%m%d-%H]
	set tsfirst [clock scan [dict get [join [
		page [post $wiki {*}$query / prop revisions / titles $title / rvdir newer / rvlimit 1] revisions
	]] timestamp] -format %Y-%m-%dT%TZ]
	if {[expr [clock seconds] - $tsfirst] < 14400 || [string first verschob $comment] > -1} {
		puts \n$title:
		set f [open qs-rc/qs-rc$ts a] ; puts $f $title ; close $f
	}
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

