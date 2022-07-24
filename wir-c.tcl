#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang meta ; source langwiki.tcl ; #set token [login $wiki]
package require http ; package require tls ; package require tdom

meta_lang
set p		[lindex $argv 0]
set kat	[lindex $argv 1]
set page	[lindex $argv 2]
set lq	[lindex $argv 3]
set lexc	[lindex $argv 4]

set lang de ; source langwiki.tcl ; #set token [login $wiki]

if ![empty lexc] {
	foreach exc $lexc {
		while 1 {
			if ![catch {
				lappend lexcconts [conts id $exc x]
			}] {break}
		}
	}
}
if [exists lexcconts] {
	set lexc [dict values [regexp -all -inline {:d:(Q\d{1,})} [join $lexcconts]]]
	puts "$page: Ausnahmen ausgelesen"
}

lassign {{} 0 {}} lkey i tbody
set xml [d_query_wir $p $lq]
lassign {} ditem
set offset -1
foreach line $xml {
	set row [join [lindex $line 2]]
	unset -nocomplain drow
	lassign {} sitelinks itemLabel itemDescription item
	foreach {-- key val} $row {
		lappend drow [dict values $key] [join $val]
	}
	dict with drow {
		set item [lindex [split [lindex [join [lindex $item 2]] 1] /] end]
		if {$item in $lexc} {continue}
		set sitelinks [lindex [join [lindex $sitelinks 2]] 1]
#puts $sitelinks:$item
		if {[llength $ditem] >= 4999} {set offset $sitelinks ; break}
#set offset 8 ; if {$sitelinks == $offset} {break}
		set itemLabel [lindex [join [lindex $itemLabel 2]] 1]
		if {[string first : $itemLabel] > -1 && [string first J:son $itemLabel] == -1 && [string first K:son $itemLabel] == -1} {
			puts "itemError: $item:$itemLabel"
			set lang test ; source langwiki.tcl ; #set token [login $wiki]
			puts [edid 63277 "WiR: itemError in \[\[:d:$item\]\]" {} / appendtext "\n* <span style=\"color:red\">'''[utc <- seconds {} %Y-%m-%dT%TZ {}] WiR: itemError in \[\[:d:$item\]\]\!'''</span>"]
			set lang de ; source langwiki.tcl ; #set token [login $wiki]
			continue
		}
		while 1 {if ![catch {
			if [missing $itemLabel] {
				set itemLabel \[\[$itemLabel\]\]
			} else {
				set itemLabel "<span style=\"color:#c20;\">$itemLabel</span><br /><small>(Dieses Lemma gibt es schon<br />für \[\[$itemLabel\]\].)</small>"
			}
		}] {break}}
#		set itemLabel \[\[[lindex [join [lindex $itemLabel 2]] 1]\]\]
		set itemDescription [string map [
			list {, } {,<br />} { and } {,<br />} { und } {,<br />}
		] [lindex [join [lindex $itemDescription 2]] 1]]
		if ![dict exists $ditem $item] {
			dict lappend ditem $item $sitelinks $itemLabel $itemDescription
		}
	}
}
foreach key [dict keys $ditem] {
	if {[incr ikey] == 250} {
		lappend llkey $lkey
		set lkey {}
		unset ikey
	}
	lappend lkey wd:$key
}
lappend llkey $lkey
puts "$page: [llength $llkey] Datenpakete"
set lldata [d_query_wir_data $llkey]

