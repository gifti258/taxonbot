#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot minekl.tcl] > 1} {exit}}

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db dewiki]

if 0 {

# Strunz8 1399045
# Strunz9 3225534
# Dana 4287967,4289027,4291344,4291381,4291567,4295663,4296956,4295808,4299848
set s8id 3225534
set llines8 [regexp -all -line -inline -- {\*.*?([IV].*?):.*?$} [conts id $s8id x]]
foreach {lines8 nr} $llines8 {
	set lmineral [dict values [regexp -all -inline -- {\[\[(.*?)[|\]]} $lines8]]
	foreach mineral $lmineral {
		lappend dk $nr $mineral
	}
}

unset -nocomplain lmineral
mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_id in ([dcat sqlid Mineral 0]) and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Infobox_Mineral'
	order by page_title
;" pt {
	lappend lmineral [sql -> $pt]
}

foreach mineral $lmineral {
	if {[string first "[set s8nr [string trim [dict values [regexp -line -inline -- {\| Kurzform_Strunz_9.*?\=.*?([IV].*?$)} [regsub -all -- {<ref.*?>} [conts t $mineral x] {}]]]]] $mineral" [string map [list \{ {} \} {}] $dk]] == -1} {if [catch {lappend errorlist "| \[\[$mineral\]\]\n| [join $s8nr]\n| [dict get [lreverse $dk] $mineral]"}] {if ![empty s8nr] {lappend errorlist "| \[\[$mineral\]\]\n| [join $s8nr]\n| \{\{?\}\}"}}}
}

set errorpage "\{| class=\"wikitable sortable\"\n! Mineral !! Strunz-9-Klasse in Infobox !! Angabe in Deiner Systematik\n|-\n[join $errorlist "\n|-\n"]\n|\}"

puts [edit {user:Ra'ike/Kaputte Mineralklassen/Strunz 9} {} "Hallo Ra'ike! Schau doch mal kurz quer über diese Liste, hier sind (bis auf ein paar Ausnahmen vielleicht) Abweichungen zwischen Infobox und Strunz-9-Systematik. Wenn so weit alles in Ordnung ist, kann ich den Bot mal über die Mineralien ohne Fragezeichen drüberlaufen lassen. Wenn Du welche per Hand korrigierst, schmeiß die Zeilen einfach raus. Liebe Grüße, ${~}\n\n$errorpage"]



exit

set s9id 3225534
set llines9 [regexp -all -line -inline -- {\*.*?(\d.*?):.*?$} [conts id $s9id x]]
foreach {lines9 nr} $llines9 {
	set lmineral [dict values [regexp -all -inline -- {\[\[(.*?)[|\]]} $lines9]]
	foreach mineral $lmineral {
		lappend dk $nr $mineral
	}
}

unset -nocomplain lmineral
mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_id in ([dcat sqlid Mineral 0]) and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Infobox_Mineral'
	order by page_title
;" pt {
	lappend lmineral [sql -> $pt]
}

foreach mineral $lmineral {
	if {[string first "[set s9nr [string trim [dict values [regexp -line -inline -- {\| Kurzform_Strunz_9.*?\=.*?(\d.*?$)} [regsub -all -- {<ref.*?>} [conts t $mineral x] {}]]]]] $mineral" [string map [list \{ {} \} {}] $dk]] == -1} {if [catch {lappend errorlist "| \[\[$mineral\]\]\n| [join $s9nr]\n| [dict get [lreverse $dk] $mineral]"}] {if ![empty s9nr] {lappend errorlist "| \[\[$mineral\]\]\n| [join $s9nr]\n| \{\{?\}\}"}}}
}

set errorpage "\{| class=\"wikitable sortable\"\n! Mineral !! Strunz-9-Klasse in Infobox !! Angabe in Deiner Systematik\n|-\n[join $errorlist "\n|-\n"]\n|\}"

puts [edit {user:Ra'ike/Kaputte Mineralklassen/Strunz 9} {} "Hallo Ra'ike! Schau doch mal kurz quer über diese Liste, hier sind (bis auf ein paar Ausnahmen vielleicht) Abweichungen zwischen Infobox und Strunz-9-Systematik. Wenn so weit alles in Ordnung ist, kann ich den Bot mal über die Mineralien ohne Fragezeichen drüberlaufen lassen. Wenn Du welche per Hand korrigierst, schmeiß die Zeilen einfach raus. Liebe Grüße, ${~}\n\n$errorpage"]


exit

set test2conts [conts t {user talk:Doc Taxon} 4]
set ltest2mineral [join [dict values [regexp -all -line -inline -- {Mineral:'''.*?\|(.*?)\]\].*?Bubenik} $test2conts]]]
puts $ltest2mineral

set lang de ; source langwiki.tcl ; #set token [login $wiki]

set raikeconts [conts t {user:Ra'ike/Kaputte Mineralklassen/Dana} x]
puts $raikeconts

foreach test2mineral $ltest2mineral {
	regsub -- [format {\|-\n\| \[\[%s\]\]\n\|.*?\n\|.*?\n} $test2mineral] $raikeconts {} raikeconts
}
puts $raikeconts

puts [edit {user:Ra'ike/Kaputte Mineralklassen/Dana} {Bot: von Bubenik korrigierte Milarit-Gruppe entfernt} "$raikeconts\n:: \{\{ping|Bubenik|Ra'ike\}\} Hallo, entsprechende Minerale habe ich dann mal aus der Liste entfernt. Vielen Dank und frohe \[\[Datei:Ostereier icon.jpg|20px\]\] ${~}"]

exit

}
set maindana {Systematik der Minerale nach Dana}
set lsubdana {Elemente Sulfide {Oxide und Hydroxide} Halogenide {Carbonate, Nitrate, Borate} {Sulfate, Chromate, Molybdate} {Phosphate, Arsenate, Vanadate} {Organische Minerale} Silikate}

foreach subdana $lsubdana {
	set lk [regexp -all -line -inline -- {\|.*?(\d\d[abcd]?.\d\d[abcd]?.\d\d[abcd]?.\d\d[abcd]?).*?\n(.*?)\n} [conts t $maindana/$subdana x]]
	foreach {-- nr mineral} $lk {
		set mineral [join [dict values [regexp -inline -- {\[\[(.*?)[|\]]} $mineral]]]
		lappend dk $nr $mineral
		lappend lmineral $mineral
	}
}

puts $dk
puts $lmineral

mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_id in ([dcat sqlid Mineral 0]) and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Infobox_Mineral'
	order by page_title
;" pt {
	lappend tmineral [sql -> $pt]
}

foreach {nr mineral} $dk {
	if {$mineral in $tmineral} {
		incr i
		regexp -- {\{\{Infobox Mineral.*?\n\}\}} [conts t $mineral x] templ
		set tnr [lindex [split [join [split [
			dict get [parse_templ $templ] Kurzform_Dana
		] <]]] 0]
		if {$tnr ne $nr} {
			puts $i:$mineral:
			if [empty tnr] {set tnr {< fehlt >}}
			puts $tnr:$nr
			lappend lres "\n\|-\n\| \[\[$mineral\]\] || $tnr || $nr"
		}
	}
}

set tab "\{| class=\"wikitable sortable\"\n! Mineral !! Dana-Klasse in Infobox !! Angabe in Deiner Systematik[join $lres]\n|\}"

puts $tab

puts [edit {user:Ra'ike/Kaputte Mineralklassen/Dana} {Bot: Tabelle aktualisiert} $tab]

exit




foreach mineral $lmineral {
	if {[string first "[set dananr [string trim [dict values [regexp -line -inline -- {\| Kurzform_Dana.*?\=.*?(\d.*?$)} [regsub -all -- {<ref.*?>} [conts t $mineral x] {}]]]]] $mineral" [string map [list \{ {} \} {}] $dk]] == -1} {if [catch {lappend errorlist "| \[\[$mineral\]\]\n| [join $dananr]\n| [dict get [lreverse $dk] $mineral]"}] {if ![empty dananr] {lappend errorlist "| \[\[$mineral\]\]\n| [join $dananr]\n| \{\{?\}\}"}}}
}
set errorpage "\{| class=\"wikitable sortable\"\n! Mineral !! Dana-Klasse in Infobox !! Angabe in Deiner Systematik\n|-\n[join $errorlist "\n|-\n"]\n|\}"

puts [edit {user:Ra'ike/Kaputte Mineralklassen/Dana} {} "Hallo Ra'ike! Schau doch mal kurz quer über diese Liste, hier sind (bis auf ein paar Ausnahmen vielleicht) Abweichungen zwischen Infobox und Dana-Systematik. Wenn so weit alles in Ordnung ist, kann ich den Bot mal über die Mineralien ohne Fragezeichen drüberlaufen lassen. Wenn Du welche per Hand korrigierst, schmeiß die Zeilen einfach raus. Frohe \[\[Datei:Ostereier_icon.jpg|20px\]\]grüße, ${~}\n\n$errorpage"]
