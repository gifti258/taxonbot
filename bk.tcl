#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

set editafter 1

source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]

proc get_rand {} {
	while 1 {
		if {[set rand [string trimleft [string range [expr rand()] end-3 end] 0]] <= 5000} {
			return [expr $rand + 10000]
		}
	}
}

set i 0
foreach var {h g v vv} {
	set $var [utc -> seconds {} %Y%m%d "-$i days"]
#set g		[utc -> seconds {} %Y%m%d {-1 day}]
#set v		[utc -> seconds {} %Y%m%d {-2 days}]
#set vv	[utc -> seconds {} %Y%m%d {-3 days}]
	incr i
}

input us 						{Benutzer:           }
input date						{Datum (h/g/v/vv/*): }
input nr 						{Ticket No.:         }
set nr [expr {$date in {h g v vv} ? [set $date] : $date}]100[expr {[string length $nr] < 5 ? 0 : {}}]$nr
puts $nr
input fp 						{Firma/privat:       }
switch $fp {
	f {input fa 				{Firma:              }
			if [empty fa] {set fa $us}					}
	p {input nm 				{Name:               }
			if [empty nm] {set nm $us}					}
}
input dm 						{Domain:             }
if {$fp eq {f}} {input ar 	{Artikel:            }}
switch $fp {
	f {set line "\{\{\{Benutzerkonto verifiziert|[string trim $nr]|$fa|$dm[expr {$ar ne {} ? "|Artikel=$ar" : {}}]\}\}\n----\n\n\}"}
	p {set line "\{\{\{Benutzerkonto verifiziert|[string trim $nr]|$nm[expr {$dm ne {} ? "|$dm" : {}}]|Privatperson=ja\}\}\n----\n\n\}"}
}
lassign {{VRTS: Benutzerkonto verifiziert} {Freigabe nach Aufhebung der Benutzersperre} 0} bv rs gbn
if {		 [dict exists {*}[get [post $wiki {*}$get / list users / ususers $us / usprop blockinfo] query users] blockid]
		&& ([dict exists [page [post $wiki {*}$get / titles user:$us / prop info]] missing]
		||  [string match *{{GBN}}* [contents t user:$us x]]
		||  [string match {*{{Gesperrter Benutzer (nicht verifizierter Benutzername)}}*} $contents]
		||	 [string match -nocase *#WEITERLEITUNG* $contents]
		||	 [string match -nocase *#REDIRECT* $contents]
			)} {
	puts \n[get [post $wiki {*}$format {*}$token / action unblock / user $us / reason $bv]]
	after [get_rand]
	puts \n[get [post $wiki {*}$format {*}$token / action protect / title user:$us / protections edit=all|move=all / reason $rs]]
	after [get_rand]
	puts \n[get [post $wiki {*}$format {*}$token / action protect / title BD:$us / protections edit=all|move=all / reason $rs]]
	after [get_rand]
	incr gbn
} elseif [dict exists {*}[get [post $wiki {*}$get / list users / ususers $us / usprop blockinfo] query users] blockid] {
	puts "\nmit Fehlern beendet\n"
	exit
}
puts \n[join $line] ; gets stdin
puts \n[edit user:$us $bv {*}[expr {$gbn ? $line : "{} / prependtext $line"}]]\n
if [dict exists [page [post $wiki {*}$get / titles BD:$us / prop info]] missing] {exit}
if $gbn {
	puts \n[edit BD:$us $bv {}]\n
	exit
}
unset -nocomplain ix
foreach sc [get [post $wiki {*}$parse / page BD:$us / prop sections] parse sections] {
	dict with sc {
		if {$line in {Benutzername {Dein Benutzername} {Problem mit dem Benutzernamen}}} {
			set ix $index
			break
		}
	}
}
if ![exists ix] {
	exit
} else {
	set sccont [contents t BD:$us $ix]
	regexp -- {(\[\[Kategorie:Benutzer:Verifizierung angefordert (\d{4}-\d{2}).*?\]\]\n\n)} $sccont -- catline cat
#	if ![exists catline] {
#		set sccont_new $sccont\n\{\{erledigt|~~~~\}\}
#		puts \n[edit BD:$us {Benutzerkonto-Verifizierung erledigt} $sccont_new / section $ix / minor true]\n
#		exit
#	}
	set sccont_new "[string map [list $catline {}] $sccont]\n\{\{erledigt|Erledigt, das Konto wurde verifiziert. ~~~\}\}"
#	puts $sccont_new ; gets stdin
	puts \n[edit BD:$us {VRTS: Benutzerkonto-Verifizierung erledigt} $sccont_new / section $ix / minor true]\n
	set tab WP:Benutzerverifizierung/Benutzernamen-Ansprachen/
	contents t [append tab [clock format [clock scan $cat-01 -format %Y-%m-%d -locale de] -format %B%Y -locale de]] x
	regsub -all -- {^(\|)(\{\{)} $contents {\1 \2} contents
	regsub -- "\\|-\n\\| \{\{Benutzer\\| ??$us.*?(\\|-|\\|\})" $contents \\1 verilist
	if {$verilist ne $contents} {
		source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
		puts \n[edit $tab "Bot: -\[\[user:$us|$us\]\]; Benutzerkonto verifiziert" $verilist]\n
	}
}
