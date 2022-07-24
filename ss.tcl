#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#set debug 1

catch {if {[exec pgrep -cxu taxonbot ss.tcl] > 1} {exit}}

set editafter 1

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]

package require http
package require tls
package require tdom

source library.tcl

#set db [read [set f [open ss-2.db r]]] ; close $f
proc ausnahme val {
set db [get_db dewiki]
set ssdb [sqlcat Schauspieler 0]
set f [open ss-3.db w] ; puts $f "set ssdb [list $ssdb]" ; close $f
set Fdb [sqldeepcat Filmschauspieler 0]
set f [open ss-3.db a] ; puts $f "set Fdb [list $Fdb]" ; close $f
set Kdb [sqlcat Kinderdarsteller 0]
set f [open ss-3.db a] ; puts $f "set Kdb [list $Kdb]" ; close $f
set Mdb [sqlcat Musicaldarsteller 0]
set f [open ss-3.db a] ; puts $f "set Mdb [list $Mdb]" ; close $f
set Tdb [sqldeepcat Theaterschauspieler 0]
set f [open ss-3.db a] ; puts $f "set Tdb [list $Tdb]" ; close $f

set db [get_db enwiki]
set fdb [sqldeepcat {Film actors} 0]
set f [open ss-3.db a] ; puts $f "set fdb [list $fdb]" ; close $f
set tvdb [sqldeepcat {Television actors} 0]
set f [open ss-3.db a] ; puts $f "set tvdb [list $tvdb]" ; close $f
set tdb [sqldeepcat {Stage actors} 0]
set f [open ss-3.db a] ; puts $f "set tdb [list $tdb]" ; close $f
set mdb [sqldeepcat {Musical theatre actors} 0]
set f [open ss-3.db a] ; puts $f "set mdb [list $mdb]" ; close $f
set cdb [sqldeepcat {Child actors} 0]
set f [open ss-3.db a] ; puts $f "set cdb [list $cdb]" ; close $f
}

source ss-3.db

set out [read [set f [open ss.out r]]] ; close $f
set offsetitem [join [dict values [regexp -inline -line -- {^:(.*?):$} [join [lreverse [split $out \n]] \n]]]]
puts $offsetitem
#gets stdin
#input offsetitem "Offset: "



