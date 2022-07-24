#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#set editafter 500

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl

proc labeldesc e {
	global wiki get format ennl ennd denl dend
	foreach {kent ent} {dlabel labels ddesc descriptions} {
		while 1 {
			if [catch {set $kent [get [post $wiki {*}$get {*}$format / action wbgetentities / ids $e / props $ent] entities $e $ent]}] {
				continue
			} else {
				break
			}
		}
	}
	foreach {l nl nd} [list en $ennl $ennd de $denl $dend] {
		if {$l eq {en}} {
			try {set $l\label "\[\[$e\]\]<br />[dict get $dlabel $l value]"} on 1 {} {set $l\label "\[\[$e\]\]<br />'''$nl'''"}
		} else {
			try {set $l\label "[dict get $dlabel $l value]"} on 1 {} {set $l\label '''$nl'''}
		}
		try {set $l\desc [dict get $ddesc $l value]} on 1 {} {set $l\desc '''$nd'''}
		set $l\desc [string map {{"} {\"}} [subst $$l\desc]]
		if {[llength [subst $$l\desc]] >= 5} {set $l\desc "[lrange [subst $$l\desc] 0 4] ..."}
	}
	return "$enlabel<br /><small>$endesc</small><br />$delabel<br /><small>$dedesc</small>"
}
lassign {{No label defined} {No description defined} {Keine Bezeichnung vorhanden} {Keine Beschreibung vorhanden}} ennl ennd denl dend
set lcspiel {Q11410 Q11416 Q13698 Q47054 Q131436 Q142714 Q160738 Q189409 Q215206 Q216749 Q239092 Q274079 Q299191 Q438419 Q510406 Q532716 Q573573 Q690264 Q734698 Q750693 Q788553 Q839864 Q877517 Q895060 Q924588 Q955224 Q985834 Q998840 Q1036289 Q1054898 Q1140722 Q1150710 Q1188693 Q1191150 Q1272194 Q1368898 Q1497658 Q1499881 Q1509934 Q1515156 Q1643932 Q1774662 Q1783817 Q2056928 Q2144077 Q2164067 Q3244175 Q3590573 Q3742351 Q5037279 Q5161688 Q5188437 Q5249796 Q5282744 Q7492302 Q10924689 Q10927576 Q14947863 Q15220419 Q15804899 Q18703581 Q21608615 Q30145312}

if 0 {

set db [get_db wikidatawiki]
mysqlreceive $db "
	select page_title
	from page c, pagelinks d
	where d.pl_from = c.page_id and page_id in (
		select page_id
		from page a, pagelinks b
		where b.pl_from = a.page_id and a.page_namespace = 0 and b.pl_title = 'P31' and b.pl_namespace = 120
	) and c.page_namespace = 0 and d.pl_title in ('[join $lcspiel ',']') and d.pl_namespace = 0
;" {pt} {
#	puts $pt
	set lv31 {}
	while 1 {
		if [catch {set lv31 [get [post $wiki {*}$get {*}$format / action wbgetclaims / entity $pt] claims P31]}] {
			continue
		} else {
			break
		}
	}
	foreach v31 $lv31 {
		if {[set cspiel [dict get $v31 mainsnak datavalue value id]] in $lcspiel} {
			dict lappend dv31 $pt $cspiel
		}
	}
}
mysqlclose $db

set f [open spiel.db w] ; puts $f $dv31 ; close $f
#exit
}

#
set dv31 [read [set f [open spiel.db r]]] ; close $f
#

foreach {k v} $dv31 {lappend bdv31 [string trimleft $k Q] [lsort -unique $v]}
set bdv31 [lsort -stride 2 -index 0 -integer $bdv31]
unset dv31
foreach {k v} $bdv31 {lappend dv31 Q$k $v}
foreach {k v} $dv31 {
	puts \n$k
	unset -nocomplain lv
	foreach c $v {
		lappend lv [labeldesc $c]
	}
	while 1 {
		if [catch {set lclaims [get [post $wiki {*}$get {*}$format / action wbgetclaims / entity $k] claims]}] {
			continue
		} else {
			break
		}
	}
	lassign {} pauth lauth lpub bgg lg
	foreach {cl v} $lclaims {
		if {$cl in {P50 P170 P178 P287}} {
			catch {
				switch $cl {
					 P50	{set pauth {([[Property:P50|P50]] author)}}
					P170	{set pauth {([[Property:P170|P170]] creator)}}
					P178	{set pauth {([[Property:P178|P178]] developer)}}
					P287	{set pauth {([[Property:P287|P287]] designed by)}}
				}
				lappend lauth "$pauth [labeldesc [dict get [join [dict get $lclaims $cl]] mainsnak datavalue value id]]"
			}
		}
		if {$cl eq {P123}} {
			catch {
				lappend lpub "[labeldesc [dict get [join [dict get $lclaims P123]] mainsnak datavalue value id]]"
			}
		}
		if {$cl eq {P2339}} {
			set bgg [dict get [join [dict get $lclaims P2339]] mainsnak datavalue value]
		}
		if {$cl eq {P3528}} {
			set lg [dict get [join [dict get $lclaims P3528]] mainsnak datavalue value]
		}
	}
	if [empty lauth]	{set lauth	'''missing'''}
	if [empty lpub]	{set lpub	'''missing'''}
	if [empty bgg]		{set bgg		'''missing'''}
	if [empty lg]		{set lg		'''missing'''}
	if {{P577} in [dict keys $lclaims]} {
		regexp -- {\+(.*?)T} [dict get [join [dict get $lclaims P577]] mainsnak datavalue value time] -- pubtime
		if {[string first {-00-00} $pubtime] > -1} {
			set pubtime [string range $pubtime 0 3]
		} elseif {[string first {-00} $pubtime] > -1} {
			set pubtime [clock format [clock scan [string range $pubtime 0 6] -format %Y-%m] -format {%B %Y}]
		} else {
			set pubtime [string trim [clock format [clock scan $pubtime -format %Y-%m-%d] -format {%e %B %Y}]]
		}
	} else {
		set pubtime '''missing'''
	}
	puts "[labeldesc $k]\n[join $lv {<br />}]\n[join $lauth {<br />}]\n[join $lpub {<br />}]\n$pubtime\n$bgg\n$lg"
	lappend lspiel "| [labeldesc $k]\n| [join $lv {<br />}]\n| [join $lauth {<br />}]\n| [join $lpub {<br />}]\n| $pubtime\n| $bgg\n| $lg"
#	if {$k eq {Q113370}} {break}
}

puts \{|\n[join $lspiel "\n|-\n"]\n|\}
set nconts "Last modified: [utc ^ seconds {} {%Y-%m-%d %H:%M:%S} {}] (UTC) by \[\[user:TaxonBot|TaxonBot\]\]\n\n\{| class=\"wikitable sortable\"\n! item !! category !! author !! publishing !! publ. date !! BoardGameGeek ID !! Luding game ID\n|-\n[join $lspiel "\n|-\n"]\n|\}"
puts [edit user:Achim_Raschka/Game {Bot: List actualized} $nconts]

exit
