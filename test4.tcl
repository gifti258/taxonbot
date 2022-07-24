#!/usr/bin/tclsh8.7
#exit

set editafter 1
#if {[exec pgrep -cxu taxonbot test4.tcl] > 1} {exit}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
#source procs.tcl
#source library.tcl
#set db [get_db dewiki]

#package require http
#package require tls
#package require tdom

#set rc [getHTML https://de.wikipedia.org/w/index.php?title=Special:Contributions/TaxonBota&offset=&limit=5000&target=TaxonBota]

#puts $rc

read_file test4e.out projects
read_file test4f.out newtitle

set lproject [split $projects \n]
puts $newtitle
puts $lproject

set project {Benutzer:Wartungsstube/Landkreis Prignitz}
set oconts [conts t $project x]

puts $oconts

regexp -- {<!--MB-NeueArtikel-->\n(.*?)\n<!--MB-NeueArtikel-->} $oconts -- oldlist

puts $oldlist
set newlist "<!--MB-NeueArtikel-->\n<!--MB-NeueArtikel-->"

foreach project $lproject {
	puts \n\n
	lassign {} oldlist loldlist
	set project [join $project]
	puts $project
	set oconts [conts t $project x]
	regexp -- {<!--MB-NeueArtikel-->\n(.*?)\n<!--MB-NeueArtikel-->} $oconts loldlist oldlist
	puts $oldlist
	puts $loldlist
	if ![empty oldlist] {
		puts [edit $project {Bot: Reset NeueArtikel aufgrund Prozessfehler, NeueArtikel werden im nächsten Schritt wieder eingetragen} [string map [list $loldlist $newlist] $oconts] / minor]
	}
	if {[incr zz] < 10} {gets stdin}
}





exit

