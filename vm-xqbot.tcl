#!/usr/bin/tclsh8.7

#set editafter 1

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
#set db [get_db dewiki]

#package require http
#package require tls
#package require tdom

set wpvm Wikipedia:Vandalismusmeldung
set lsect [get [post $wiki {*}$format / action parse / page $wpvm] parse sections]
foreach sect $lsect {
	dict with sect {
		if {[string first Benutzer $line] > -1 && [string first (erl.) $line] == -1} {
			puts $sect
			set sectconts [conts t $wpvm $index]
			puts $sectconts
			if {[string first TaxonBota $sectconts] == -1} {
				set firstline [string trim [lindex [split $sectconts \n] 0]]
				if {[string first == $firstline] == -1} {continue}
				puts $firstline
				regexp -- {(Benutzer.*?)\]\]} $sectconts -- rexuser
				set rexuser [string map {{Benutzer: } Benutzer: {Benutzerin: } Benutzerin:} $rexuser]
				puts $rexuser
				set lblock [get [post $wiki {*}$format / action query / list logevents / leprop title|user|timestamp|comment|details / leaction block/block / lelimit 100] query logevents]
				foreach block $lblock {
					dict with block {
						if {$title eq $rexuser} {
							puts $title
							puts $block
							set nfirstline [string map {{  } { }} "[string range $firstline 0 end-2] (erl.) =="]
							puts $nfirstline
							set dur [dict get $params duration]
							if {$dur eq {infinite}} {
								set dur {''unbeschränkt''}
							} else {
								set dur "für ''[string map {seconds Sekunden second Sekunde minutes Minuten minute Minute hours Stunden hour Stunde days Tage day Tag months Monate month Monat years Jahre year Jahr} [dict get $params duration]]''"
							}
							puts $dur
							set finish "\{\{StrichBeidseitig|1=[lindex [split $rexuser :] 1] wurde von <span class=\"plainlinks\">\[\{\{canonicalurl:User:$user\}\} $user\]</span> $dur gesperrt, Begründung war: ''$comment''. ${~}\}\}"
							puts $finish
							set summary "Bot: /* $line (erl.) */ erledigt"
							puts $summary
							set oconts [conts t $wpvm $index]
							set nconts $oconts\n$finish
							set vmconts [string map [list $oconts $nconts] [conts t $wpvm x]]
							set vmconts [string map [list $firstline $nfirstline] $vmconts]
							puts $vmconts
#							gets stdin
							puts [edit $wpvm $summary $vmconts / minor]
						}
					}
				}
			}
		}
	}
}

