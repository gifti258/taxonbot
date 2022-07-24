#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot log-copperbot.t] > 1} {exit}}

source api2.tcl
set lang de ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl

set t1 [clock seconds]
lassign {} ollog llogid
while 1 {
	set llog [lreverse [get [post $wiki {*}$logevents / lelimit 400] query logevents]]
	if {$llog ne $ollog} {
		set ollog $llog
		foreach log $llog {if {[dict get $log logid] ni $llogid} {
			set lparam [dict get $log params]
			if [catch {set curid [dict get $log params curid]}] {incr s} else {set s 0}
			if !$s {
				if ![exists ocurid] {set ocurid $curid}
				for {set id [incr ocurid]} {$id <= $curid} {incr id} {
					if [catch {
						set rv [encoding convertfrom [page [post $wiki {*}$query / revids $id / prop revisions / utf8]]]
						set rvdata [join [dict get $rv revisions]]
						dict with rvdata {
							dict with rv {
#Arbeitsbereich
if {[expr [clock seconds] - $t1] > 3600} {exit}
#set db [get_db dewiki]
#puts $db
#set usergroup [mysqlsel $db "select ug_group from user_groups join user on ug_user = user_id where user_name = '[sql <- $user]';" -flatlist]
#puts $usergroup
#if {$ns in {1 3 4 5 7 9 11 13 15 100 101} && ({bot} ni $usergroup} || {editor} ni $usergroup || {sysop} ni $usergroup)} {puts $ns:$title:$user:$usergroup}
#if {$ns in {1 3 4 5 7 9 11 13 15 100 101}} {puts $ns:$title:$user}
#mysqlclose $db
#Arbeitsbereich
							}
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

