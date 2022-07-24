#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#package require http
#package require tls
#package require tdom

catch {if {[exec pgrep -cxu taxonbot ld.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set t1 [clock seconds]
proc lh {ldpage} {
	global llh wiki get parse ch
	set 2 {}
	catch {set lh [page [post $wiki {*}$get / prop linkshere / titles $ldpage / lhprop title / lhnamespace 4 / lhlimit max] linkshere]}
	foreach 1 $lh {
		dict with 1 {
			if {		 $title ne $ch
					&&  [string match *Wikipedia:Löschkandidaten/* $title]
					&& ![string match *Wikipedia:Löschkandidaten/Urheberrechtsverletzungen* $title]} {
				lappend 2 $title
			}
		}
	}
	set llh {}
	foreach 1 $2 {
		foreach 3 [get [post $wiki {*}$parse / page $1 / prop sections] parse sections] {
			dict with 3 {
				if [string match *$ldpage* $line] {
					set ldlemma [join [dict values [
						regexp -inline -line -- {^==.*?\[\[[:]?(.*?)(?:\|.*?)?\]\].*?==.*?$} [contents t $1 $index]
					]]]
					if {$ldlemma eq $ldpage} {lappend llh $1 $line}
				}
			}
		}
	}
	foreach {1 2} $llh {lrepl llh $1 [clock scan [lindex [split $1 /] 1] -format {%e. %B %Y} -locale de]}
	foreach {1 2} [set llh [lsort -stride 2 -integer $llh]] {
		lrepl llh $1 [string trim [clock format $1 -format  {%e. %B %Y} -locale de]]
	}
	return $llh
}

proc lddata {} {
	global wiki parse ldpage llh
	lassign [list [list {War in Löschdiskussion} Pagename=$ldpage] -1 0 0] lddata idxdate idxline idxresult
	foreach {1 2} $llh {
		set result [string trim [join [dict values [regexp -inline -- "[string map {( {\(} ) {\)}} $ldpage]\(.*\)" $2]]]]
		if {[string index $result 0] eq {(} && [string index $result end] eq {)}} {
			set result [string replace $result 0 0]
			set result [string replace $result end end]
		}
		lappend lddata [incr idxdate 2]=$1 [incr idxline 2]=$2 Result[incr idxresult]=$result
	}
	return [string map [list & \\&] \{\{[join [lappend lddata Bot=TaxonBot] |]\}\}]
}

set sect 0
while 1 {
	if {[expr [clock seconds] - $t1] > 3600} {exit}
	if {[catch {
		set ldpage {}
		set ch Wikipedia:Löschkandidaten/[string trim [
			clock format [clock seconds] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de
		]]
		set lastsect [dict get [lindex [set lsection [get [post $wiki {*}$parse / page $ch / prop sections] parse sections]] end] index]
		if {		[regexp -line -- {^=(?!=)} [set contentssect [contents t $ch [incr sect]]]]
				||	[lsearch [
						get [post $wiki {*}$parse / text $contentssect / prop templates] parse templates
					] {*Vorlage:War in Löschdiskussion*}] != -1} {
			continue
		}
		set ldpage [join [dict values [regexp -inline -line -- {^==.*?\[\[[:]?(.*?)(?:\|.*?)?\]\].*?==.*?$} $contentssect]]]
		if {[lh $ldpage] ne {}} {
			foreach section $lsection {
				if {[dict get $section index] == $sect} {
					dict with section {
						puts [edit $ch "Bot: /* $line */ war bereits Löschkandidat" [
							regsub -line -- {(^==.*?==.*?\n)} $contentssect \\1[lddata]\n
						] / section $index / minor]
						puts $ldpage
						puts [regsub -line -- {(^==.*?==.*?\n)} $contentssect \\1[lddata]\n]
					}
				}
			}
		}
	}] == 1} {
		if {$ldpage ne {}} {
			if {$ldpage eq {Spezial:Leerseite}} {continue}
			puts $ldpage:Fehler
			set lang test ; source langwiki.tcl ; #set token [login $wiki]
			puts [edid 63277 {Log: LB} {} / appendtext "\n* '''[
				clock format [clock seconds] -format %Y-%m-%dT%TZ
			] LB: Fehler bei \[\[:w:de:$ldpage\]\]!'''"]
			set lang de ; source langwiki.tcl ; #set token [login $wiki]
		}
	}
	if {$sect == $lastsect} {
		if {$ch ne {Wikipedia:Löschprüfung}} {
			set ch Wikipedia:Löschprüfung
		} else {
			set ch Wikipedia:Löschkandidaten/[string trim [
				clock format [clock seconds] -format {%e. %B %Y} -timezone :Europe/Berlin -locale de
			]]
		}
		set sect 0
	}
}
