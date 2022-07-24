#!/usr/bin/tclsh8.7
#exit

set editafter 1

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

package require http
package require tls
package require tdom

proc rc u {
	global zq pt c
	set lrc [regexp -all -inline -- [format {.{0,40}\u%s.{0,40}} $u] $c]
	set crc [regexp -all -- [format {\u%s} $u] $c]
	if {$lrc ne {}} {
		switch $u {
			007f {set lu Delete}
			00a0 {set lu NoBackSpace}
			2004 {set lu ThreePerEmSpace}
			2005 {set lu FourPerEmSpace}
			2006 {set lu SixPerEmSpace}
			2007 {set lu FigureSpace}
			2008 {set lu PunctuationSpace}
			200b {set lu ZeroWidthSpace}
			200e {set lu LeftToRightMark}
			200f {set lu RightToLeftMark}
			2028 {set lu LineSeparator}
			202a {set lu LeftToRightEmbedding}
			202c {set lu PopDirectionalFormatting}
			202d {set lu LeftToRightOverride}
			feff {set lu ZeroWidthNo-BreakSpace}
		}
		puts "\n> $crc $lu: $pt:\n"
		foreach rc $lrc {
			puts [regsub -all -- [format {\u%s} $u] $rc ʃ]
		}
		return $u
	} else {
		return {}
	}
}

set zq {Bot: Steuerzeichen ersetzt}
set nlist [list \u007f {&nbsp;} \u00a0 {&nbsp;} \u2004 {&nbsp;} \u2005 {&nbsp;} \u2006 {&nbsp;} \u2007 {&nbsp;} \u2008 {&nbsp;} \u200b {&nbsp;} \u200e {&nbsp;} \u200f {&nbsp;} \u2028 {&nbsp;} \u202a {&nbsp;} \u202c {&nbsp;} \u202d {&nbsp;} \ufeff {&nbsp;}]
set llist [list \u007f { } \u00a0 { } \u2004 { } \u2005 { } \u2006 { } \u2007 { } \u2008 { } \u200b { } \u200e { } \u200f { } \u2028 { } \u202a { } \u202c { } \u202d { } \ufeff { }]
set elist [list \u007f {} \u00a0 {} \u2004 {} \u2005 {} \u2006 {} \u2007 {} \u2008 {} \u200b {} \u200e {} \u200f {} \u2028 {} \u202a {} \u202c {} \u202d {} \ufeff {}]
set clist [list " \u007f " { } " \u00a0 " { } " \u2004 " { } " \u2005 " { } " \u2006 " { } " \u2007 " { } " \u2008 " { } " \u200b " { } " \u200e " { } " \u200f " { } " \u2028 " { } " \u202a " { } " \u202c " { } " \u202d " { } " \ufeff " { }]

#set html [getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=bots&id=16]

set lpt [lrange [split [lindex [[[dom parse -html [getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=bots&id=16]] documentElement] asList] 2 1 2 0 2 0 1] \n] 1 end-1]

foreach pt $lpt {
	puts \n----
	set c [conts2 t $pt x]

	foreach u {007f 00a0 2004 2005 2006 2007 2008 200b 200e 200f 2028 202a 202c 202d feff} {
		lappend lu [rc $u]
	}

	set slu [lsort -unique [join $lu]]
	puts \n$slu

	if {$slu in {007f 200b 200e 200f 2028 202a 202d feff}} {
		set nl e ; puts {}
	} elseif {$slu in {2004 2005 2006}} {
		set nl l ; puts {}
	} elseif {$slu eq {2007}} {
		set nl {} ; puts {}
	} else {
		if [empty slu] {
			puts "\nkein Steuerzeichen gefunden: $pt"
		}
		input nl "\n&nbsp;/Leerzeichen/empty/cut? "
	}

	switch $nl {
		n			{puts [edit $pt $zq [string map $nlist $c] / minor]\n}
		l			{puts [edit $pt $zq [string map $llist $c] / minor]\n}
		e			{puts [edit $pt $zq [string map $elist $c] / minor]\n}
		c			{puts [edit $pt $zq [string map $clist $c] / minor]\n}
		default	{}
	}

	unset -nocomplain lu

	getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=only&id=16&title=[curl::escape $pt]
}

