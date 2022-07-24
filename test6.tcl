#!/usr/bin/tclsh8.7
#exit

set editafter 1
#if {[exec pgrep -cxu taxonbot test3.tcl] > 1} {exit}

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]

set lal [wb_get_alias Q37492499 {}]
foreach {lang al} $lal {
#	puts $lang
	if {[dict get {*}$al value] eq {Defalco}} {
		lappend res $lang [format {{DeFalco}}]
	}
}
#wb_change_alias Q37492499 Defalco DeFalco ja

puts $res

#lappend claims [format {aliases {uz {%s} vep {%s}}} DeFalco DeFalco]

lappend claims [format {aliases {%s}} $res]
puts $claims

#d_edit_entity1 Q37492499 $claims

exit

read_file test6a.db db

puts [string length $db]
puts [edit {Benutzer:Doc Taxon/Test4} {Bot: font color-Liste 10} {} / appendtext [string range $db 1000001 end]]

exit

set lins [insource {\<font color\=\"/} $argv]
#set lins [insource [format {\<font color\=\"%s/} $argv] 4]
#set lins [insource {Friedrich Graf\/K/} x]
puts [set lenlins [llength $lins]]

set summ {Bot: Überarbeitung veralteter Syntax / [[H:LINT|HTML-Validierung]]}
set summ1 {Überarbeitung veralteter Syntax / [[H:LINT|HTML-Validierung]]}

foreach ins $lins {
	puts "\n[incr i]/$lenlins: $ins:"
	set lrex [dict values [regexp -all -inline -line -- {(<font color=.*?)\d\d:\d\d} [conts t $ins x]]]
	foreach rex $lrex {
		puts $rex
		append_file test6.db $rex
	}
}

















exit

set old1 {<span style="font-variant:small-caps; font-size: 1.1em;"><font color="green">[[Benutzer:AK09|AK09]]</font></span>}
set old2 {<span style="font-variant:small-caps; font-size: 1.1em;"><font color="wine">[[Benutzer:AK09|AK09]]</font></span>}
set new1 {[[Benutzer:AK09|<span style="font-variant:small-caps; font-size: 1.1em; color:green;">AK09</span>]]}
set new2 {[[Benutzer:AK09|<span style="font-variant:small-caps; font-size: 1.1em; color:#722f37;">AK09</span>]]}
set old3 {<span style="font-variant:small-caps; font-size: 1.1em;"><font color="red">[[Benutzer:S 400 HYBRID|S 400 H]]</font></span>}
set old4 {<span style="font-variant:small-caps; font-size: 1.1em;"><font color="green">[[Benutzer:S 400 HYBRID|S 400 H]]</font></span>}
set new3 {[[Benutzer:S 400 HYBRID|<span style="font-variant:small-caps; font-size: 1.1em; color:red;">S 400 H</span>]]}
set new4 {[[Benutzer:S 400 HYBRID|<span style="font-variant:small-caps; font-size: 1.1em; color:green;">S 400 H</span>]]}
set old5 {<font color="#0000FF">[[Benutzer:NBarchiv|NB/archiv]]</font>}
set new5 {[[Benutzer:NBarchiv|<span style="color:#0000FF;">NB/archiv</span>]]}
set old6 {<font color="#008080">[[User:Olliminatore|Ολλίμίνατορέ]]</font>}
set old7 {<font color="teal">[[User:Olliminatore|Ολλίμίνατορέ]]</font>}
set old8 {<font face="serif"> [[User:Olliminatore|Ολλίμίνατορέ]]</font>}
set old9 {<font face="serif">[[User:Olliminatore|Ολλίμίνατορέ]]</font>}
set olda {<font color="teal" face="serif">[[User:Olliminatore|Ολλίμίνατορέ]]</font>}
set oldb {<font face="serif">&nbsp;[[User:Olliminatore|Ολλίμίνατορέ]]</font>}
set new6 {[[User:Olliminatore|<span style="color:#008080;">Ολλίμίνατορέ</span>]]}
set new7 {[[User:Olliminatore|<span style="color:teal;">Ολλίμίνατορέ</span>]]}
set new8 {<span style="font-family:serif;"> [[User:Olliminatore|Ολλίμίνατορέ]]</span>}
set new9 {<span style="font-family:serif;">[[User:Olliminatore|Ολλίμίνατορέ]]</span>}
set newa {[[User:Olliminatore|<span style="color:teal; font-family:serif;">Ολλίμίνατορέ</span>]]}
set newb {<span style="font-family:serif;">&nbsp;[[User:Olliminatore|Ολλίμίνατορέ]]</span>}
set oldc {<sub><font color="orange">[[Benutzer Diskussion:Chokocrisp|Senf]]</font></sub>}
set newc {[[Benutzer Diskussion:Chokocrisp|<sub style="color:orange;">Senf</sub>]]}
set oldd {'''<font color="#0000FF">[[User:Jayen466|JN]]</font><small></small>''<font color=" #FFBF00">[[Benutzer Diskussion:Jayen466|466]]</font>'''''}
set olde {<font color=" #FFBF00">[[User_Talk:Jayen466|JN]]</font>}
set newd {'''[[User:Jayen466|<span style="color:#0000FF;">JN</span>]]''[[Benutzer Diskussion:Jayen466|<span style="color:#FFBF00;">466</span>]]'''''}
set newe {[[User talk:Jayen466|<span style="color:#FFBF00;">JN</span>]]}
set oldf {[[Benutzer_Diskussion:Fossa|?!]]</font></sub><sup><font color="green">[[Benutzer:Fossa/Bewertung| ±]]</font></sup>}
set newf {[[Benutzer:Fossa|<span style="color:#886600;">Fossa</span>]][[Benutzer_Diskussion:Fossa|<sub style="color:#330033;">?!</sub>]][[Benutzer:Fossa/Bewertung| <sup style="color:green;">±</sup>]]}
set oldg {<font color="#8B3E2F">[[Benutzer:Petar Marjanovic|Þetar]]</font><nowiki/><small><font color="#8B2500">[[Benutzer_Diskussion:Petar_Marjanovic|M]]</font><font color="darkgreen">[[Benutzer:Petar Marjanovic/Bewertung|&plusmn;]]</font></small>}
set newg {[[Benutzer:Petar Marjanovic|<span style="color:#8B3E2F;">Þetar</span>]][[Benutzer Diskussion:Petar Marjanovic|<small style="color:#8B2500;">M</small>]][[Benutzer:Petar Marjanovic/Bewertung|<small style="color:darkgreen;">&plusmn;</small>]]}

set offset 0
foreach ins $lins {
#	append_file test3.out $ins
	puts "\n[incr i]/$lenlins: $ins:"
	if {$ins eq {Hilfe Diskussion:Wikisyntax/Validierung}} {continue}
#	if {$ins eq {Benutzer Diskussion:Srbauer/Archiv6}} {set offset 1} else {if {$offset == 0} {continue}}
#	if {$ins eq {Benutzer Diskussion:PDD}} {continue}
#	if {$ins ne {Benutzer Diskussion:Kriddl/Archiv}} {continue}
	set in	[conts t $ins x]
#	set nin [string map [list $old1 $new1] $in]
#	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9] $in]
	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9 $olda $newa $oldb $newb $oldc $newc $oldd $newd $olde $newe $oldf $newf $oldg $newg] $in]
#save_file test3.out $nin
#exit

	if {$nin ne $in} {
		set out [edit $ins $summ $nin / minor]
		puts $out
		if {{protectedpage} in [split $out]} {
			source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
			puts [edit $ins $summ1 $nin / minor]
			after 5000
			source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
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
