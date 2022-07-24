# api.tcl Library

# Providing convenience procs for the MediaWiki API

# Copyright 2010, 2011, 2012, 2014 Giftpflanze

# This file is part of the MediaWiki Tcl Bot Framework.

# The MediaWiki Tcl Bot Framework is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

#if !$tcl_interactive {
#if [exists quiet] {puts quiet} else {puts 0}
	puts \n----\n[set t [clock format [clock seconds] -format %c -locale de]]\n
	set date [lindex [split [clock format [clock seconds] -format %c -timezone :Europe/Berlin -locale de]] 0]
	foreach {cal(key) cal(val)} {year %Y month %m day %d wday %A\s hour %H min %M sec %S} {
		set cal($cal(key)) [string tolower [clock format [clock seconds] -format $cal(val) -timezone :Europe/Berlin -locale de]]
	}
	foreach {timekey timeval} {day 0 month 1 year 2} {
		set $timekey [lindex [split $date .] $timeval]
	}
#}

package require control
namespace import control::do

source curl2.tcl
source json.tcl
source params.tcl

if ![exists editafter] {set editafter 5000}

#proc login {handle} {
#	global login
#	do {
#		if {[set result [get [set ret1 [post $handle {*}$login($handle)]] login result]] eq {Throttled}} {
#			after [get $ret1 login wait]000
#		} elseif {$result ne {NeedToken}} {
#			error [get $ret1]
#		}
#	} until {$result eq {NeedToken}}
#	if {[set result [get [set ret2 [post $handle {*}$login($handle) / lgtoken [get $ret1 login token]]] login result]] eq {Throttled}} {
#		after [get $ret2 login wait]000
#		login $handle
#	} elseif {$result ne {Success}} {
#		error [get $ret2]
#	}
#	return "/ token [get_token $handle]"
#}

proc login {handle} {
	return "/ token [get-token $handle]"
}

proc get-token {handle} {
	global query
	get [post $handle {*}$query / meta tokens] query tokens csrftoken
}

proc true {script} {
	uplevel 1 $script
	return true
}

set bot true

# automated editing, reruns if logged out
# set wiki
# set token [login $wiki]
proc edit {title summary text args} {
	global wiki token put bot headers editafter
	debug {puts $title:$summary}
	do {
		set ret [get [post {*}$wiki {*}$token {*}$put / title $title / summary $summary / text $text {*}[expr $bot?{/ bot true}:{}] {*}$args]]
	} while {
		[dict exists $ret error code] &&
		[dict get $ret error code] in {badtoken unknownerror assertuserfailed} &&
		[true {set token [login $wiki]}]
	}
	#pass certain error conditions
	if {[dict exists $ret error code] && [dict get $ret error code] in {editconflict nosuchsection protectedpage missingtitle undofailure nosuchrevid articleexists}} {
		return $ret
	}
	if {![dict exists $ret edit result] || [dict get $ret edit result] ne {Success}} {
		parray headers
		error $ret
	}
	if ![dict exists $ret edit nochange] {
		after $editafter
	}
	return $ret
}

proc edid {pageid summary text args} {
	global wiki token put bot headers editafter
	do {
		set ret [get [post {*}$wiki {*}$token {*}$put / pageid $pageid / summary $summary / text $text {*}[expr $bot?{/ bot true}:{}] {*}$args]]
	} while {
		[dict exists $ret error code] &&
		[dict get $ret error code] in {badtoken unknownerror assertuserfailed} &&
		[true {set token [login $wiki]}]
	}
	#pass certain error conditions
	if {[dict exists $ret error code] && [dict get $ret error code] in {editconflict nosuchsection protectedpage missingtitle undofailure nosuchrevid articleexists}} {
		return $ret
	}
	if {![dict exists $ret edit result] || [dict get $ret edit result] ne {Success}} {
		parray headers
		error $ret
	}
	if ![dict exists $ret edit nochange] {
		after $editafter
	}
	return $ret
}


proc katedit {title summary text args} {
	global wiki token put bot headers
	if [string match *true* [contents id 9498090 x]] {puts "\n*** Bot gesperrt ***\n" ; exit}
	do {
		set ret [get [post {*}$wiki {*}$token {*}$put / title $title / summary $summary / text $text {*}[expr $bot?{/ bot true}:{}] {*}$args]]
	} while {
		[dict exists $ret error code] &&
		[dict get $ret error code] in {badtoken unknownerror assertuserfailed} &&
		[true {set token [login $wiki]}]
	}
	#pass certain error conditions
	if {[dict exists $ret error code] && [dict get $ret error code] in {editconflict nosuchsection protectedpage missingtitle undofailure nosuchrevid articleexists}} {
		return $ret
	}
	if {![dict exists $ret edit result] || [dict get $ret edit result] ne {Success}} {
		parray headers
		error $ret
	}
	if ![dict exists $ret edit nochange] {
		after 5000
	}
	return $ret
}

proc katedid {pageid summary text args} {
	global wiki token put bot headers
	if [string match *true* [contents id 9498090 x]] {puts "\n*** Bot gesperrt ***\n" ; exit}
	do {
		set ret [get [post {*}$wiki {*}$token {*}$put / pageid $pageid / summary $summary / text $text {*}[expr $bot?{/ bot true}:{}] {*}$args]]
	} while {
		[dict exists $ret error code] &&
		[dict get $ret error code] in {badtoken unknownerror assertuserfailed} &&
		[true {set token [login $wiki]}]
	}
	#pass certain error conditions
	if {[dict exists $ret error code] && [dict get $ret error code] in {editconflict nosuchsection protectedpage missingtitle undofailure nosuchrevid articleexists}} {
		return $ret
	}
	if {![dict exists $ret edit result] || [dict get $ret edit result] ne {Success}} {
		parray headers
		error $ret
	}
	if ![dict exists $ret edit nochange] {
		after 5000
	}
	return $ret
}


proc cont {lambda args} {
        global wiki
        upvar [lindex $lambda 0] ret
        lassign {} cont cont2
        do {
               set ret [post $wiki {*}$args / continue $cont / {*}$cont2]
               uplevel [lindex $lambda 1]
        } until {[catch {
               set cont [get $ret continue continue]
               set cont2 [lrange [get $ret continue] 0 1]
        }]}
}

proc contalt {lambda args} {
	global wiki
	lassign {} cont cont2
	do {
		set ret [post $wiki {*}$args / continue $cont / {*}$cont2]
		apply $lambda $ret
	} until {[catch {
		set cont [get $ret continue continue]
		set cont2 [lrange [get $ret continue] 0 1]
	}]}
}

#if {{string} ne [info procs] && [incr string_orig_incr] == 1} {
#	rename string string_orig
#}

#proc string {args} {
#	switch [lindex $args 0] {
#		replace {
#			return [string_orig range [lindex $args 1] 0 [expr {[expr [lindex $args 2]]-1}]][lindex $args 4][string_orig range [lindex $args 1] [expr {[expr [lindex $args 3]]+1}] end]
#		}
#		default {
#			string_orig {*}$args
#		}
#	}
#}

return