lassign {} dP106 dP18 dP373 dP27Label dP19Label dP20Label dP569 dP570
foreach ldata $lldata {
	puts "$page: Verarbeite Datenpaket [incr l]"
	foreach {-- -- line} $ldata {
		unset -nocomplain drow
		lassign {} item P106 P18 P373 P27Label P569 P570 P19Label P20Label
		set drow [list item [lindex [split [lindex $line 2 0 2 0 2 0 1] /] end]]
		foreach val [lrange [lindex $line 2] 1 end] {
			lappend drow [lindex $val 1 1] [lindex $val 2 0 2 0 1]
		}
		dict with drow {
#			set item [lindex [split [lindex [join [lindex $item 2]] 1] /] end]
#set item [lindex [split [lindex $item 2 0 1] /] end]
#puts $item
			if ![empty P106] {
#				set P106 [lindex [join [lindex $P106 2]] 1]
#				if {[string first porno $P106] > -1 || [string first Porno $P106] > -1} {
#					continue
#				}
				if [dict exists $dP106 $item] {
#					set P106 $P106
					if {$P106 ni [dict get $dP106 $item]} {
						dict lappend dP106 $item $P106
					}
				} else {
					dict lappend dP106 $item $P106
				}
			}
			if {![empty P18] && ![dict exists $dP18 $item]} {
				set P18 "\[\[Datei:[lindex [split [urldecode $P18] /] end]|center|120px\]\]"
				dict lappend dP18 $item $P18
			}
			if ![empty P373] {
#				set P373 [lindex [join [lindex $P373 2]] 1]
				set P373 "\[\[Datei:Commons-logo.svg|x16px\]\] '''\[\[:c:Category:$P373|Kategorie\]\]'''"
				if [dict exists $dP373 $item] {
					if {$P373 ni [dict get $dP373 $item]} {
						dict lappend dP373 $item $P373
					}
				} else {
					dict lappend dP373 $item $P373
				}
			}
			if ![empty P27Label] {
#				set P27Label [lindex [join [lindex $P27Label 2]] 1]
				while 1 {
					if ![catch {
						if ![missing Vorlage:$P27Label] {
							set P27Label \{\{$P27Label\}\}
						} else {
							set P27Label \[\[$P27Label\]\]
						}
					}] {break}
				}
				if [dict exists $dP27Label $item] {
					if {$P27Label ni [dict get $dP27Label $item]} {
						dict lappend dP27Label $item $P27Label
					}
				} else {
					dict lappend dP27Label $item $P27Label
				}
			}
			if {![empty P19Label] && [lindex $P19Label 1] ne {}} {
				set P19Label \[\[$P19Label\]\]
				if [dict exists $dP19Label $item] {
					if {$P19Label ni [dict get $dP19Label $item]} {
						dict lappend dP19Label $item $P19Label
					}
				} else {
					dict lappend dP19Label $item $P19Label
				}
			}
			if {![empty P20Label] && [lindex $P20Label 1] ne {}} {
				set P20Label \[\[$P20Label\]\]
				if [dict exists $dP20Label $item] {
					if {$P20Label ni [dict get $dP20Label $item]} {
						dict lappend dP20Label $item $P20Label
					}
				} else {
					dict lappend dP20Label $item $P20Label
				}
			}
		}
	}
}

set dP569 [d_query_wir_date $llkey P569]
set dP570 [d_query_wir_date $llkey P570]

