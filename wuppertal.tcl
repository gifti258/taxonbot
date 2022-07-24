#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

package require tdom

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

package require http
package require tls
package require uri::urn

set i 0
set xml [[[dom parse -html [getHTML https://www.wuppertal.de/denkmalliste-online/]] documentElement] asList]

lappend dict 9414262 [string map {+ %2B = %3D} [uri::urn::quote [encoding convertto [lindex $xml 2 1 2 1 2 0 2 0 1 7]]]]
lappend dict 9414264 [string map {+ %2B = %3D} [uri::urn::quote [encoding convertto [lindex $xml 2 1 2 1 2 1 2 0 1 7]]]]
lappend dict 9414266 [string map {+ %2B = %3D} [uri::urn::quote [encoding convertto [lindex $xml 2 1 2 1 2 1 2 1 1 7]]]]

foreach {key value} $dict {
	if {[conts id $key x] ne $value} {
		puts [edid $key aktualisiert $value / minor]
		incr i
	}
}
if $i {
	set lang test ; source langwiki.tcl ; #set token [login $wiki]
	puts [edid 63277 {Log: DLWuppertal} {} / appendtext "\n* '''[
		clock format [clock seconds] -format %Y-%m-%dT%TZ
	] DLWuppertal: Aktualisierung'''"]
}
