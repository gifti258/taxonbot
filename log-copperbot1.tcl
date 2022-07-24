#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot log-copperbot.t] > 1} {exit}}

package require tdom
source api2.tcl
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
set language de
source procs.tcl


set t1 [clock seconds]
lassign {} ollog llogid
while 1 {
	set llog [lreverse [get [post $wiki {*}$logevents / lelimit 400] query logevents]]
	if {$llog ne $ollog} {
		set ollog $llog
		foreach log $llog {if {[dict get $log logid] ni $llogid} {
			set lparam [dict get $log params]
			if [catch {set curid [dict get $log params curid]}] {incr s} else {set s 0}
			if !$s {
				if ![exists ocurid] {set ocurid $curid}
				for {set id [incr ocurid]} {$id <= $curid} {incr id} {
					if [catch {
						set rv [encoding convertfrom [page [post $wiki {*}$query / revids $id / prop revisions / rvprop ids|flags|timestamp|comment|user|content / utf8]]]
						set rvdata [join [dict get $rv revisions]]
						dict with rvdata {
							dict with rv {
#Arbeitsbereich
#if {[expr [clock seconds] - $t1] > 3600} {exit}
#puts rv:$rv
#puts rvdata:$rvdata
unset -nocomplain invalid
lassign {0 {} {}} editcount groups ladd
set while 0
while 1 {if ![catch {
puts while:[incr while]
	set userprop [join [get [post $wiki {*}$format / action query / list users / ususers $user / usprop editcount|groups] query users]]
}] {break}}
dict with userprop {
	if {		({bot} ni $groups && {editor} ni $groups && {sysop} ni $groups)
			&& $ns in {1 3 4 5 7 9 11 13 15 100 101}
			&& $editcount <= 1000
			&& ![regexp -nocase -- {
					\Wrevert\W|\Wrückgängig\W|\Wzurückgesetzt\W|\Wre?v\W|\Wnosig!
				} " $comment "]
	} {
#		puts $rvdata
#		puts $rv
#		puts $*
		set diff1 [get [post $wiki {*}$format / action compare / fromrev $revid / torelative prev] compare *]
#		puts $diff1
		set ldiff [lindex [[[dom parse -html <table>$diff1</table>] documentElement] asList] 2]
		foreach trdiff $ldiff {
#			puts [lindex $trdiff 2]
			if {[lindex $trdiff 2 1 2 0 1] eq {+}} {
				lappend ladd [lindex $trdiff 2 2 2 0 2 0 1]
			}
		}
		if ![empty ladd] {puts "+: $ladd"} else {continue}
		set ats [string map {{, 0} {, } Mrz. Mär. Mai. Mai} [utc -> $timestamp %Y-%m-%dT%TZ {%R, %d. %b. %Y (%Z)} {}]]
		if [exists invalid] {
			set nickname "\[\[Spezial:Beiträge/$user|$user\]\]"
			puts nickname:$nickname
			if {[string first $nickname [string map {\\ {}} $ladd]] == -1} {
				puts ---Treffer:\n$ns\n$title\n$user\ninvalid\n$comment
				puts "\ncheck:[lindex $ladd end] \{\{subst:unsigned|$user|$ats\}\}"
				set oconts [conts t $title x]
				set nconts [string map [list [lindex $ladd end] "[lindex $ladd end] \{\{subst:unsigned|$user|$ats\}\}"] $oconts]
				puts nconts:$nconts
				input y y?
				if {$y eq {y}} {
					set bot 0
					puts [edit $title "Bot: Signaturnachtrag für Beitrag von \[\[Spezial:Beiträge/$user|$usery\]\]: \"$comment\"" $nconts / minor]
					set bot 1
				}
			} else {
				puts continue ; continue
				puts ---kein\ Treffer:\n$ns\n$title\n$user\ninvalid\n$comment
			}
			gets stdin
#			puts $content
		} else {
			if {[set nickname [nickname $user]] eq {}} {
				set gender Benutzer[expr {[gender $user] eq {female} ? {in} : {}}]
				set nickname "\[\[$gender:$user|$user\]\] (\[\[$gender Diskussion:$user|Diskussion\]\])"
			}
			if [regexp -all -nocase -- {\{\{ers:|\{\{subst:} $nickname] {continue}
			puts nickname:$nickname
			if {[string first $nickname [string map {\\ {}} $ladd]] == -1} {
				puts ---Treffer:\n$ns\n$title\n$user\n$editcount\n$groups\n$comment
				puts "\ncheck:[lindex $ladd end] \{\{subst:unsigned|$user|$ats\}\}"
				set oconts [conts t $title x]
				set nconts [string map [list [lindex $ladd end] "[lindex $ladd end] \{\{subst:unsigned|$user|$ats\}\}"] $oconts]
				puts nconts:$nconts
				input y y?
				if {$y eq {y}} {
					set bot 0
					puts [edit $title "Bot: Signaturnachtrag für Beitrag von \[\[Benutzer:$user|$user\]\]: \"$comment\"" $nconts / minor]
					set bot 1
				}
			} else {
				puts continue ; continue
				puts ---kein\ Treffer:\n$ns\n$title\n$user\n$editcount\n$groups\n$comment
			}
			gets stdin
		}
	}
}
#Arbeitsbereich
							}
						}
					}] {continue}
				}
				set ocurid $curid
			}
		}}
		unset -nocomplain llogid
		foreach log $llog {lappend llogid [dict get $log logid]}
	}
}

