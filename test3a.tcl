#!/usr/bin/tclsh8.7
#exit

set editafter 1
#if {[exec pgrep -cxu taxonbot test3.tcl] > 1} {exit}

#source api2.tcl ; set lang de1 ; source langwiki.tcl ; set atoken [login $wiki]
#puts $atoken ; puts $wiki
source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set lins [insource {Marsé-Vidri/} $argv]
#set lins [insource [format {\<font color\=%s/} $argv] 4]
#set lins [insource {Friedrich Graf\/K/} x]
puts [set lenlins [llength $lins]]

#set summ {Bot: [[Enrique López-Pérez]] → [[Enrique López Pérez]]}
set summ {Bot: Jordi Marsé-Vidri → Jordi Marsé Vidri}
#set summ1 {Überarbeitung veralteter Syntax / [[H:LINT|HTML-Validierung]]}

set old1 {Marsé-Vidri}
set new1 {Marsé Vidri}
#set old2 {Burrieza-López}
#set new2 {Burrieza López}
#set old3 {Burrieza|}
#set new3 {Burrieza López|}
#set old4 "Burrieza\]"
#set new4 "Burrieza López\]"

#set old2 Solves
#set new2 Solvès

set offset 0
foreach ins $lins {
#	append_file test3.out $ins
	puts "\n[incr i]/$lenlins: $ins:"
#	if {$ins in {{Hilfe Diskussion:Wikisyntax/Validierung} {Benutzer:Doc Taxon/Test4} {Hilfe Diskussion:Wikisyntax/Validierung/Liste}}} {continue}
#	if {$ins eq {Wikipedia:Qualitätssicherung/5. Juli 2008}} {set offset 1} else {if {$offset == 0} {continue}}
#	if {$ins in {Odanacatib Knochenmetastase}} {continue}
#	if {$ins ne {Wikipedia:Löschkandidaten/24. August 2005}} {continue}
	set in	[conts t $ins x]
	set nin [string map [list $old1 $new1] $in]
#	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9 $olda $newa] $in]
#	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9 $olda $newa $oldb $newb $oldc $newc $oldd $newd $olde $newe $oldf $newf $oldg $newg] $in]
#save_file test3.out $nin
#exit

	if {$nin ne $in} {
		set out [edit $ins $summ $nin / minor]
		puts $out
		if {{protectedpage} in [split $out]} {
			source api2.tcl ; set lang de1 ; set wiki curl1 ; #set token $atoken
			puts [edit $ins $summ1 $nin / minor]
			after 5000
			source api.tcl ; set lang de ; set wiki curl2 ; #set token $btoken
		}
#		if {[incr c] <= 2} {gets stdin}
	}
}

exit


