#!/usr/bin/tclsh8.7

set editafter 1

#exit

set revid	{Vorlage:Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)/Revid}
set greetz	{{{Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)}}}
set new		{{{subst:Bitte erst NACH dieser Zeile schreiben! (Begrüßungskasten)/Text}}}
if {$argv eq {reset}} {
	source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
	catch {exec pkill -x spielwiese.tcl}
	puts [get [post $wiki {*}$token {*}$format / action delete / title Wikipedia:Spielwiese / reason {Reset der Spielwiese (halbmonatlich)}]]
	save_file spielwiese.db {}
} elseif {$argv eq {new}} {
	source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
	puts [set g	 [edit Wikipedia:Spielwiese {Bot: Reset der Spielwiese} 		 $greetz]]
	puts [set gn [edit Wikipedia:Spielwiese {Bot: Spielwiese neu aufgesetzt} $greetz$new]]
	if {{newrevid} ni [dict keys $g]} {
		set g [list edit [list newrevid [dict get $gn edit oldrevid]]]
	}
	puts [edit "$revid Leer" {Bot: neue Revisions-ID} [regsub -- {\d{9}} [conts t "$revid Leer" x] [dict get $g edit newrevid]] / minor]
	puts [edit "$revid Text" {Bot: neue Revisions-ID} [regsub -- {\d{9}} [conts t "$revid Text" x] [dict get $gn edit newrevid]] / minor]
	after 60000
	source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
	puts [get [post $wiki {*}$token {*}$format / action protect / title Wikipedia:Spielwiese / protections move=sysop / reason {Die Spielwiese genießt Verschiebeschutz.}]]
	source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]
	wbsite 3938 {de Wikipedia:Spielwiese} {page reset on dewiki}
}

exit