foreach line [split $rc \n] {
	lappend lline [dict values [regexp -inline -- {contributions-title" title\="(.*?)"\>} $line]]
}

save_file test4e.out [join $lline \n]


exit

set ls [split $rc \n]

#save_file test4a.out $ls

foreach {1 2 3 4 5 6 7} $ls {
	lappend lincr [incr zzzz]:$1|$2|$3|$4|$5|$6|$7
#	if {$zzzz == 10} {exit}
}

save_file test4b.out [join $lincr \n]

exit

read_file contribtool0.out c
#puts $c

set url0 http://de.wikipedia.org/w/index.php?
set urld http://devilman.fandom.com/wiki/Devilman_Saga?
set userd https://devilman.fandom.com/wiki/User:

foreach line [split $c \n] {
	set line [string map [list $url0 $urld] $line]
	input oldid "\noldid: "
	input user "user: "
	regsub -all -- {oldid=\d{9}} $line "oldid=$oldid" line
	if ![empty user] {
		regsub -- {\[\[:user:Doc Taxon\|Doc Taxon\]\]} $line "\[$userd$user $user\]" line
	}
	puts \n$line
	lappend lline $line
}

puts [join $lline \n]
append_file contribtool0.out [join $lline \n]

exit

set summ {Bot: Parameterkorrektur: [[Vorlage:Unsigniert]] ist ohne Signatur zu verwenden; diese aufgrund Problemen bezüglich [[H:LINT]] entfernt}
set summ1 {Parameterkorrektur: [[Vorlage:Unsigniert]] ist ohne Signatur zu verwenden; diese aufgrund Problemen bezüglich [[H:LINT]] entfernt}

read_file test4.db t

set lt [split $t \n]

foreach t $lt {
	if {[string first \[ $t] > -1} {lappend lc $t}
}

set offset 0
set llc [llength $lc]
foreach c $lc {
	puts \n\n[incr i]:$llc
	puts ====\n[lindex $c 0]:
#	puts [lindex $c end]\n
	if {[lindex $c 0] ne {Wikipedia:Löschkandidaten/10. Juli 2019}} {if !$offset {continue}} else {set offset 1}
	set conts [conts t [lindex $c 0] x] ; set nconts $conts
	foreach typetempl [lindex $c end] {
		foreach templ $typetempl {
			if {[string first \[ $templ] > -1 && [regexp -all \} $templ] > 3} {
#				puts [regexp -all -inline -line -nocase {\{\{[ ]?unsigniert.*?\}\}} $templ]
#				puts [regexp -all -inline -line -nocase {\{\{[ ]?unsigned.*?\}\}} $templ]
#				puts [regexp -all -inline -line -nocase {\{\{[ ]?nicht unterschrieben.*?\}\}} $templ]
				puts $templ
				input templ "\nTemplate: "
				if [empty templ] {continue}
				set ptempl [parse_templ $templ]
				puts $ptempl
				dict with ptempl {
					set ntempl $TEMPLATE
					append ntempl |$1
					catch {if {[string first \[\[ $2] == -1} {append ntempl |$2}}
					catch {if {[string first \[\[ $3] == -1} {append ntempl |$3}}
					catch {if {[string first \[\[ $ALT] == -1} {append ntempl |ALT=$ALT}}
					set ntempl [format {{{%s}}} $ntempl]
					puts $ntempl
					set nconts [string map [list $templ $ntempl] $nconts]
					unset -nocomplain TEMPLATE 1 2 3 ALT templ ptempl ntempl
				}
			}
		}
	}
	if {$nconts ne $conts} {
		set out [edit [lindex $c 0] $summ $nconts / minor]
		puts $out
		if {{protectedpage} in [split $out]} {
			source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
			puts [edit [lindex $c 0] $summ1 $nconts / minor]
			after 5000
			source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
		}
#		gets stdin
	}
}
#puts [llength $lc]
#puts $ic



exit

set ltempl [template1 Vorlage:Unsigniert x]
puts $ltempl
puts [set lenltempl [llength $ltempl]]

foreach templ $ltempl {
	puts "\n[incr i]/$lenltempl: $templ"
	set c [conts t $templ x]
	append_file test4.db [list $templ [list [
		regexp -all -inline -line -nocase {\{\{[ ]?unsigniert.*?\}\}} $c
	] [
		regexp -all -inline -line -nocase {\{\{[ ]?unsigned.*?\}\}} $c
	] [
		regexp -all -inline -line -nocase {\{\{[ ]?nicht unterschrieben.*?\}\}} $c
	]]]
}




exit

set lpt [lsort [insource {\{\{!-\}\}|\{\{\(!\}\}|\{\{!\)\}\}|\{\{!!\}\}/} 4]]
puts $lpt
puts [llength $lpt]



foreach pt $lpt {
	if {$pt in {{Wikipedia:WikiProjekt Vorlagen/Werkstatt} {Wikipedia:Administratoren/Anfragen}}} {continue}
	if {[string first /Archiv $pt] > -1} {continue}
	puts $pt
	set oc [conts t $pt x]
	set nc [string trim [string map [list {{{!-}}} {{{!}}-} \n\{\{\(!\}\} \n\{\{\{!\}\} \{\{\(!\}\} \n\{\{\{!\}\} \{\{!\)\}\} \{\{!\}\}\} {{{!!}}} {{{!}}{{!}}}] $oc]]
	puts [edit $pt {Ersetzung der obsoleten Vorlagen {{!-}}, {{(!}}, {{!)}} und {{!!}} mit der Parser-Funktion {{!}}} $nc / minor]
#	if {[incr i] < 10} {gets stdin}
	after 15000
	incr a
	if {$a in {2 4 7 8}} {
		after 15000
	} elseif {$a in {1 5 9}} {
		after 30000
	} elseif {$a in {3 6 0}} {
		after 45000
	}
}

exit

puts [mysqlsel $db {select page_title from page join templatelinks on page_id = tl_from where page_namespace = 10 and tl_title = '!-';} -flatlist]

exit

set test4db [read [set f [open test4.db r]]] ; close $f
set test4db [lrange [lreverse [split $test4db \n]] 1 end]

foreach item $test4db {
	regexp -- {(2.*?) \(Versionen\)} $item -- itempart
	lappend ditem [list timestamp [lindex $itempart 0] title [lrange $itempart 1 end]]
}
foreach d $ditem {
	dict with d {
		if [catch {backlinks $title 100}] {puts $timestamp:$title\n[conts t $title x]}
	}
}

exit


exit

set lpt [dcat list Titularbistum 0]

foreach pt $lpt {
	set lrex [dict values [regexp -all -inline -nocase -- {(\[\[Kategorie:Titularerz.*?\]\])} [set oc [conts t $pt x]]]]
	puts $pt:$lrex:[llength $lrex]
	if {[llength $lrex] == 1 && [string first | $lrex] == -1} {
		set ncat [string map [list \]\] |[lrange $pt 1 end]\]\]] $lrex]
		puts $ncat
		set nc [string map [list [join $lrex] [join $ncat]] $oc]
		puts [edit $pt {Bot: Sortierung im [[:Kategorie:Titularbistum|Kategoriebaum Titularbistum]]} $nc / minor]\n
	}
}

exit

if 0 {
set olrc {}
while 1 {
	while 1 {
		if ![catch {
			set lrc [get [post $wiki {*}$query {*}$format / list recentchanges / rcnamespace 0 / rcprop timestamp|title|ids|user|comment / rclimit 500] query recentchanges]
		}] {break}
	}
	if {$lrc ne $olrc} {
		foreach rc [lreverse $lrc] {
			if {$rc ni $olrc} {
#				puts \n
[6~#				puts $rc
				dict with rc {
					lappend rcline pageid $pageid ns $ns title $title revid $revid parentid $old_revid user $user timestamp $timestamp comment $comment
				}
#				puts $rcline
				set ts [split $timestamp -T]
				set ts [lindex $ts 0][lindex $ts 1][lindex $ts 2]
				if {$ts == [clock format [clock seconds] -format %Y%m%d]} {
					set f [open rc/rc$ts.db a] ; puts $f $rcline ; close $f
				}
				set rcline {}
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

}

set conts [conts t {Liste von Vornamen/M} x]

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
set name "Julia $name Bracken"
#puts $name:
set html [getHTML https://www.bing.com/search?q='[join $name +]']
#puts $html ; gets stdin
#if [catch {
#set xml [[[dom parse -html [encoding convertfrom $html]] documentElement] asList]
#}] {puts Fehler ; continue}
set rex [regexp -all -- "$name" $html]
#puts $rex
if {$rex >= 4} {puts $name:$rex}
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
