#!/usr/bin/tclsh8.7
#exit

set editafter 5
#if {[exec pgrep -cxu taxonbot test3.tcl] > 1} {exit}

source api2.tcl ; set la de ; set project wikipedia ; source langwiki1.tcl ; #set token [login $wiki]
#puts $atoken ; puts $wiki ; set wikia $wiki
#source api.tcl ; set lang de ; source langwiki.tcl ; #set token [set btoken [login $wiki]]
#puts $btoken ; puts $wiki

set old_ [lindex $argv 0]
set new_ [lindex $argv 1]
set old  [string map {_ { }} $old_]
set new  [string map {_ { }} $new_]
set glinks [getHTML https://commons.wikimedia.org/w/index.php?title=Special:GlobalUsage&offset=&limit=500&target=[curl::escape $old_]]
set sglinks [split $glinks \n]
set llemma {}
foreach line $sglinks {
	if {[string first <ul> $line] > -1} {
		if ![empty llemma] {lappend lglinks [list $llemma]}
		set llemma {}
		lappend lglinks [lrange [split [lindex [split $line {<>}] end-4] { .}] 2 3]
		continue
	}
	if {[string first <li> $line] > -1} {
		lappend llemma [lindex [split $line {<>}] end-4]
		continue
	}
}
lappend lglinks [list $llemma]
puts [join $lglinks]

set zuq [format {([[c:GR|GR]]) [[File:%s]] → [[File:%s]]} $old $new]

if 0 {
read_file test3.db conts

puts $conts

set sconts [split $conts \n]
set mllang {}

foreach line $sconts {
	puts \n$line
	if {[string first Verwendung $line] > -1} {
		lappend llang $mllang
		set mllang {}
		lappend llang [lindex [regexp -inline -line -- {erwendung auf (.*?)\.} $line] 1]
	} else {
		lappend mllang [string trim $line]
	}
}
lappend llang $mllang

foreach {lang lpage} [lrange $llang 1 end] {
	puts "$lang : $lpage"
	puts [incr z]
}
}

foreach {la project llemma} [join $lglinks] {
	if {[lindex $argv 2] ne {fr}} {
		if {$la eq {fr} && $project eq {wikipedia}} {continue}
	}
	if {$la eq {www}} {continue}
	puts "\n\n====\n$la : $project : $llemma"
	source api2.tcl ; source langwiki1.tcl ; #set token [login $wiki]
	foreach lemma $llemma {
		if {$lemma eq {Wikipedia:WikiProjekt Wappen}} {continue}
		set ns [ns $lemma]
		if {$ns ni {2 3 6 7}} {
			set conts [conts t $lemma x]
			set nconts [string map [list $old $new $old_ $new_] $conts]
			puts \n$lemma:
			if {$nconts ne $conts} {
				puts [edit $lemma $zuq $nconts / minor]
			}
		}
	}
}

exit

foreach {la project lpage} [lrange $llang 1 end] {
#puts $la
	source api2.tcl ; set lang $la ; source langwiki1.tcl ; #set token [login $wiki]
	puts "$lang : $lpage"
	if {$lang eq {fr}} {continue}
	foreach page $lpage {
		set ns [ns $page]
		if {$ns ni {2 3 6 7}} {
			set conts [conts t $page x]
			set nconts [string map [list $old $new $old_ $new_] $conts]
			puts $page:
			if {$nconts ne $conts} {
				puts [edit $page $zuq $nconts / minor]
#				gets stdin
			}
#			if {[incr y] < 7} {gets stdin}
		}
	}
}

exit


source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]


set lins [insource {\>...bRUMMfUß!\]\]/} $argv]
#set lins [insource {\<tt\>/} $argv]
#set lins [insource [format {\<font color\=%s/} $argv] 4]
#set lins [insource {Friedrich Graf\/K/} x]
puts [set lenlins [llength $lins]]

#puts $lins