foreach {item val} $ditem {
	set sitelinks [lindex $val 0]
	if {$sitelinks == $offset} {break}
	append tbody "\n|-\n| style=\"text-align: right;\" | [incr i]"
	append tbody "\n| style=\"text-align: right;\" | $sitelinks"
	append tbody "\n| [lindex $val 1]"
	if [dict exists $dP106 $item] {
		set vP106 [lsort -unique [dict get $dP106 $item]]
		if {[lindex $val 2] ne {}} {
			append tbody "\n| [lindex $val 2]\n----\n[join $vP106 {,<br />}]"
		} else {
			append tbody "\n| [join $vP106 {,<br />}]"
		}
	} else {
		append tbody "\n| [lindex $val 2]"
	}
	append tbody "\n| align=\"center\" |"
	if [dict exists $dP18 $item] {
		append tbody " [join [dict get $dP18 $item]]"
	}
	if [dict exists $dP373 $item] {
		set vP373 [lsort -unique [dict get $dP373 $item]]
		append tbody "\n[join $vP373 {<br />}]"
	}
	if [dict exists $dP27Label $item] {
		set vP27 [lsort -unique [dict get $dP27Label $item]]
		append tbody "\n| [join $vP27 {,<br />}]"
	} else {
		append tbody "\n|"
	}
	if [dict exists $dP569 $item] {
		set vP569 [lsort -unique [dict get $dP569 $item]]
		append tbody "\n| [join $vP569 {,<br />}]"
	} else {
		append tbody "\n|"
	}
	if [dict exists $dP19Label $item] {
		set vP19 [lsort -unique [dict get $dP19Label $item]]
		append tbody "\n| [join $vP19 {,<br />}]"
	} else {
		append tbody "\n|"
	}
	if [dict exists $dP570 $item] {
		set vP570 [lsort -unique [dict get $dP570 $item]]
		append tbody "\n| [join $vP570 {,<br />}]"
	} else {
		append tbody "\n|"
	}
	if [dict exists $dP20Label $item] {
		set vP20 [lsort -unique [dict get $dP20Label $item]]
		append tbody "\n| [join $vP20 {,<br />}]"
	} else {
		append tbody "\n|"
	}
	append tbody "\n| \[\[:d:$item|$item\]\]"
}

if {$i != [llength $xml]} {
	set ncount "[tdot $i] von [tdot [llength $xml]]"
} else {
	set ncount [tdot $i]
}

set th "\{\{../../Listenhinweis\}\}\n\{| class=\"wikitable sortable zebra\" style=\"width:100%; margin:0; line-height:140%; font-size:95%;\"\n\|- class=\"hintergrundfarbe8\"\n! colspan=\"11\" style=\"line-height:180%; font-size:110%;\" | $page <onlyinclude><small>($ncount)</small></onlyinclude>\n|- class=\"hintergrundfarbe8\"\n! # !! Wikis !! Name !! Beschreibung / Tätigkeit !! Bild !! Nationalität !! Geburtsdatum !! Geburtsort !! Sterbedatum !! Sterbeort !! Wikidata-Objekt"

#if {$i >= 1000} {
#	set ncount \{\{0|\}\}[tdot $i]
#} elseif {$i >= 100} {
#	set ncount \{\{0|.0\}\}$i
#} elseif {$i >= 10} {
#   set ncount \{\{0|.00\}\}$i
#} else {
#   set ncount \{\{0|.000\}\}$i
#}
#set mc [llength $xml]
#if {$mc >= 10000} {
#	append ncount " / \{\{0|\}\}[tdot $mc]"
#} elseif {$mc >= 1000} {
#	append ncount " / \{\{0|0\}\}[tdot $mc]"
#} elseif {$mc >= 100} {
#	append ncount " / \{\{0|.00\}\}$mc"
#} elseif {$mc >= 10} {
#  append ncount " / \{\{0|.000\}\}$mc"
#} else {
#   append ncount " / \{\{0|.0000\}\}$mc"
#}
#puts $i:[llength $xml]
#exit

set tf "|- class=\"hintergrundfarbe8\"\n! # !! Wikis !! Name !! Beschreibung / Tätigkeit !! Bild !! Nationalität !! Geburtsdatum !! Geburtsort !! Sterbedatum !! Sterbeort !! Wikidata-Objekt\n|- class=\"hintergrundfarbe8\"\n! colspan=\"11\" style=\"line-height:180%; font-size:110%;\" | $page <small>($ncount)</small>\n|\}"

set lang de ; source langwiki.tcl ; #set token [login $wiki]
puts $page:\n[edit "Wikipedia:WikiProjekt Frauen/Frauen in Rot/Fehlende Artikel nach $kat/$page" {Bot: Update Wikidata-Liste} $th\n[string trim $tbody]\n$tf / minor]

exit
