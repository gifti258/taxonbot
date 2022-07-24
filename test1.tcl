#!/usr/bin/tclsh8.7
#exit

set editafter 5

source api2.tcl
set lang de ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl
source library.tcl
#set db [get_db commonswiki]

#package require http
#package require tls
#package require tdom

set editreport [edit user:TaxonBot/Test1 Test {} / appendtext "\n\n== Test4 ==\nTest4" / section 1]
puts editreport:$editreport
puts [dict get $editreport edit result]

exit

#cont {ret1 {
#	foreach item [alldeletedrevisions $ret1] {puts [incr i]}
#}} {*}$alldeletedrevisions / adrprop ids|timestamp|content / adrslots * / adrfrom Spielwiese / adrnamespace 4}

#exit

set contrev 4|Spielwiese|20200401031702|198330689
while 1 {
set radr [get [post $wiki {*}$token {*}$format / action query / list alldeletedrevisions / adrprop ids|timestamp|content / adrslots * / adrfrom Spielwiese / adrnamespace 4 / adrlimit max / adrcontinue $contrev]]

set ladr [dict get $radr query alldeletedrevisions]



#set ladr [get [post $wiki {*}$token {*}$format / action query / list alldeletedrevisions / adrprop ids|timestamp|content / adrslots * / adrfrom Spielwiese / adrnamespace 4 / adrlimit max] query alldeletedrevisions]

#puts [post $wiki {*}$token {*}$format / action query / prop revisions / titles Wikipedia:Spielwiese / rvslots * / rvstart 2020-04-11T00:00:00Z / rvprop content]
#exit

foreach adr [dict get [join $ladr] revisions] {
	puts [incr i]:[dict get $adr timestamp]:[dict get $adr revid]
	if {[string first Teut [dict get $adr slots]] > -1} {
		puts $adr ; gets stdin
	}
	set contrev 4|Spielwiese|[string map {- {} T {} : {} Z {}} [dict get $adr timestamp]]|[dict get $adr revid]
}
}

exit

