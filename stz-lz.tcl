#!/usr/bin/tclsh8.7
#exit

set editafter 1

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source library.tcl
set db [get_db dewiki]

package require http
package require tls
package require tdom

if 0 {
set html [getHTML https://persondata.toolforge.org/vorlagen/?tmpl=Nowrap&value=+%24&value_op=rx&with_wl&show_param&show_value]

puts $html

set lpt [dict values [regexp -all -inline -- {\<a .*?>(.*?)\</a\>} $html]]
foreach pt $lpt {
	if {[string first RedPencil $pt] == -1} {
		lappend nlpt $pt
	}
}
set nlpt [lrange $nlpt 9 end-5]
puts [llength $nlpt]:$nlpt
}

set lpt [insource {\[https?:\/\/[^\]' ]*''[^\]' ]*''/} $argv]

proc rc2 u {
	global pt c
	set lrc [regexp -all -inline -line -nocase -- [format {\[%s.*?[ \]].*?[a-z\n].*?[\s\n]} $u] $c]
#	puts $lrc\n====\n
	set lnrc {}
	foreach rc $lrc {
#puts $rc
		unset -nocomplain nrc
#		puts $rc\n----\n
#		set nrc [regsub -all -- { } $rc ʃ]
		if {[string first '' $rc] == -1} {continue}
		if {[string first f=false $rc] > -1} {
#			set rc [lindex $rc 0]
			set brc [string map [list \'\' \" \' \"] [lindex $rc 0]]
			set bnrc [string map [list [lindex $rc 0] $brc] $rc]
		} else {
			set bnrc $rc
		}
		set nrc [string map [list	"\'\'\]" "\'\'\]" \
											"\'\'.\]" ".\'\'\]" \
											"|\'\'" " \'\'" \
											"  \'\'" " \'\'" \
											"   \'\'" " \'\'" \
											" \'\'" " \'\'"] $bnrc]
		regsub -- {(\S)\s?''\s?} $nrc {\1 ''} nrc
		set nrc [string map {false"Digitalisat" {false ''Digitalisat''}} $nrc]
		set nrc [string map {{( ''} (''} $nrc]
if 0 {
		set nrc [string map [list "   \}\}" "\}\}" \
		                          "   \}\} " "\}\} " \
		                          "   \}\}\}" "\}\}\}" \
		                          "   \}\})" "\}\})" \
		                          "   \}\}\'" "\}\}\'" \
		                          "   \}\}<" "\}\}<" \
		                          "   \}\}" "\}\} " \
		                          "  \}\} " "\}\} " \
		                          "  \}\}\}" "\}\}\}" \
		                          "  \}\})" "\}\})" \
		                          "  \}\}\'" "\}\}\'" \
		                          "  \}\}<" "\}\}<" \
		                          "  \}\}" "\}\} " \
		                          " \}\} " "\}\} " \
		                          " \}\}\}" "\}\}\}" \
		                          " \}\})" "\}\})" \
		                          " \}\}\'" "\}\}\'" \
		                          " \}\}<" "\}\}<" \
		                          " \}\}" "\}\} "] $rc]
}
#		lappend lnrc $rc [string trimright $nrc]
		if {$nrc ne $rc} {
			lappend lnrc $rc $nrc
		}
	}
	puts \n\n\n\n\n$pt\n====\n->[join $lnrc "\n->"]\n====\n
	return $lnrc
#	return $lrc
}

proc rc u {
	global zq pt c
	set lrc [regexp -all -inline -- [format {.{0,40}\u%s.{0,80}} $u] $c]
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

set zq {Bot: Weblink repariert: Leerzeichen eingefügt}
set zq1 {Weblink repariert: Leerzeichen eingefügt}
set nlist [list \u007f {&nbsp;} \u00a0 {&nbsp;} \u2004 {&nbsp;} \u2005 {&nbsp;} \u2006 {&nbsp;} \u2007 {&nbsp;} \u2008 {&nbsp;} \u200b {&nbsp;} \u200e {&nbsp;} \u200f {&nbsp;} \u2028 {&nbsp;} \u202a {&nbsp;} \u202c {&nbsp;} \u202d {&nbsp;} \ufeff {&nbsp;}]
set llist [list \u007f { } \u00a0 { } \u2004 { } \u2005 { } \u2006 { } \u2007 { } \u2008 { } \u200b { } \u200e { } \u200f { } \u2028 { } \u202a { } \u202c { } \u202d { } \ufeff { }]
set elist [list \u007f {} \u00a0 {} \u2004 {} \u2005 {} \u2006 {} \u2007 {} \u2008 {} \u200b {} \u200e {} \u200f {} \u2028 {} \u202a {} \u202c {} \u202d {} \ufeff {}]
set clist [list " \u007f " { } " \u00a0 " { } " \u2004 " { } " \u2005 " { } " \u2006 " { } " \u2007 " { } " \u2008 " { } " \u200b " { } " \u200e " { } " \u200f " { } " \u2028 " { } " \u202a " { } " \u202c " { } " \u202d " { } " \ufeff " { }]

#set html [getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=bots&id=16]

#set lpt [lrange [split [lindex [[[dom parse -html [getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=bots&id=16]] documentElement] asList] 2 1 2 0 2 0 1] \n] 1 end-1]

#set lpt {{Let’s Dance (Fernsehsendung)}}
foreach pt $lpt {
#	set pt {Rosmonda d’Inghilterra}
	puts \n----
	set c [conts2 t $pt x]

#	foreach u {007f 00a0 2004 2005 2006 2007 2008 200b 200e 200f 2028 202a 202c 202d feff} {
#		lappend lu [rc2 $u]
#	}
	set u http
set nc [string map [rc2 $u] $c]
#set snc [split $nc \n]
#foreach line $snc {lappend ljnc [string trimright $line]}
#set nc [join $ljnc \n]
#puts $nc
if 0 {
if {[string first Film $pt] > -1} {
	set nl j
} else {
	input nl "\nersetzen oder nicht? "
}
}
	puts [incr i]/[llength $lpt]
	input nl "\nersetzen oder nicht? "
	if {$nl ne {n}} {
		set out [edit $pt $zq $nc / minor]
		puts $out
		if {{protectedpage} in [split $out]} {
			source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
			puts [edit $pt $zq1 $nc / minor]
			after 15000
			source api.tcl ; set lang de ; source langwiki.tcl; #set token [login $wiki]
		}
	}

if 0 {
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

}

#	getHTML https://tools.wmflabs.org/checkwiki/cgi-bin/checkwiki.cgi?project=dewiki&view=only&id=16&title=[curl::escape $pt]
}

