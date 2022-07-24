#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot log-mineral.tcl] > 1} {exit}}

source api2.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

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
						set rv [encoding convertfrom [page [post $wiki {*}$query / revids $id / prop revisions / utf8]]]
						set rvdata [join [dict get $rv revisions]]
#Arbeitsbereich
if {[expr [clock seconds] - $t1] > 3600} {exit}
if {[incr i] in {1 100}} {
	unset -nocomplain lmineral
	cont {ret1 {
		foreach item [embeddedin $ret1] {lappend lmineral [dict get $item title]}
	}} {*}$embeddedin / eititle {Vorlage:Infobox Mineral}
}
if {[set title [dict get $rv title]] in $lmineral} {
	dict with rvdata {
		set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Mineral:''' \[\[:de:$title|$title\]\] -- \
			\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
				regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
			]''" : {}}]"
	}
	set lang test ; source langwiki.tcl ; #set token [login $wiki]
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: Mineral} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl ; #set token [login $wiki]
}
#Arbeitsbereich
					}] {continue}
				}
				set ocurid $curid
			}
		}}
		unset -nocomplain llogid
		foreach log $llog {lappend llogid [dict get $log logid]}
	}
}

