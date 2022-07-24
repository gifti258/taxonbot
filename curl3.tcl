# curl.tcl Library

# Accessing TclCurl – Low-level Access to the MediaWiki API

# Copyright 2010, 2011, 2012 Giftpflanze

# This file is part of the MediaWiki Tcl Bot Framework.

# The MediaWiki Tcl Bot Framework is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

package require TclCurl
package require unicode
#source /usr/lib/tcltk/TclCurl7.22.0/tclcurl.tcl

# Test if variable exists in caller scope (standard)
# Use #0 for level to test in the global scope
proc exists {var {level 1}} {
	return [expr {$var in [uplevel $level {info vars}]}]
}

# Put debug information if debug is set (exists)
proc debug {proc} {
	if [exists debug #0] {
		uplevel $proc
	}
}

# API call wrapper
# call: post $handle / param1 value1 / param2 value2 ...
proc post {handle args} {
	global headers errorCode errorInfo
	foreach {/ name value} $args {
		lappend pairs "[curl::escape $name]=[curl::escape $value]"
	}
	control::do {
		array unset headers
		$handle configure -postfields [join $pairs &] -bodyvar body
		while {
			[catch {$handle perform}] && $errorCode eq {NONE}
		} {
			puts "[clock format [clock seconds] -format %Y-%m-%d-%T]: catch 35"; puts $errorInfo; $handle configure -verbose 1; after 1000
		}
	} while {![catch {
		after [expr {[set replag $headers(Retry-After)]*1000}]
		puts "replag: ${replag}s"
	}]}
	if {[lindex $headers(http) 1] ne 200} {
		puts $args
		if {[string first {action login} $args] > -1} {goto c}
		puts $body
	} else {
		debug {
			puts $args
			puts $body
		}
	}
	return $body
}

proc post2 {handle args} {
	global headers errorCode errorInfo
	foreach {/ name value} $args {
		lappend pairs "[curl::escape $name]=[curl::escape $value]"
	}
	control::do {
		array unset headers
		$handle configure -postfields [join $pairs &] -bodyvar body
		while {
			[catch {$handle perform}] && $errorCode eq {NONE}
		} {
			puts "[clock format [clock seconds] -format %Y-%m-%d-%T]: catch 35"; puts $errorInfo; $handle configure -verbose 1; after 1000
		}
	} while {![catch {
		after [expr {[set replag $headers(Retry-After)]*1000}]
		puts "replag: ${replag}s"
	}]}
	if {[lindex $headers(http) 1] ne 200} {
		puts $args
		if {[string first {action login} $args] > -1} {goto c}
		puts $body
	} else {
		debug {
			puts $args
			puts $body
		}
	}
	return [encoding convertfrom [encoding convertfrom [encoding convertto $body]]]
}

proc export {lang wiki title} {
   global self email
   curl::transfer \
   -useragent "$self@$lang.$wiki <$email> - MediaWiki Tcl Bot Framework 0.5" \
   -encoding all \
   -cookiefile cookies \
   -url https://$lang.$wiki.org/w/index.php?title=Special:Export&history \
   -postfields [join [lmap {a b} [list pages $title wpDownload] {join [list $a [curl::escape $b]] =}] &] \
   -bodyvar body
   return $body

}

# Get API handle
proc get_handle {lang wiki wikiurl} {
	global self email format password
	upvar #0 login login
	[set handle [curl::init]] configure \
	-useragent "$self@$lang.$wiki <$email> – MediaWiki Tcl Bot Framework 0.5" \
	-encoding all \
	-cookiefile cookies \
	-url $wikiurl/api.php \
	-sslverifypeer 0 \
	-sslsessionidcache 0 \
	-headervar headers \
	-verbose 0
	set login($handle) [list {*}$format / action login / lgname $self / lgpassword $password]
	return $handle
}


if {{string} ni [info procs]} {
	rename string string_original
}

proc string {subcommand args} {
    switch $subcommand {
        range {
            unicode::tostring [lrange [lmap item [unicode::fromstring [lindex $args 0]] {if [llength $item] {set item} continue}] {*}[lrange $args 1 end]]
        }
        default {
            string_original $subcommand {*}$args
        }
    }
}

return
