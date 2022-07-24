#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot log-log.tcl] > 1} {exit}}

source api2.tcl
set lang de ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl

#set t1 [clock seconds]
lassign {} ollog llogid
while 1 {
	set llog [lreverse [get [post $wiki {*}$logevents / lelimit 40] query logevents]]
#puts $llog
	if {$llog ne $ollog} {
		set ollog $llog
		foreach log $llog {if {[dict get $log logid] ni $llogid} {
			set lparam [dict get $log params]
#puts $log
#puts [dict get $log params 0] ; gets stdin
puts $lparam
			if {{curid} in $lparam} {
				set curid [dict get $log params curid]
				set s 0
			} else {
				if [catch {set curid [dict get $log params 0]}] {incr s} else {set s 0}
			}
puts $s
puts $curid
			if !$s {
				if ![exists ocurid] {set ocurid $curid}
				for {set id [incr ocurid]} {$id <= $curid} {incr id} {
					if [catch {
						set rv [encoding convertfrom [page [post $wiki {*}$query / revids $id / prop revisions / utf8]]]
						set rvdata [join [dict get $rv revisions]]
						dict with rvdata {
							dict with rv {
#Arbeitsbereich
#if {$user eq {Informationswiedergutmachung} && $ns != 0} {
#	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] IWG:''' \[\[:de:$title|$title\]\] -- \
#		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
#			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
#		]''" : {}}]"
#	set lang test ; source langwiki.tcl
#	puts [edid 63277 {Log: IWG} {} / appendtext $log]
#	set lang	de1 ; source langwiki.tcl
#}
#if {[expr [clock seconds] - $t1] > 3600} {exit}
#puts [incr xyz]
if {$title in 	{{Wikipedia:Adminwiederwahl/Doc Taxon} {Wikipedia Diskussion:Adminwiederwahl/Doc Taxon}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] WW:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: WW} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{{Wikipedia Diskussion:Importwünsche} {Wikipedia Diskussion:Importwünsche/Importupload}
					 {Wikipedia Diskussion:Übersetzungen}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] IMP:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: IMP} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{Wikipedia:Bibliotheksrecherche 				{Wikipedia Diskussion:Bibliotheksrecherche}
					 Wikipedia:Bibliotheksrecherche/Anfragen	{Wikipedia Diskussion:Bibliotheksrecherche/Anfragen}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] BIBR:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: BIBR} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title eq 	{Wikipedia:Bots/Anfragen}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Bots:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: Bots} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{{Wikipedia:WikiProjekt Kategorien/Warteschlange}	{Wikipedia Diskussion:WikiProjekt Kategorien/Warteschlange} Benutzer:TaxonKatBot/blocked.js}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Kat:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: Kat} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{{Wikipedia:Löschkandidaten/Urheberrechtsverletzungen/Nicht Eingetragen}
					  Wikipedia:Löschkandidaten/Urheberrechtsverletzungen
					 {Wikipedia Diskussion:Löschkandidaten/Urheberrechtsverletzungen}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] LKU:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: LKU} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{{Eckhard Wandel}	{Diskussion:Eckhard Wandel}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Wandel:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: Wandel} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{{Ina Wolf}	{Diskussion:Ina Wolf}	{Peter Wolf (Komponist)}	{Diskussion:Peter Wolf (Komponist)}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Wolf:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: Wolf} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{{Modul:Vorlage:Defekter Weblink} {Wikipedia Diskussion:Lua/Modul/Vorlage:Defekter Weblink}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Modul DWL:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: Modul DWL} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in 	{{Wikipedia:Augsburg}	{Wikipedia Diskussion:Augsburg}}} {
	set log "\n* '''$timestamp \[\[:de:Special:Diff/prev/$revid|••\]\] Augsburg: \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]'''"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: AUX} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title eq 	{Wikipedia:Miniaturenwettbewerb}} {
	set log "\n* '''$timestamp \[\[:de:Special:Diff/prev/$revid|••\]\] MiniWB: \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]'''"
	puts $log
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: MiniWB} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
	exec ./miniwb.tcl
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

