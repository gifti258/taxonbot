#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot ldw.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set t1 [clock seconds]
set matchtempl {Vorlage:War Löschkandidat|Vorlage:Wurde erneut behalten}
while 1 {
	if {[expr [clock seconds] - $t1] > 3600} {exit}
	if {[catch {
		contents t Wikipedia:Löschkandidaten 2
		set lldp [dict values [regexp -all -line -inline -- {^\* \[\[(Wikipedia:Löschkandidaten/.*?)\|} $contents]]
		if {[set 1 [dict values [regexp -all -line -inline -- {^\* \[\[/(.*?)\|} $contents]]] ne {}} {
			foreach 2 $1 {
				lappend lldp Wikipedia:Löschkandidaten/[join $2]
			}
		}
		foreach ldp $lldp {
			set ldpdate [lindex [split $ldp /] 1]
			set lsect [get [post $wiki {*}$parse / page $ldp / prop sections] parse sections]
			foreach sect $lsect {
				if {[catch {dict with sect {
					if {[string is digit $index] && [string match *(bleibt* $line]} {
						set ldpage [join [dict values [
							regexp -inline -line -- {^==.*?\[\[[:]?(.*?)(?:\|.*?)?\]\].*?==.*?$} [contents t $ldp $index]
						]]]
						set p [get [post $wiki {*}$get / prop info / titles $ldpage] query pages]
						lassign [list [dict keys $p] [dict get [join [dict values $p]] ns]] kp vp
						set d [dict keys [get [post $wiki {*}$get / prop info / titles talk:$ldpage] query pages]]
						if {$line eq "$ldpage (bleibt)"} {
							set templ "\{\{War Löschkandidat|$ldpdate\}\}"
						} else {
							set templ "\{\{War Löschkandidat|$ldpdate|$line\}\}"
						}
						if {$line eq "$ldpage (bleibt)"} {set checktempl "\{\{War Löschkandidat|$ldpdate"} else {continue}
						if {$kp == -1 || $vp != 0} {continue}
						if {![missing $ldpage] && ![redirect $ldpage]} {
							if {$d == -1} {
								puts [edit talk:$ldpage {Bot: Artikel war Löschkandidat} $templ / minor]
							} elseif {		![string match -nocase *$checktempl* [
													set contents [string map {1= {}} [contents t talk:$ldpage x]]
												]]
											&& ![string match -nocase {*\{\{Wurde erneut behalten*} $contents]} {
								puts [edit talk:$ldpage {Bot: Artikel war Löschkandidat} {} / prependtext $templ\n\n / minor]
							}
						}
					}
				}}] == 1} {puts $line:Fehler! ; gets stdin ; continue}
			}
		}
	}] == 1} {puts $ldpage:ü-Fehler! ; exit}
}