set db [get_db dewiki]
set lrev [mysqlsel $db "
	select rc_deleted from recentchanges
	where rc_namespace = 4 and rc_title = 'Spielwiese'
;" -list]
mysqlclose $db

puts $lrev

exit

set db [get_db dewiki]
set lpg [mysqlsel $db "
	select page_title from page join pagelinks on pl_from = page_id
	where !pl_from_namespace and !pl_namespace and pl_title in ('Wilsberg_(Fernsehserie)','Wilsberg_(Fernsehserie)/Episodenliste')
;" -flatlist]
puts $lpg:[llength $lpg]

foreach pg [lreverse $lpg] {
	puts $pg
	puts [edit $pg {Bot: Linkkorrektur [[Wilsberg (Fernsehserie)]] → [[Wilsberg (Fernsehreihe)]]} [string map {{Wilsberg (Fernsehserie)} {Wilsberg (Fernsehreihe)}} [conts t $pg x]] / minor]
	if {[incr i] < 10} {gets stdin}
}



exit

set db [get_db commonswiki]
set lcat [sqlcat Images_from_Wiki_Loves_Monuments_2019 14]
mysqlclose $db
foreach cat $lcat {
	lassign [list {} [sql <- $cat]] state cat_
	regexp -- {^Images.*in (?:the |an )?(.*)} $cat -- state
	if ![empty state] {
puts $cat
		set db [get_db commonswiki]
		set lfi [sqldeepcat_id $cat_ 6]
		mysqlclose $db
		lappend lstate $state $cat_ [llength $lfi] $lfi
	}
}

puts [lsort -stride 4 -index 2 -integer -decreasing $lstate]

set pgid 82146278
set db [get_db commonswiki]
puts [mysqlsel $db "select page_title, img_actor, actor_name from page, image, actor where img_name = page_title and actor_id = img_actor and page_id = $pgid and page_namespace = 6;" -flatlist]
mysqlclose $db










exit

set lpt [insource {[Dd]es weiteren/} 0]
puts $lpt
puts [llength $lpt]

foreach pt $lpt {
	if {[incr i] > 314} {
	set o [conts t $pt x]
	puts $i:[set v [regexp -all -- {[Dd]es weiteren} $o]]:$pt
	if {$v == 1} {
		set rex [regexp -inline -- {.{0,39}[Dd]es weiteren.{0,39}} $o]
		puts $rex
		input f "?: "
		if {$f eq {j}} {
			puts [edit $pt {Bot: korrigiere Rechtschreibung "des Weiteren"} [string map {{es weiteren} {es Weiteren}} $o] / minor]
		}
	}}
}


exit

set lpt [cat {Category:A selection of Hexandrian plants, belonging to the natural orders Amaryllidae and Liliacae} 6]

foreach pt $lpt {
	puts $pt
	set c [conts t $pt x]
	puts [edit $pt {Bot: corr. authorship} [string map {{Bury, Edward;} {Bury, Priscilla Susan;}} $c] / minor]
#	gets stdin
}

exit

set lpt [insource {\{ OTRS-Freigabe/} x]

set ll [llength $lpt]
foreach pt $lpt {
	puts [decr ll]:$pt
#	puts [decr ll]:[edit $pt {Bot: OTRS: Kategorisierung jetzt per [[Vorlage:OTRS]]} [regsub -line -- {\[\[Kategorie:Wikipedia:OTRS-Freigabe\|.*?\]\]} [conts t $pt x] {}] / minor]
#	gets stdin
}

exit

set wph Wikipedia:Hannover
set wpsh {Wikipedia:Stammtisch Hannover}
set map [list $wph/Anreise $wpsh/Anreise $wph/Archiv $wpsh/Archiv $wph/Bilderwettbewerb $wpsh/Bilderwettbewerb $wph/CeBIT $wpsh/CeBIT $wph/Projekt $wpsh/Projekt $wph/T-Shirt $wpsh/T-Shirt]

puts [set lpt [insource {Wikipedia:Hannover\/T-Shirt/} -0]]

gets stdin

foreach pt $lpt {
	catch {
		puts [edit $pt {Bot: "Wikipedia:Hannover" → "Wikipedia:Stammtisch Hannover" wie gewünscht} [string map $map [conts t $pt x]] / minor]
	}
}


exit

set t [utc -> seconds {} {%d. %B %Y} {-1 day}]
set qst [sql <- Qualitätssicherung/$t]
set lpt [scat Wikipedia:Qualitätssicherung 0]
set sign ":<small>vergessenen QS-Eintrag nachgetragen ${~}</small>"
set db [get_db dewiki]
mysqlreceive $db "
	select pl_title from pagelinks, page where page_id = pl_from
	and pl_from_namespace = 4 and !pl_namespace
		and page_namespace = 4 and page_title = '$qst'
;" plt {
	lappend ll [sql -> $plt]
}
mysqlclose $db
foreach pt $lpt {
	regexp -- {\{\{QS.*?\}\}} [conts t $pt x] templ
	set ptempl [parse_templ $templ]
	if {[dict get $ptempl 1] eq $t && $pt ni $ll} {
		puts [edit Wikipedia:$qst \[\[$pt\]\] $sign\n[dict get $ptempl 2] / section new]
	}
}

exit

set lpt [lsort [insource {\<big\>'''Lies bitte alles genau\<\/big\> und erkunde auch, was sich hinter den Links verbirgt\.'''/} x]]

set otext {<big>'''Lies bitte alles genau</big> und erkunde auch, was sich hinter den Links verbirgt.'''}
set ntext {'''<span style="font-size:larger;">Lies bitte alles genau</span> und erkunde auch, was sich hinter den Links verbirgt.'''}

foreach pt $lpt {
	puts [set ret [edit $pt {Bot: HTML-Validierung} [string map [list $otext $ntext] [conts t $pt x]] / minor]]
	if {[string first protectedpage $ret] > -1} {
		set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
		puts [edit $pt {HTML-Validierung} [string map [list $otext $ntext] [conts t $pt x]] / minor]
		set lang de ; source langwiki.tcl ; #set token [login $wiki]
	}
}














exit

set ot {Category:Heinrich Ignaz Frans Biber}
set nt {Category:Heinrich Ignaz Franz Biber}

set lpt [cat $ot 6]
puts $lpt

foreach pt $lpt {
	puts [edit $pt {incorrect category lemma} [string map [list $ot $nt] [conts t $pt x]] / minor]
}


exit

foreach pt $lpt {
	puts [post $wiki {*}$token {*}$format / action move / from $pt / to [string map {Dommuseum DomQuartier} $pt] / reason {imprecise lemma} / movetalk 1 / noredirect 1]
}

exit

}

set argv [join $argv]
puts [lindex $argv 0]

puts [lindex $argv 1]
set nconts [set oconts [conts t [lindex $argv 1] x]]

switch [lindex $argv 0] {
	big			{
						set nconts [string map [list <big> {<span style="font-size:larger;">} </big> </span>] $nconts]
						puts $nconts
						gets stdin
					}
	small			{
						set lsmall [regexp -all -inline {<small.*?</small>} $oconts]
						foreach small $lsmall {
#					puts $small
							if {[string first \n* $small] > -1 || [string first \n\n $small] > -1 || [string first <br $small] > -1} {
								set nsmall [
									string map [list <small> "<div style=\"font-size:smaller\;\">\n" </small> \n</div>] $small
								]
								puts \n$small\n\n$nsmall
								gets stdin
								set nconts [string map [list $small $nsmall] $nconts]
							}
						}
					}
	smallcenter	{
						set lsc [regexp -all -inline {(<small><center|<center><small).*?</center></small>} $oconts]
						foreach sc $lsc {
							set nsc [
								string map [list <small><center> "<div class=\"center\" style=\"font-size:smaller\;\">" <center><small> "<div class=\"center\" style=\"font-size:smaller\;\">" </center></small> </div>] $sc
							]
							puts \n$sc\n\n$nsc
							gets stdin
							set nconts [string map [list $sc $nsc] $nconts]
						}
					}
	span			{
						set lspan [regexp -all -inline {<span.*?</span>} $oconts]
						foreach span $lspan {
#					if {[string first \n* $small] > -1} {
#						set nsmall [
#							string map {<small> {<div style="font-size:smaller;">} </small> </div>} $small
#						]
#						puts $small\n\n$nsmall
#						gets stdin
#						set nconts [string map [list $small $nsmall] $nconts]
#					}
						puts $span
					}
			}
}
#if {[llength $argv] > 1} {
#	set small [lindex $argv 1 0]
#	set nsmall [lindex $argv 1 1]
#	puts $small\n\n$nsmall
#	gets stdin
#	set nconts [string map [list $small $nsmall] $nconts]
#} else {
#	set lsmall [regexp -all -inline {<small.*?</small>} $conts]
#	set lsmall [regexp -all -inline {<small.*?</small>} $conts]
#	foreach small $lsmall {
#		if {[string first \n\n $small] > -1 || [string first \n: $small] > -1} {
#			set nsmall [
#				string map {<small> {<div style="font-size:smaller;">} </small> </div>} $small
#			]
#			puts $small\n\n$nsmall
#			gets stdin
#			set nconts [string map [list $small $nsmall] $nconts]
#		}
#	}
#}

#gets stdin

if {$nconts ne $oconts} {
	puts [edit [lindex $argv 1] {Bot: [[Spezial:LintErrors/misnested-tag|Lint-Fehler: Falsch verschachtelte Tags]] im Rahmen des [[WP:WikiProjekt HTML5|WikiProjektes HTML5]] zur Validierung der Hypertext-Auszeichnungssprache behoben} $nconts / minor]
} else {
	puts {! keine Änderung !}
}

exit


#gets stdin

set lpt [insource {\<strike\>/} 1]
puts $lpt
set i [llength $lpt]

set summary {Bot: HTML-Validierung: <strike> → <s> ([[BD:Doc Taxon#Wäre es machbar…|Disk]])}

foreach pt $lpt {
#	set pt $argv
#	if {$pt eq {Hilfe:Textgestaltung}} {continue}
	catch {
		set nconts [set oconts [conts t $pt x]]
		set lrx [regexp -all -inline -line -- {<strike>.*?</strike>} $oconts]
		if {[string first \n $lrx] > -1} {puts Fehler ; exit}
		puts [decr i]:$pt:\n$lrx\n
		foreach rx $lrx {
			set nrx [string map -nocase {<strike> <s> </strike> </s>} $rx]
			set nconts [string map [list $rx $nrx] $nconts]
		}
		if {$nconts ne $oconts} {
			puts [set out [edit $pt $summary $nconts / minor]]\n
		}
		if {[string first protectedpage $out] > -1} {exec ./test12.tcl "$pt" &}
	}
#	if {[incr i] < 5} {gets stdin}
}
puts \a

exit


set lpt [mysqlsel $db {
	select page_title
	from page join templatelinks on tl_from = page_id
	where page_namespace in (828,829) and tl_from_namespace and tl_namespace = 10 and tl_title in ('Welterbe_Staat','Welterbe_Tentativliste','Welterbe')
	order by page_title
;} -flatlist]

puts $lpt
puts [llength $lpt]

foreach pt $lpt {
	set conts [conts t $pt x]
	set nconts $conts
	set lrextempl [regexp -all -inline -line -nocase -- {\{\{ ?Welterbe[^\}]*?\}\}} $conts]
#	if {[string first WHTour=1 $lrextempl] > -1} {continue}
	puts $pt
	puts $lrextempl
#	puts [llength $lrextempl]
#	if {[string first = $lrextempl] > -1} {puts Fehler ; exit}
#	puts [llength [split $rextempl |]]
	foreach templ $lrextempl {
		unset -nocomplain ntempl s1 s2 s3 s4
		set lp [llength [set ls [split $templ |]]]
#		puts $lp
		set s1 [lindex $ls 0]
		if {[string first Staat $s1] > -1} {
			catch {set s1 [string trim [string trim $s1 \{\}]]}
			switch $lp {
				1	{	set ntempl "\{\{Weblink Welterbe Staat\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
				2	{	set s2 [lindex $ls 1]
						catch {set s2 [string trim [string trim $s2 \{\}]]}
						set ntempl "\{\{Weblink Welterbe Staat |Kürzel=$s2\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
				3	{	set s2 [lindex $ls 1] ; set s3 [lindex $ls 2]
						catch {set s2 [string trim [string trim $s2 \{\}]]}
						catch {set s3 [string trim [string trim $s3 \{\}]]}
						set ntempl "\{\{Weblink Welterbe Staat |Kürzel=$s2 |Name=$s3\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
			}
		} elseif {[string first Tentativ $s1] > -1} {
			catch {set s1 [string trim [string trim $s1 \{\}]]}
			switch $lp {
				1	{	set ntempl "\{\{Weblink Welterbe Tentativliste\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
				2	{	set s2 [lindex $ls 1]
						catch {set s2 [string trim [string trim $s2 \{\}]]}
						set ntempl "\{\{Weblink Welterbe Tentativliste |Nummer=$s2\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
				3	{	set s2 [lindex $ls 1] ; set s3 [lindex $ls 2]
						catch {set s2 [string trim [string trim $s2 \{\}]]}
						catch {set s3 [string trim [string trim $s3 \{\}]]}
						set ntempl "\{\{Weblink Welterbe Tentativliste |Nummer=$s2 |Name=$s3\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
				4	{	set s2 [lindex $ls 1] ; set s3 [lindex $ls 2] ; set s4 [lindex $ls 3]
						catch {set s2 [string trim [string trim $s2 \{\}]]}
						catch {set s3 [string trim [string trim $s3 \{\}]]}
						catch {set s4 [string trim [string trim $s4 \{\}]]}
						set ntempl "\{\{Weblink Welterbe Tentativliste |Nummer=$s2 |Name=$s3 |Sprache=$s4\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
			}
		} else {
			catch {set s1 [string trim [string trim $s1 \{\}]]}
			switch $lp {
				1	{	set ntempl "\{\{Weblink Welterbe\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
				2	{	set s2 [lindex $ls 1]
						catch {set s2 [string trim [string trim $s2 \{\}]]}
						set ntempl "\{\{Weblink Welterbe |Nummer=$s2\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
				3	{	set s2 [lindex $ls 1] ; set s3 [lindex $ls 2]
						catch {set s2 [string trim [string trim $s2 \{\}]]}
						catch {set s3 [string trim [string trim $s3 \{\}]]}
						set ntempl "\{\{Weblink Welterbe |Nummer=$s2 |Name=$s3\}\}"
						set nconts [string map [list $templ $ntempl] $nconts]
					}
			}
		}
		puts $ntempl
	}
	puts [llength $lrextempl]:[edit $pt {Bot: Anpassung der Welterbe-Vorlagen, siehe [[WP:Bots/A#Vorlagenumstellung|Bot-Anfrage]]} $nconts / minor]\n
gets stdin
#	if {[incr i] < 30} {gets stdin}
}

exit


set lcat [dcat list Wikipedia:Wikimedia:Woche 4]
foreach cat [lrange $lcat 1 end-1] {
	puts $cat
	if [catch {set ncat [utc ^ $cat Wikimedia:Woche/%Y-%m-%d Wikimedia:Woche/%d%m%y {}]}] {continue}
	puts $ncat
	puts [edit Wikipedia:$ncat {Bot-Auftrag von [[Benutzer:Masin Al-Dujaili (WMDE)]]; Weiterleitung wegen externer Verlinkungen benötigt} "#WEITERLEITUNG \[\[Wikipedia:$cat\]\]"]\n
	if {[incr i] == 1} {gets stdin}
}

exit

	puts [get [post $wiki {*}$token {*}$format / action move / from Wikipedia:$cat / to Wikipedia:$ncat / reason {Bot-Auftrag von [[Benutzer:Masin Al-Dujaili (WMDE)]]} / movetalk 1 / noredirect 1]]\n
	after 5000
}

exit



set linsrc [insource altdwz.schachbund.net/ 0]
puts $linsrc
puts [llength $linsrc]

foreach insrc $linsrc {
	if ![missing Diskussion:$insrc] {
		puts $insrc\n======
		puts [conts t Diskussion:$insrc x]
		gets stdin
	}
}

exit

foreach insrc $linsrc {
	puts [edit $insrc {Bot: Weblinkersatz http://altdwz.schachbund.de → http://altdwz.schachbund.net} [string map {altdwz.schachbund.de altdwz.schachbund.net} [conts t $insrc x]] / minor]
}

exit

set arg [lindex $argv 0]
set f [open adt.db w] ; close $f
mysqlreceive $db {
	select page_title
	from page join templatelinks on tl_from = page_id
	where !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title in ('Lesenswert','Exzellent')
	order by page_title
;} pt {
	lappend lpt $pt
}
foreach pt $lpt {
	catch {
		if {[string first $arg [conts t $pt x]] > -1} {
			puts [incr i]:$pt
			set f [open adt.db a] ; puts $f $i:$pt ; close $f
		}
	}
}
puts \a


