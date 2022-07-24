#!/usr/bin/tclsh8.7

catch {if {[exec pgrep -cxu taxonbot recent.tcl] > 1} {exit}}

source api.tcl ; set lang test ; source langwiki.tcl ; #set token [login $wiki]

set blacklist {log-log.out log-mineral.out ld.out c-uncat.out}
set oconts [conts id 63277 4]
foreach out [glob *.out] {
	set c [read [set f [open $out r]]] ; close $f
	if {[conts id 63277 4] eq $oconts && [string first recent $c] > -1 && [string first "Recent: $out" $oconts] == -1} {
		if {$out eq {recent.out}} {
			exec rm recent.out
		} elseif {$out ni $blacklist} {
			if ![exists token] {set token [login $wiki]}
			puts [edid 63277 "Log: Recent ($out)" {} / appendtext "\n* <span style=\"color:red\">'''[
				utc <- seconds {} %Y-%m-%dT%TZ {}
			] Recent: $out\!'''</span>"]
		}
	}
	if {[conts id 63277 4] eq $oconts && [string first editconflict $c] > -1 && [string first "Edit conflict: $out" $oconts] == -1} {
		if {$out eq {recent.out}} {
			exec rm recent.out
		} elseif {$out ni $blacklist} {
			if ![exists token] {set token [login $wiki]}
			puts [edid 63277 "Log: Edit conflict ($out)" {} / appendtext "\n* <span style=\"color:red\">'''[
				utc <- seconds {} %Y-%m-%dT%TZ {}
			] Edit conflict: $out\!'''</span>"]
		}
	}
}
