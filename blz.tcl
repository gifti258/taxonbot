#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

package require http
package require tls
package require tdom

#puts $db

#save_file blz.db $db

proc r {s e} {
	global d
	if {$s < 0} {set s end$s}
	if {$e < 0} {set e end$e}
	return [string range $d $s $e]
}

set blob [lindex [
	regexp -inline -line -- {.*/blob/(\d{6})/.*?\.txt.*} [
		getHTML https://www.bundesbank.de/de/aufgaben/unbarer-zahlungsverkehr/serviceangebot/bankleitzahlen/download-bankleitzahlen-602592
	]
] end]
set db [getHTML https://www.bundesbank.de/resource/blob/$blob/latest/mL/blz-aktuell-txt-data.txt]
if {[string first {404 - File not found} $db] > -1} {
	set lang test ; source langwiki.tcl ; #set token [login $wiki]
	puts [edid 63277 "Log: BLZ" {} / appendtext "\n* <span style=\"color:red\">'''[utc <- seconds {} %Y-%m-%dT%TZ {}] BLZ: !ERROR!'''</span>"]
	exit
}

foreach d [split [string trim $db] \n] {
#puts $d
	unset -nocomplain ds blz bic pds
#puts id8:[string range $d 5 10]
	if {[string index $d 8] != 1} {continue}
	set ds  [r -16 -11]
	set blz [r 0 7]
	set bic [r -29 -26]\ [r -25 -22]\ [r -21 -19]
	set pds [r -34 -30]
	lappend ld |$ds\BLZ=$blz|$ds\BIC=$bic|$pds\DS=$ds
#puts \n\n|$ds\BLZ=$blz|$ds\BIC=$bic|$pds\DS=$ds
#gets stdin
}

set c [conts t {Vorlage:Infobox Kreditinstitut/DatenDE} x]
regsub -- {(<!--SUBSTER-DatenDE-->).*<!--SUBSTER-DatenDE-->} $c \\1[join $ld \n]\\1 c
#puts $c ; exit
puts [edit {Vorlage:Infobox Kreditinstitut/DatenDE} {Bot: Aktualisierung der Daten} $c / minor]
