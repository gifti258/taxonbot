#!/usr/bin/tclsh8.7
#exit

set editafter 1

source api.tcl
set lang de ; source langwiki.tcl ; #set token [login $wiki]
#source procs.tcl
source library.tcl
#set db [get_db dewiki]

#package require http
#package require tls
#package require tdom

#gets stdin

set lpt [insource {books.google.*?\'.*?f\=false/} $argv]

puts $lpt
puts [llength $lpt]

set summary {Bot: Google-Books-Weblinks repariert}

foreach pt $lpt {
	unset -nocomplain lrx
	set nconts [set oconts [conts t $pt x]]
	set lrx [regexp -all -inline -line -nocase -- {books.google.*?[\n\s\]]} $oconts]
#	puts \n$pt:$lrx\n
	foreach rx $lrx {
		set nrx [string map [list \'\' \" \' \"] $rx]
		puts ->$rx\n->$nrx
		set nconts [string map [list $rx $nrx] $nconts]
	}
	puts \n[incr i]/[llength $lpt]\n$pt\n
#	if {[regexp -nocase {strike\>} $nconts]} {puts "!!! Fehler !!!" ; gets stdin ; continue}
	catch {
		if {$nconts ne $oconts} {
			input e "ersetzen? "
			if {$e ne {n}} {
				set out [edit $pt $summary $nconts / minor]
				puts $out
				if {{protectedpage} in [split $out]} {
					source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
					puts [edit $pt $summary1 $nconts / minor]
					after 15000
					source api.tcl ; set lang de ; source langwiki.tcl; #set token [login $wiki]
				}
			}
		}
	}
}






exit

set lpt [insource {[Ss][Tt][Rr][Ii][Kk][Ee]\>/} $argv]
puts $lpt
puts [llength $lpt]

set summary {Bot: [[H:LINT#Veraltetes HTML-Tag|HTML-Validierung]]: <strike> → <s>}
set summary1 {[[H:LINT#Veraltetes HTML-Tag|HTML-Validierung]]: <strike> → <s>}

foreach pt [lreverse $lpt] {
	unset -nocomplain lrx
	set nconts [set oconts [conts t $pt x]]
	set lrx [regexp -all -inline -line -nocase -- {\<strike\>.*?\</strike\>} $oconts]
	puts \n$pt:$lrx\n
	foreach rx $lrx {
		set nconts [string map -nocase {<strike> <s> </strike> </s>} $nconts]
	}
	puts \n$pt:$lrx\n
	if {[regexp -nocase {strike\>} $nconts]} {puts "!!! Fehler !!!" ; gets stdin ; continue}
	catch {
		if {$nconts ne $oconts} {
			input e "ersetzen? "
			if {$e ne {n}} {
				set out [edit $pt $summary $nconts / minor]
				puts $out
				if {{protectedpage} in [split $out]} {
					source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
					puts [edit $pt $summary1 $nconts / minor]
					after 15000
					source api.tcl ; set lang de ; source langwiki.tcl; #set token [login $wiki]
				}
			}
		}
	}
}

exit

puts [join $argv]
#foreach pt $lpt {}
	set pt [join $argv]
#	if {$pt eq {Hilfe:Textgestaltung}} {continue}
	catch {}
		set nconts [set oconts [conts t $pt x]]
		set lrx [regexp -all -inline -line -- {<strike>.*?</strike>} $oconts]
		if {[string first \n $lrx] > -1} {puts Fehler ; exit}
		puts $pt:\n$lrx\n
#		puts [decr i]:$pt:\n$lrx\n
		foreach rx $lrx {
			set nrx [string map -nocase {<strike> <s> </strike> </s>} $rx]
			set nconts [string map [list $rx $nrx] $nconts]
		}
		if {$nconts ne $oconts} {
			after 15000
			puts [set out [edit $pt $summary $nconts / minor]]\n
		}
#		if {[string first protectedpage $out] > -1} {exec ./test1.tcl $pt &}
puts	{}
#	if {[incr i] < 5} {gets stdin}
puts {}
#puts \a

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

