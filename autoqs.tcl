#!/usr/bin/tclsh8.7
#exit

source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

package require http
package require tls
package require tdom

proc indent {nr s} {
	global ~ new
	switch $s {
		f			{set text {false positive}}
		g			{set text {URV-Versionen versteckt}}
		i			{set text {Artikelversionen nachimportiert}}
		k			{set text {keine URV}}
		n			{lappend new $nr ; return {}}
		o			{set text {VRTS: Ticket zur Textfreigabe liegt vor}}
		s			{set text {Schöpfungshöhe der Textübernahme nicht ausreichend}}
		u			{set text {umgekehrte URV}}
		v			{set text {URV-Versionen versteckt}}
		z			{set text {Zitat innerhalb maximaler Größe bei Nennung der Quelle}}
		default	{return $nr}
	}
	if {[string first <s> $nr] == -1} {
		regsub -- {\[\[.*?\]\]} $nr {<s>&</s>} nr
	}
	return "$nr\n#:[lindex [regexp -all -inline -- {#(:.*?)[^:]} $nr] end] $text ${~}"
}

set nconts [set oconts [conts id 6535923 [expr 4+$argv]]]
set nconts [string map {#: $$} $nconts]
set nconts [string map [list \n# Ъ] $nconts]
set nconts [split $nconts Ъ]
set nconts [string map {$$ #:} $nconts]
set i -1
foreach line $nconts {
	lappend dline [incr i] $line
}
dict lappend dline new {}
while 1 {
	dict with dline {
		foreach {i line} $dline {
			if {$line ne {}} {
				puts "\n$i: $line"
			} else {
				unset -nocomplain $i
			}
		}
		input nr "\nNr.: "
		if {[empty nr] || !$nr} {
			puts \n
			break
		} else {
			puts \n[set $nr]
			input s "\nAuswahl: "
			set $nr [indent [set $nr] $s]
		}
	}
}
foreach {nr line} $dline {
	if {$nr eq {new} && $line ne {}} {
		set new [join $line \n#]
	} else {
		lappend lline $line
	}
}
set nconts [join $lline \n#]
#puts $nconts\n\nnew:$new
gets stdin
if {[conts id 6535923 [expr 4+$argv]] eq $oconts} {
	puts [edid 6535923 {URV-Fälle abgearbeitet} [string map [list $oconts $nconts] [conts id 6535923 x]]$new]
}