lassign {{[[:Kategorie:Schauspieler]]} {[[:Kategorie:Filmschauspieler]]} {[[:Kategorie:Kinderdarsteller]]} {[[:Kategorie:Musicaldarsteller]]} {[[:Kategorie:Theaterschauspieler]]} 0} katS katF katK katM katT offset
lassign {{[[Kategorie:Schauspieler]]} {[[Kategorie:Filmschauspieler]]} {[[Kategorie:Kinderdarsteller]]} {[[Kategorie:Musicaldarsteller]]} {[[Kategorie:Theaterschauspieler]]}} KatS KatF KatK KatM KatT
foreach item $ssdb {
	catch {
#		set item {Calista Flockhart}
		puts \n:$item:
		if {$item ne $offsetitem && !$offset} {continue} else {incr offset}
		set lang kat ; source langwiki.tcl ; #set token [login $wiki]
		lassign {{} 0} entitle kid
		foreach 1 [page [post $wiki {*}$query / titles $item / prop langlinks / lllimit max] langlinks] {
			if {[dict get $1 lang] eq {en}} {set entitle [dict get $1 *] ; break}
		}
#		if {$entitle eq {}} {continue} else {puts $entitle}
		if {$entitle ne {} && $item ni $Fdb && $item ni $Kdb && $item ni $Mdb && $item ni $Tdb && ($entitle in $tdb || $entitle in $mdb || $entitle in $cdb || $entitle in $fdb || $entitle in $tvdb)} {
			puts entitle:$entitle
			set born [dict values [regexp -inline -- {Kategorie:Geboren (\d{4})} [pagecat $item]]]
			set entity [page [post $wiki {*}$query / prop pageprops / titles $item / ppprop wikibase_item] pageprops wikibase_item]
			set lang d ; source langwiki.tcl ; #set token [login $wiki]
			set imdb [dict get [join [dict get [get [
				post $wiki {*}$format / action wbgetclaims / entity $entity
			] claims] P345]] mainsnak datavalue value]
			set lang kat ; source langwiki.tcl ; #set token [login $wiki]
			set html [getHTML http://www.imdb.com/name/$imdb/]
			if {[string first >Actress< $html] > -1} {
				set actor [regexp -inline -- {<a name="actress">Actress</a>.*?</div>\n</div>\n</?div(?:>| id)} $html]
			} else {
				set actor [regexp -inline -- {<a name="actor">Actor</a>.*?</div>\n</div>\n</?div(?:>| id)} $html]
			}
			set selfie [regexp -inline -- {<a name="self">Self</a>.*?</div>\n</div>\n</?div(?:>| id)} $html]
			set dateactor [dict values [regexp -all -inline -- {&nbsp;(\d{4})} $actor]]
			set dateself [dict values [regexp -all -inline -- {&nbsp;(\d{4})} $selfie]]
			set first [lindex [lsort -unique "$dateactor $dateself"] 0]
			if {[expr $first - $born] < 1} {
				continue
			} elseif {[expr $first - $born] < 14} {
				set kid 1
			} elseif {[expr $first - $born] > 13} {
				set kid 2
			}
#		puts $item:$imdb:$born:$first:$kid ; gets stdin
			set conts [conts t $item x]
			set nkats {}
			set summ "Bot: -$katS"
			if {$entitle in $fdb || $entitle in $tvdb} {append nkats $KatF\n ; append summ "; +$katF"}
			if {$entitle in $tdb && $entitle in $mdb} {continue}
			if {$entitle in $tdb} {append nkats $KatT\n ; append summ "; +$katT"}
			if {$entitle in $mdb} {append nkats $KatM\n ; append summ "; +$katM"}
			if {$kid == 1 || ($entitle in $cdb && $kid == 0)} {append nkats $KatK\n ; append summ "; +$katK"}
			puts nkats:\n$nkats\n$summ
			regsub -- {\[\[ ?Kategorie: ?Schauspieler\]\]\n} $conts $nkats nconts
			puts \n[edit $item $summ $nconts / minor]
#			set cats [pagecat $item]
#			puts $conts
#			input nkats "Kats: "
#			switch $nkats {
#				ftk	{
#							regsub -- {\[\[ ?Kategorie: ?Schauspieler\]\]\n} $conts $KatF\n$KatT\n$KatK\n nconts
#							puts [edit $item "Bot: -$katS; +$katF; +$katT; +$katK" $nconts / minor]
#						}
#			}
#			puts $nconts
#			if {$kid && {Kategorie:Kinderdarsteller} in $cats} {
#				set w 1
#				regsub -- {\[\[ ?Kategorie: ?Schauspieler} $conts {[[Kategorie:Filmschauspieler} nconts
#puts $w
#				puts $w:[edit $item "Bot: -$katS; +$katF" $nconts / minor]
#			} elseif {$kid && {Kategorie:Kinderdarsteller} ni $cats} {
#				set w 2
#				regsub -- {\[\[ ??Kategorie: ?Schauspieler.*?\n} $conts "\[\[Kategorie:Filmschauspieler\]\]\n\[\[Kategorie:Kinderdarsteller\]\]\n" nconts
#puts $w
#				puts $w:[edit $item "Bot: -$katS; +$katF; +$katK" $nconts / minor]
#			} elseif {!$kid && {Kategorie:Kinderdarsteller} in $cats} {
#				set w 3
#				regsub -- {\[\[ ??Kategorie: ?Kinderdarsteller.*?\n} $conts {} nconts
#				regsub -- {\[\[ ?Kategorie: ?Schauspieler} $nconts {[[Kategorie:Filmschauspieler} nconts
#puts $w
#				puts $w:[edit $item "Bot: -$katS; -$katK; +$katF" $nconts / minor]
#			} elseif {!$kid && {Kategorie:Kinderdarsteller} ni $cats} {
#				set w 4
#				regsub -- {\[\[ ?Kategorie: ?Schauspieler} $conts {[[Kategorie:Filmschauspieler} nconts
#puts $w
#				puts $w:[edit $item "Bot: -$katS; +$katF" $nconts / minor]
#			} else {
#				set w 5
#				set nconts $conts
#			}
		} else {continue}
#		if {[incr z] < 31} {gets stdin}
#		puts $conts\n$w:[pagecat $item] ; gets stdin
#		puts $nconts ; gets stdin
	}
}


exit

set db [read [set f [open ss-1.db r]]] ; close $f

foreach item $db {if {[string first heater [conts t $item x]] == -1} {puts $item ; lappend match $item}}

set f [open ss-2.db w] ; puts $f $match ; close $f









exit

#set f [open ss.db w] ; puts $f [lrange [cat Kategorie:Schauspieler 0] 1 end] ; close $f

set db [read [set f [open ss1.db r]]] ; close $f

foreach {1 2} $db {
	if [empty 2] {lappend 3 "# \[\[$1\]\]"}
}
puts [edit user:TaxonBot/SS {} [join $3 \n]]

exit

set db [read [set f [open ss.db r]]] ; close $f

foreach 1 $db {
	set c {}
	set contents [string tolower [contents t $1 x]]
	if {[string first film $contents] > -1} {lappend c f}
	if {[string first serie $contents] > -1} {lappend c f}
	if {[string first darstell $contents] > -1} {lappend c f}
	if {[string first porno $contents] > -1} {lappend c p}
	if {[string first theater $contents] > -1} {lappend c t}
	if {[string first variet $contents] > -1} {lappend c t}
	if {[string first kind $contents] > -1} {lappend c c}
	if {[string first jugend $contents] > -1} {lappend c c}
	if {[string first vivid $contents] > -1} {lappend c v}
	if {[string first stumm $contents] > -1} {lappend c s}
	if {[string first burg $contents] > -1} {lappend c b}
	if {[string first hof $contents] > -1} {lappend c h}
	if {[string first kammer $contents] > -1} {lappend c k}
	if {[string first musical $contents] > -1} {lappend c m}
	set c [lsort -unique $c]
	puts [set line [list $1 $c]]
	set f [open ss1.db a] ; puts $f $line ; close $f
#	if {[incr i] == 15} {exit}
}