#foreach ins $lins {
#	if {[string first Adminkandidaturen $ins] > -1} {
#lappend lins1 $ins
#		set rox {}
#		puts $ins
#		set oc [conts t $ins x]
#		set rox [regexp -all -inline -line -- {<font.*?/font>} $oc]
#		foreach ox $rox {
#			lappend lox $ox
#		}
#	}
#}
#foreach ox [lsort -unique $lox] {
#	puts $ox
#}



set summ {Bot: Überarbeitung veralteter Syntax / [[H:LINT|HTML-Validierung]]}
set summ1 {Überarbeitung veralteter Syntax / [[H:LINT|HTML-Validierung]]}


set old1 {>...bRUMMfUß!]]</span>}
set new1 {>...bRUMMfUß!</span>]]}

if 0 {
set old2 {}
set new2 {}
set old3 {}
set new3 {}
set old4 {}
set new4 {}
set old5 {}
set new5 {}
set old6 {}
set new6 {}
set old7 {}
set new7 {}
set old8 {}
set new8 {}
set old9 {}
set new9 {}
set old10 {}
set new10 {}
}

if 0 {

set old1 {<font style="font-size: 10px; padding: 0px; margin: 0px;">[[Benutzer:Quadratmeter|B]] | [[Benutzer_Diskussion:Quadratmeter|D]]</font>}
set new1 {<span style="font-size: 10px;">[[Benutzer:Quadratmeter|B]] | [[Benutzer Diskussion:Quadratmeter|D]]</span>}
set old2 {[[Benutzer:Ncnever|<font color=#116611>ncnever</font>]]}
set new2 {[[Benutzer:Ncnever|<span style="color:#116611;">ncnever</span>]]}
set old3 {[[Benutzer:FarinUrlaub|<font color=#116611>FarinUrlaub</font>]]}
set new3 {[[Benutzer:FarinUrlaub|<span style="color:#116611;">FarinUrlaub</span>]]}
set old4 {[[Benutzer:Glückspirat|<font color=#116611>Freibeuter der Freude</font>]]}
set new4 {[[Benutzer:Glückspirat|<span style="color:#116611;">Freibeuter der Freude</span>]]}
set old5 {[[User:RacoonyRE|Racoony<font color="red">''RE''</font>]]}
set new5 {[[User:RacoonyRE|Racoony<span style="color:red;">''RE''</span>]]}
set old6 {[[Benutzer:Necrophorus|<font color="black">Necrophorus</font>]]}
set new6 {[[Benutzer:Necrophorus|<span style="color:black;">Necrophorus</span>]]}
set old7 {[[Benutzer:Necrophorus|<b font color="black">Necrophorus</font </b>]]}
set new7 {[[Benutzer:Necrophorus|<span style="color:black;">'''Necrophorus'''</span>]]}
set old8 {[[Benutzer:Necrophorus|<b font color="black">Necrophorus</font /b>]]}
set new8 {[[Benutzer:Necrophorus|<span style="color:black;">'''Necrophorus'''</span>]]}
set old9 {[[Benutzer:Necrophorus|<b font color="black">Necrophorus</font></b>]]}
set new9 {[[Benutzer:Necrophorus|<span style="color:black;">'''Necrophorus'''</span>]]}
set old10 {[[Benutzer:Necrophorus|'''<font color="black">Necrophorus</font>''']]}
set new10 {[[Benutzer:Necrophorus|<span style="color:black;">'''Necrophorus'''</span>]]}

set old11 {[[Benutzer:Xellos|<font color=#006611>Xellos</font>]]}
set new11 {[[Benutzer:Xellos|<span style="color:#006611;">Xellos</span>]]}
set old12 {<font face="Futura">[[Benutzer:Geolina163|Geolina]] <sup>mente et malleo</sup> [[Benutzer Diskussion:Geolina163|✎]]</font>}
set new12 {<span style="font-family:Futura;">[[Benutzer:Geolina163|Geolina]] <sup>mente et malleo</sup> [[Benutzer Diskussion:Geolina163|✎]]</span>}
set old13 {<font face="Monotype Corsiva" size="4">[[Benutzer:Rabenbaum|Rabenbaum]]</font>}
set new13 {<span style="font-family:'Monotype Corsiva'; font-size:1.28em;">[[Benutzer:Rabenbaum|Rabenbaum]]</span>}
set old14 {[[Benutzer:Widescreen|<font face="Comic Sans MS"><span style="color:#00008B"> Widescreen</span></font>]]}
set new14 {[[Benutzer:Widescreen|<span style="color:#00008B; font-family:'Comic Sans MS';"> Widescreen</span>]]}
set old15 {[[Benutzer:Widescreen|<font face="Comic Sans MS"><span style="color:#00008B"> WSC</span></font>]]}
set new15 {[[Benutzer:Widescreen|<span style="color:#00008B; font-family:'Comic Sans MS';"> WSC</span>]]}
set old16 {<sup>[[Benutzer:Nilreb|<span style="color:#00CD00"><b><font face="Lucida Handwriting">NIL</font></b></span>]]</sup>[[Benutzer Diskussion:Nilreb|<font color="#FF0000" face="HANA"><span style="background-color: #000000"> Disk.</span></font>]]}
set new16 {[[Benutzer:Nilreb|<sup style="color:#00CD00; font-family:'Lucida Handwriting';">'''NIL'''</sup>]][[Benutzer Diskussion:Nilreb|<span style="color:#FF0000; font-family:HANA; background-color: #000000;"> Disk.</span>]]}
set old17 {<span style="text-shadow:gray 0.1em 0.1em 0.2em; class=texhtml">[[Benutzer:111Alleskönner|<font face="Copperplate">Alleskoenner</font>]] [[Benutzer Diskussion:111Alleskönner|✉]] </span>}
set new17 {<span style="text-shadow:gray 0.1em 0.1em 0.2em;">[[Benutzer:111Alleskönner|<span style="font-family:Copperplate;">Alleskoenner</span>]] [[Benutzer Diskussion:111Alleskönner|✉]]</span>}
set old18 {[[Benutzer:Codc|<span style="color:black; font-family:'Comic Sans MS';">Codc </span>]]<sup>[[Benutzer Diskussion:Codc|<code style="border:none;">Disk </code>]]</sup><small>[[WP:RC|<tt>Chemie </tt>]]</small><sub>[[WP:MP|<tt>Mentorenprogramm</tt>]]</sub>}
set new18 {[[Benutzer:Codc|<span style="color:black;font-family:'Comic Sans MS';">Codc </span>]]<span style="font-family:monospace;"><sup>[[Benutzer Diskussion:Codc|Disk ]]</sup><small>[[WP:RC|Chemie ]]</small><sub>[[WP:MP|Mentorenprogramm]]</sub></span>}
set old19 {}
set new19 {}
set old20 {}
set new20 {}

set old21 {}
set new21 {}
set old22 {}
set new22 {}
set old23 {}
set new23 {}
set old24 {}
set new24 {}
set old25 {}
set new25 {}
set old26 {}
set new26 {}
set old27 {}
set new27 {}
set old28 {}
set new28 {}
set old29 {}
set new29 {}
set old30 {}
set new30 {}

}

foreach ins $lins {
	puts $ins
}

#exit

set offset 0
foreach ins [lreverse $lins] {
#if {[string first Wikipedia:Adminkandidaturen $ins] == -1} {continue}
#	append_file test3.out $ins
	puts "\n[incr i]/$lenlins: $ins:"
	if {$ins in {{Hilfe Diskussion:Wikisyntax/Validierung} {Benutzer Diskussion:Doc Taxon} {Hilfe Diskussion:Wikisyntax/Validierung/Liste} Benutzer:Martin1009/EditCounterOptIn.js Benutzer:Olliminatore/customToolbar.js MediaWiki:Gadget-Extra-Editbuttons.js}} {continue}
	if {[string first .js $ins] > -1} {continue}
#	if {[string first Adminkandidaturen $ins] > -1} {continue}
#	if {$ins eq {Benutzer Diskussion:Sargoth/Archiv/2012}} {set offset 1} else {if {$offset == 0} {continue}}
#	if {$ins ne {Benutzer Diskussion:PDD/ältere Diskussionen}} {continue}
#	if {$ins ne {Wikipedia:Löschkandidaten/24. August 2005}} {continue}
	set in	[conts t $ins x]
if 0 {{
	set sin [split $in \n]
	foreach line $sin {
		if {[string first {<tt } $line] > -1} {
			lappend lline [regexp -all -inline -line {<tt .*</tt>} $line]
		}
	}
}
puts $lline
puts [llength $lline]
set lline [lsort -unique $lline]
puts $lline
puts [llength $lline]
foreach line $lline {
	puts $line
}

exit
}
	set nin [string map [list $old1 $new1] $in]
#	set nin [string map [list $old5 $new5 $old18 $new18] $in]
#	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9 $old10 $new10 $old11 $new11 $old12 $new12 $old13 $new13 $old14 $new14 $old15 $new15 $old16 $new16 $old17 $new17 $old18 $new18] $in]
#	set nin	[string map [list $old1 $new1 $old2 $new2 $old3 $new3 $old4 $new4 $old5 $new5 $old6 $new6 $old7 $new7 $old8 $new8 $old9 $new9 $olda $newa $oldb $newb $oldc $newc $oldd $newd $olde $newe $oldf $newf $oldg $newg $oldh $newh $oldi $newi $oldj $newj $oldk $newk $oldl $newl $oldm $newm $oldn $newn $oldo $newo $oldp $newp $oldq $newq $oldr $newr $olds $news $oldt $newt $oldu $newu $oldv $newv $oldw $neww $oldx $newx $oldy $newy $oldz $newz $old10 $new10 $old11 $new11 $old12 $new12 $old13 $new13 $old14 $new14 $old15 $new15 $old16 $new16 $old17 $new17 $old18 $new18 $old19 $new19 $old20 $new20 $old21 $new21 $old22 $new22 $old23 $new23 $old24 $new24 $old25 $new25 $old26 $new26 $old27 $new27 $old28 $new28 $old29 $new29 $old30 $new30 $old31 $new31 $old32 $new32 $old33 $new33 $old34 $new34 $old35 $new35 $old36 $new36 $old37 $new37 $old38 $new38 $old39 $new39 $old40 $new40 $old41 $new41 $old42 $new42 $old43 $new43 $old44 $new44 $old45 $new45 $old46 $new46 $old47 $new47 $old48 $new48 $old49 $new49 $old50 $new50 $old51 $new51 $old52 $new52 $old53 $new53 $old54 $new54 $old55 $new55 $old56 $new56 $old57 $new57 $old58 $new58 $old59 $new59 $old60 $new60 $old61 $new61 $old62 $new62 $old63 $new63 $old64 $new64 $old65 $new65 $old66 $new66 $old67 $new67 $old68 $new68 $old69 $new69 $old70 $new70 $old71 $new71 $old72 $new72] $in]
#save_file test3.out $nin
#exit

#gets stdin
	if {$nin ne $in} {
		set out [edit $ins $summ $nin / minor]
		puts $out
		if {{protectedpage} in [split $out]} {
#			source api2.tcl ; set lang de1 ; set wiki curl1 ; #set token $atoken
			source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
			puts [edit $ins $summ1 $nin / minor]
			after 15000
			source api.tcl ; set lang de ; source langwiki.tcl; #set token [login $wiki]
		}
		if {[incr c] <= 5} {gets stdin}
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