set old1 {[[Benutzer:Robinhood|<font color=#005500>Robinhood]]</font>[[Benutzer Diskussion:Robinhood|<font size="3" style="text-decoration:none; color:#005500">♣</font>]]}
set old2 {[[Benutzer:Robinhood|<font color=#006600>Robinhood]]</font>[[Benutzer Diskussion:Robinhood|<font color=#009933><font size="3" style="text-decoration: none">♣</font>]]}
set old3 {[[Benutzer:Robinhood|<font color=#009900>Robinhood]]</font> [[Benutzer Diskussion:Robinhood|<sup><font color=#800000>@</font></sup>]]}
set new1 {[[Benutzer:Robinhood|<span style="color:#005500;">Robinhood</span>]] [[Benutzer Diskussion:Robinhood|<span style="color:#005500; font-size:1.2em;">♣</span>]]}
set new2 {[[Benutzer:Robinhood|<span style="color:#006600;">Robinhood</span>]] [[Benutzer Diskussion:Robinhood|<span style="color:#009933; font-size:1.2em;">♣</span>]]}
set new3 {[[Benutzer:Robinhood|<span style="color:#009900;">Robinhood</span>]] [[Benutzer Diskussion:Robinhood|<sup style="color:#800000;">@</sup>]]}
set old4 {[[Benutzer:Louie|Louie <font color=green>†</font>]]}
set new4 {[[Benutzer:Louie|Louie <span style="color:green;">†</span>]]}
set old5 {[[Benutzer:Toen96|<font color="#686868">Toen96</font>]] <sup> [[Benutzer Diskussion:Toen96|<font color="#686868">sabbeln</font>]] </sup>}
set new5 {[[Benutzer:Toen96|<span style="color:#686868;">Toen96</span>]] [[Benutzer Diskussion:Toen96|<sup style="color:#686868;"> sabbeln </sup>]]}
set old6 {<sup>[[Benutzer:Nilreb|<span style="color:#00CD00"><b><font face="Lucida Handwriting">NIL</font></b></span>]]</sup>[[Benutzer Diskussion:Nilreb|<small><font color="#FF0000" face="HANA"><span style="background-color: #000000"> Disk.</span></font></small>]]}
set new6 {[[Benutzer:Nilreb|<sup style="color:#00CD00; font-family:'Lucida Handwriting';">'''NIL'''</sup>]][[Benutzer Diskussion:Nilreb|<span style="color:#ff0000; font-family:Hana; background-color:#000000;"><small> Disk.</small></span>]]}
set old7 {[[Benutzer:DerAndre|<font color="#4D9900">'''D'''er'''A'''ndre</font>]]}
set new7 {[[Benutzer:DerAndre|<span style="color:#4D9900;">'''D'''er'''A'''ndre</span>]]}
set old8 {<font color="#4e4f4f">— [[Benutzer:111Alleskönner|<font color="#686868">'''Alleskoenner'''</font>]] <small>([[BD:111Alleskönner|<font color="#686868">Diskussion</font>]])</small></font>}
set new8 {<span style="color:#4e4f4f;">— </span>[[Benutzer:111Alleskönner|<span style="color:#686868;">'''Alleskoenner'''</span>]] <small>([[BD:111Alleskönner|<span style="color:#686868;">Diskussion</span>]])</small>}
set old9 {[[Benutzer:23PowerZ|<font color="red">★</font>P''οωερ''<font color="black"><b>Z</b></font>]]<sub><sub>[[Benutzer_Diskussion:23PowerZ|Diskussion]]</sub></sub>}
set new9 {[[Benutzer:23PowerZ|<span style="color:red;">★</span>P''οωερ''<span style="color:black;">'''Z'''</span>]][[Benutzer Diskussion:23PowerZ|<sub><sub>Diskussion</sub></sub>]]}
set olda {[[Benutzer Diskussion:Hæggis|Hæ]]<font color="#002bb8">gg</font>[[Benutzer:Hæggis|is]]}
set newa {[[Benutzer Diskussion:Hæggis|Hæ]]<span style="color:#002bb8;">gg</span>[[Benutzer:Hæggis|is]]}





set offset 0
foreach ins $lins {
#	append_file test3.out $ins
	puts "\n[incr i]/$lenlins: $ins:"
	if {$ins in {{Hilfe Diskussion:Wikisyntax/Validierung} {Benutzer:Doc Taxon/Test4} {Hilfe Diskussion:Wikisyntax/Validierung/Liste}}} {continue}
#	if {$ins eq {Wikipedia:Qualitätssicherung/5. Juli 2008}} {set offset 1} else {if {$offset == 0} {continue}}
#	if {$ins eq {Benutzer Diskussion:PDD}} {continue}
#	if {$ins ne {Wikipedia:Löschkandidaten/24. August 2005}} {continue}
	set in	[conts t $ins x]
#	set nin [string map [list $old1 $new1 $old2 $new2 $old3 $new3] $in]
	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9 $olda $newa] $in]
#	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9 $olda $newa $oldb $newb $oldc $newc $oldd $newd $olde $newe $oldf $newf $oldg $newg] $in]
#save_file test3.out $nin
#exit

	if {$nin ne $in} {
		set out [edit $ins $summ $nin / minor]
		puts $out
		if {{protectedpage} in [split $out]} {
			source api2.tcl ; set lang de1 ; set wiki curl1 ; #set token $atoken
			puts [edit $ins $summ1 $nin / minor]
			after 5000
			source api.tcl ; set lang de ; set wiki curl2 ; #set token $btoken
		}
#		if {[incr c] <= 2} {gets stdin}
	}
}

exit



#<font size="-3">The quick brown fox jumps over the lazy dog. (-3)</font><br />
#<span style="font-size:0.71em;">The quick brown fox jumps over the lazy dog. (0.71)</span><br />
#<font size="-2">The quick brown fox jumps over the lazy dog. (-2)</font><br />
#<span style="font-size:0.71em;">The quick brown fox jumps over the lazy dog. (0.71)</span><br />
#<font size="-1">The quick brown fox jumps over the lazy dog. (-1 = default)</font><br />
#<span style="font-size:0.93em;">The quick brown fox jumps over the lazy dog. (0.93)</span><br />
#<font size="+0">The quick brown fox jumps over the lazy dog.</font><br />
#<span style="font-size:1.14em;">The quick brown fox jumps over the lazy dog. (1.14)</span><br />
#<font size="+1">The quick brown fox jumps over the lazy dog. (+1)</font><br />
#<span style="font-size:1.28em;">The quick brown fox jumps over the lazy dog. (1.28)</span><br />
#<font size="+2">The quick brown fox jumps over the lazy dog. (+2)</font><br />
#<span style="font-size:1.71em;">The quick brown fox jumps over the lazy dog. (1.71)</span><br />
#<font size="+3">The quick brown fox jumps over the lazy dog. (+3)</font><br />
#<span style="font-size:2.28em;">The quick brown fox jumps over the lazy dog. (2.28)</span><br />
#<font size="+4">The quick brown fox jumps over the lazy dog. (+4)</font><br />
#<span style="font-size:3.4em;">The quick brown fox jumps over the lazy dog. (3.4)</span><br />
#<font size="+5">The quick brown fox jumps over the lazy dog. (+5)</font><br />
#<span style="font-size:3.4em;">The quick brown fox jumps over the lazy dog. (3.4)</span><br />


read_file test3.out dlrex

#puts $dlrex
set offset 0

save_file test3-1.out {}
foreach {key lval} $dlrex {
	if {$key eq {Benutzer:Suhadi Sadono/recent2.js}} {continue}
	if {$key eq {Benutzer:Strangemeister}} {incr offset}
	if !$offset {continue}
	puts \n$key
	append_file test3-1.out \n$key
	set conts [conts t $key x]
	foreach val $lval {
		if {		[string first Actany28 $val] > -1
				|| [string first Beethoven $val] > -1
				|| [string first {new topic at the end} $val] > -1
				|| [string first '''Warnung''' $val] > -1
				|| [string first {style="color} $val] > -1
				|| [string first {font color=} $val] > -1
				|| [string first {weight="} $val] > -1
				|| [string first {color="} $val] > -1
				|| [string first {face="} $val] > -1
				|| [string first {20:39, 4. Mär 2005 (CET)} $val] > -1
				|| [string first {"+1""} $val] > -1
				|| [string first {(Test: Aa)} $val] > -1
		} {continue}
		puts $val
		append_file test3-1.out $val
		set nval [string map {{"+0,5"} {"+1"} {"+0.6"} {"+1"} {"+0.75"} {"+1"} {"+1&amp;quot;} {"+1"} {"+1.5"} {"+1"} {"+2.0"} {"+2"}} $val]
		set nval [string map {{<font size=} {<span style="font-size:} {"+0"} {1.14em;"} {"+1"} {1.28em;"} {"+2"} {1.71em;"} {"+3"} {2.28em;"} {"+4"} {3.4em;"} {"+5"} {3.4em;"} </font> </span>} $nval]
		puts $nval
		append_file test3-1.out $nval
		set conts [string map [list $val $nval] $conts]
	}
#	puts $conts
	set summ {Bot: Überarbeitung veralteter Syntax}
	set summ1 {Überarbeitung veralteter Syntax}
	set out [edit $key $summ $conts / minor]
	puts $out
	if {{customjsprotected} in [split $out]} {continue}
	if {{protectedpage} in [split $out]} {
		source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
		puts [edit $key $summ1 $conts / minor]
		after 5000
		source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
	}
#	if {[incr c] <= 20} {gets stdin}
}

exit

		lappend nlval $val
	}
}

foreach val [lsort -unique $nlval] {


exit


foreach ins $lins {
	set lrex {}
	puts \n$ins:
	set lrex [lsort -unique [regexp -all -line -inline -- {\<font size ?\= ?\"\+.*?\</font\>} [conts t $ins x]]]
	puts $lrex
	lappend dlrex $ins $lrex
#	regsub -all -- {\<font size\=\"\+1\"\>(.*?)\</font\>} [set old1 [conts t $ins x]] {<span style="font-size:1.3em;">\1</span>} new1
#	puts $new1
}
puts $dlrex

save_file test3.out $dlrex

exit

set html [getHTML https://commons.wikimedia.org/w/index.php?title=Special:GlobalUsage&offset=&limit=500&target=Wappen+Kempten.svg]

set shtml [split $html \n]
foreach line $shtml {
	if {[string first "external" $line] > -1} {
		puts [incr i]:$line
		if {$i > 2} {
			regexp -- {//(.*?)\.} $line -- lang
			puts $lang
			regexp -- {">(.*?)<} $line -- pt
			puts $pt
			if [catch {
				source langwiki.tcl ; #set token [login $wiki]
				puts [edit $pt {Bot: actual coat of arms} [string map {{Wappen Kempten.svg} {DEU Kempten (Allgäu) COA.svg} Wappen_Kempten.svg DEU_Kempten_(Allgäu)_COA.svg} [conts t $pt x]] / minor]
				if {[incr z] < 6} {gets stdin}
			}] {puts "[incr j] caught"}
		}
	}
}

exit

while 1 {
	puts -nonewline .
	after 1000
}


exit

source library.tcl
set db [get_db dewiki]

#package require http
#package require tls
#package require tdom


set summary {Benutzerseite eines unbeschränkt [[WP:BS|gesperrten Benutzers]]}
set us [join $argv]
puts $us:

set lpt [mysqlsel $db "
	select page_title from page join pagelinks on pl_from = page_id
	where page_namespace = 4 and pl_from_namespace = 4 and pl_namespace = 2 and pl_title = '[sql <- $us]'
;" -flatlist]
set verilist Wikipedia:[lsearch -inline $lpt Benutzerverifizierung/Benutzernamen-Ansprachen/*]

puts [get [post $wiki {*}$format {*}$token / action block / user $us / allowusertalk false / reason {Trotz Aufforderung nicht [[WP:VER|verifiziertes Benutzerkonto]]}]]

after 10000
puts [edit user:$us $summary {#WEITERLEITUNG [[{{ers:DISK}}]]}]

after 10000
puts [get [post $wiki {*}$format {*}$token / action protect / title user:$us / protections edit=sysop|move=sysop / reason $summary]]

after 10000
puts [edit BD:$us $summary {{{GBN}}}]

after 10000
puts [get [post $wiki {*}$format {*}$token / action protect / title BD:$us / protections edit=sysop|move=sysop / reason $summary]]

after 3000
set cvl [conts t $verilist x]
regsub -all -- {^(\|)(\{\{)} $cvl {\1 \2} ncvl
regsub -- "\\|-\n\\| \{\{Benutzer\\| ??$us.*?(\\|-|\\|\})" $ncvl \\1 nncvl
if {$nncvl ne $cvl} {
	set lang de ; source langwiki.tcl
	set token [login $wiki]
	puts [edit $verilist "-\[\[user:$us|$us\]\]; Benutzerkonto nicht verifiziert" $nncvl]\n
}

exit

set lins [lsort [insource { / incategory:Wikipedia:Vorlagen-Parameterfehler/SUVA-MAK hastemplate:Infobox_Chemikalie -insource:/\| *CAS *= *\*/} 0]]

puts $lins:[llength $lins]

foreach ins $lins {
	incr i
	set cx [conts t $ins x]
	regexp -- {\{\{SUVA-MAK.*?\}\}} $cx rex
	set tp [parse_templ $rex]
	set c0 [conts t $ins 0]
	set cas [regexp -inline -line -- {\|[ ]?CAS.*} $c0]
	regexp -- {\d{1,8}-\d{1,8}-\d{1,8}} $cas cas
	if {{Abrufdatum} in $tp} {
		set abruf [utc ^ [dict get $tp Abrufdatum] {%e. %B %Y} %Y-%m-%d {}]
	} elseif {{Abruf} in $tp} {
		set abruf [dict get $tp Abruf]
	}
	puts \n$ins\n$rex\n$tp\n$cas\n$abruf
	set ntp "\{\{SUVA-MAK |Name=$ins |CAS-Nummer=$cas |Abruf=$abruf\}\}"
	set ncx [string map [list $rex $ntp] $cx]
	puts [edit $ins {Bot: [[:Vorlage:SUVA-MAK]] korrigiert (siehe [[Spezial:Diff/191818981/192638797|Diff]])} $ncx / minor]
	if {$i < 10} {gets stdin}
}

exit

set c5 [conts id 9364384 5]

set lcat [scat Träger_der_Litteris_et_Artibus 0]


set llink [get [post $wiki {*}$format / action parse / text $c5 / prop links / contentmodel wikitext] parse links]

foreach link $llink {
	dict with link {
		if {${*} ni $lcat} {
			puts \n${*}
			set rex [regexp -inline -- {\[\[Kategorie\:.*} [set c0 [conts t ${*} x]]]
			set nrex "\[\[Kategorie:Träger der Litteris et Artibus\]\]\n[join $rex]"
#			puts $nrex
			set nc0 [string map [list [join $rex] $nrex] $c0]
#			puts $nc0
			set summary {Bot: [[:Kategorie:Träger der Litteris et Artibus]] hinzugefügt}
			puts [edit ${*} $summary $nc0 / minor]
		}
	}
}

#puts $c5







exit

#read_file test3.token token
set token "/ token test"

puts [edit user:TaxonBot/Test Test \n\nTest9\n\n]
puts $token

#puts $token
#save_file test3.token $token


exit

set olrc {}
while 1 {
	while 1 {
		if ![catch {
			set lrc [get [post $wiki {*}$query {*}$format / list recentchanges / rcprop timestamp|title|ids|user|userid|comment|loginfo / rclimit 500] query recentchanges]
		}] {break}
	}
	if {$lrc ne $olrc} {
		foreach rc [lreverse $lrc] {
			if {$rc ni $olrc} {
#				puts \n
				dict with rc {
					if {$user ne {Schnabeltassentier}} {puts $rc}
#					puts $rc
#					if {$type eq {log} && $logaction eq {delete}} {
#						puts $rc
#					}
				}
#				puts $rcline
			}
		}
		set olrc $lrc
	} else {
		continue
	}
}

exit

cont {ret1 {
puts ----[incr xyz]
	foreach item [get $ret1 query recentchanges] {
		puts $item
	}
}} {*}$query {*}$format / list recentchanges / rclimit 10







exit

set conts [conts t {Liste von Vornamen/N} x]

set llink [lrange [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $conts]] 1 end-1]

foreach name $llink {
	if {[string first | $name] > -1} {
		lappend lname [lindex [split $name |] 1]
	} else {
		lappend lname $name
	}
}


foreach name $lname {
#set name {Elaine Aron}
set name "Elaine $name Aron"
puts $name:
set html [getHTML https://www.google.de/search?q='[join $name +]']
#puts $html ; gets stdin
#if [catch {
#set xml [[[dom parse -html [encoding convertfrom $html]] documentElement] asList]
#}] {puts Fehler ; continue}
puts [regexp -all -- "$name" $html]
}

exit

set c4 [conts t Benutzer:AsuraBot/Purges 4]
set ll4 [dict values [regexp -all -inline -line -- {^\* \[\[[:]?(.*?)[|\]].*$} $c4]]
set lpid {}
foreach l4 $ll4 {
lappend lpid [scat [join $l4] -14]
}
lassign {} plpid lplpid
foreach pid [join $lpid] {
incr i
lappend plpid $pid
if {$i == 500} {
lappend lplpid $plpid
lassign {0 {}} i plpid
}
}
lappend lplpid $plpid
set f [open test3.out w]
foreach plpid $lplpid {
puts $f [get [post $wiki {*}$format / action purge / pageids [join $plpid |] / forcelinkupdate 1]]
}
close $f
