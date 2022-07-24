#!/usr/bin/tclsh8.7
#exit

source api2.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
#set db [get_db dewiki]

#package require http
#package require tls
#package require tdom
foreach x {00 01 02 03 04 05 06 07 08 09 10 11 12 13} {
	while 1 {
		if ![catch {
			unset -nocomplain y z
			append y 20181008$x 0000
			append z 20181008$x 5959
			lappend lrc [lreverse [get [post $wiki {*}$query {*}$format / list recentchanges / rcnamespace 0|2 / rcprop timestamp|title|ids|user|comment|loginfo / rclimit 5000 / rcstart $z / rcend $y] query recentchanges]]
		}] {break} else {puts 1}
	}
}
puts [join $lrc]
puts [llength $lrc]
puts [llength [join $lrc]]

#exit
		foreach rc [join $lrc] {
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
					if {![empty rcline] && $ts == 20181008} {
						set f [open rc/rc$ts.b.db a] ; puts $f $rcline ; close $f
					}
				}
				lassign {} rcline logtype logparams
		}
