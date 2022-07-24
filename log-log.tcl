#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot log-log.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set olrc {}
while 1 {
	while 1 {
		if ![catch {
			set lrc [get [post $wiki {*}$query {*}$format / list recentchanges / rcprop timestamp|title|ids|user|userid|sizes|comment|loginfo / rclimit 500] query recentchanges]
		}] {break}
	}
	if {$lrc ne $olrc} {
		foreach rc [lreverse $lrc] {
			if {$rc ni $olrc} {
				dict with rc {
#Arbeitsbereich
if [catch {
	get [post $wiki {*}$format / action purge / titles $title / forcerecursivelinkupdate]
}] {puts {caught purge}}
#if {$ns in {3 5 7 9 11 13 15 101 829 2301 2303}} {
#	exec ./unsigned.tcl $revid >> unsigned.out 2>@1 &
#}
#if {$ns && $user in {Bachsau Brainswiffer {Fiona B.} {Georg Hügler} JTCEPB Mautpreller}} {
#	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] FB:''' \[\[:de:$title|$title\]\] -- \
#		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
#			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
#		]''" : {}}]"
#	set lang test ; source langwiki.tcl
#	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
#		puts [edid 63277 {Log: FB} {} / appendtext $log]
#	}
#	set lang de ; source langwiki.tcl
#}
#if {!$ns && $user eq {Über-Blick}} {
#	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Über-Blick:''' \[\[:de:$title|$title\]\] -- \
#		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
#			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
#		]''" : {}}]"
#	set lang test ; source langwiki.tcl
#	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
#		puts [edid 63277 {Log: Über-Blick} {} / appendtext $log]
#	}
#	set lang de ; source langwiki.tcl
#}
if !$ns {
	exec ./refcheck.tcl $pageid >> refcheck.out 2>@1 &
}
if {$ns in {8 9}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] MediaWiki:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: MediaWiki} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title eq {Wikipedia:Spielwiese} && $type eq {log} && $logaction eq {delete}} {
	exec ./spielwiese-reset.tcl new >> spielwiese.out 2>@1 &
} elseif {$title eq {Wikipedia:Spielwiese} && $type eq {edit}} {
	prepend_file spielwiese.db [list $timestamp $comment]
}
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
if {$title in 	{{Ingo B. Runnebaum} {Diskussion:Ingo B. Runnebaum}}} {
	set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Runnebaum:''' \[\[:de:$title|$title\]\] -- \
		\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
			regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
		]''" : {}}]"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: Runnebaum} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
if {$title in	{{Wikipedia:Verhalten im Notfall} {Wikipedia Diskussion:Verhalten im Notfall}}} {
	set log "\n* '''$timestamp -- <span style=\"color:red;\">110</span>'''"
	set lang test ; source langwiki.tcl
	if {[string trim $log] ni [split [conts id 63277 x] \n]} {
		puts [edid 63277 {Log: 110} {} / appendtext $log]
	}
	set lang de ; source langwiki.tcl
}
catch {
	if {$user eq {Qäsee} && [expr abs($newlen-$oldlen) >= 500]} {
		set log "\n* $timestamp '''\[\[:de:Special:Diff/prev/$revid|••\]\] Qäsee:''' \[\[:de:$title|$title\]\] -- \
			\[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
				regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
			]''" : {}}]"
		set lang test ; source langwiki.tcl
		if {[string trim $log] ni [split [conts id 63277 x] \n]} {
			puts [edid 63277 {Log: Qäsee} {} / appendtext $log]
		}
		set lang de ; source langwiki.tcl
	}
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
	exec ./miniwb.tcl >> miniwb.out 2>@1 &
}
if {!$ns && $userid && $user ne {Schnabeltassentier}} {
	catch {
		set diff [regexp -all -line -- {.*"diff-addedline".*\[\[ ?Kategorie: ?Schauspieler.*} [
			get [post $wiki {*}$format / action compare / fromrev $revid / torelative prev] compare *
		]]
		if $diff {
			set f [open ss.db a] ; puts $f ----\n$timestamp\n$title\n$user\nuserid:$userid ; close $f
			set ssdb [read [set f [open ss.db r]]] ; close $f
			set uc [regexp -all -line -- "^userid:$userid\$" $ssdb]
			set log "\n* '''$timestamp \[\[:de:Special:Diff/prev/$revid|••\]\] SS: \[\[:de:$title|$title\]\] -- \
				($uc×) \[\[:de:user:$user|$user\]\] -- [expr {$comment ne {} ? "''[
					regsub -- {/\* (.*?) \*/} $comment "\[\[:de:$title#\\1|→\]\]<span class=\"autocomment\">\\1: </span>"
				]''" : {}}]'''"
			set lang test ; source langwiki.tcl
			if {[string trim $log] ni [split [conts id 63277 x] \n]} {
				puts [edid 63277 {Log: SS} {} / appendtext "$log"]
			}
			set lang de ; source langwiki.tcl
			if {$uc in {1 4 7 10 13 16 19}} {
				set sstx [string map [list <> \n §revid $revid §article $title §~ ${~}] [lindex [split $ssdb \n] 0]]
				puts [edit user_talk:$user {Bot: Hinweis zur Verwendung der [[:Kategorie:Schauspieler]]} {} / appendtext $sstx]
			}
		}
	}
}
if {$title eq {Wikipedia:WikiProjekt Frauen/Frauen in Rot/WerMachtMit}} {
	catch {
		puts [get [post $wiki {*}$format / action purge / titles {Wikipedia:WikiProjekt Frauen/Frauen in Rot} / forcerecursivelinkupdate]]
	}
}
if {!$ns && [matchtemplate $title Vorlage:Normdaten]} {
	exec ./normdaten2.tcl pgid $pageid revid $revid >> normdaten2.out 2>@1 &
}
if {$title eq {Wikipedia Diskussion:Hauptseite/Schon gewusst}} {
	exec ./sg.tcl Vorschlag >> sg.out 2>@1 &
}
if {$title eq "Wikipedia:Hauptseite/Schon gewusst/[utc -> seconds {} %A {}]"} {
	exec ./sg.tcl aufHS >> sg.out 2>@1 &
}
if {$title eq {Wikipedia Diskussion:Hauptseite/Artikel des Tages/Vorschläge} || [string first {Wikipedia Diskussion:Hauptseite/Artikel des Tages/20} $title] > -1} {
	exec ./adt2.tcl notice >> adt2.out 2>@1 &
}
catch {
	if {$title eq {Benutzer:Shi Annan/A - Verschieben}} {
		exec ./shiannan.tcl >> shiannan.out 2>@1 &
	}
}
catch {
	set mtitle {{user:Maimaid/Meine Mentees}}
	set menteeconts [conts t [join $mtitle] x]
	set luser [dict values [
		regexp -all -inline -line -- {^\*.*?Beiträge/(.*?)\|.*$} $menteeconts
	]]
	set ltitle [dict values [
		regexp -all -inline -line -- {\|title\=(.*?)\|.*$} $menteeconts
	]]
	if {$user in $luser || $title in "$mtitle $ltitle"} {
		exec ./mentees.tcl >> mentees.out 2>@1 &
	}
}
#Arbeitsbereich
				}
			}
		}
		set olrc $lrc
	} else {
		continue
	}

}
