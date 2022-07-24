#!/usr/bin/tclsh8.7
#exit

catch {if {[exec pgrep -cxu taxonbot rcnew.tcl] > 1} {exit}}

source api2.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
#set db [get_db dewiki]

#package require http
#package require tls
#package require tdom

lassign {} olrc rcline logtype logparams
while 1 {
	while 1 {
		if ![catch {
			set lrc [get [post $wiki {*}$query {*}$format / list recentchanges / rcnamespace 0|2 / rcprop timestamp|title|ids|user|comment|loginfo / rclimit 500] query recentchanges]
		}] {break}
	}
	if {$lrc ne $olrc} {
		foreach rc [lreverse $lrc] {
			if {$rc ni $olrc} {
				dict with rc {
					if {$ns == 2 && $logtype eq {move} && ![dict get $logparams target_ns]} {
						puts $rc
						lappend rcline type $type pageid $pageid ns $ns title [dict get $logparams target_title] user $user timestamp $timestamp
					} elseif {!$ns && $type eq {new}} {
						puts $rc
						lappend rcline type $type pageid $pageid ns $ns title $title user $user timestamp $timestamp
					} else {
						lassign {} rcline logtype logparams
						continue
					}
					set ts [split $timestamp -T]
					set ts [lindex $ts 0][lindex $ts 1][lindex $ts 2]
					if {![empty rcline] && $ts == [clock format [clock seconds] -format %Y%m%d]} {
						set f [open rc/rc$ts.a.db a] ; puts $f $rcline ; close $f
					}
				}
				lassign {} rcline logtype logparams
			}
		}
		set olrc $lrc
	} else {
		continue
	}
}
