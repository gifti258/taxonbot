#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set lt [dcat list {Liste (Kulturdenkmale in Sachsen)} 0]
foreach t $lt {
#if {$t ne {Liste der Kulturdenkmale in Panschwitz-Kuckau}} {continue}
	puts $t
	set lrex [regexp -all -inline -- {\{\{Denkmalliste Sachsen Tabellenzeile.*?\n\}\}} [
		conts t $t x
	]]
	lassign {} NameID NSID DatierungID BeschreibungID
	foreach rex $lrex {
		lassign {} prex Name NS EW Datierung Beschreibung ID
		set prex [parse_templ $rex]
#puts $prex
		dict with prex {
			foreach p {Name NS EW Datierung Beschreibung} {
				if {[set $p] eq {}} {
					if {$p eq {EW}} {
						lappend NSID $ID
					} else {
						lappend $p\ID $ID
					}
				}
			}
		}
	}
	lappend ll [list Liste \[\[$t\]\] Name [lsort -unique $NameID] NS [lsort -unique $NSID] Datierung [lsort -unique $DatierungID] Beschreibung [lsort -unique $BeschreibungID]]
}
set th "\{| class=\"wikitable\" style=\"width: 100%;\""
set tr1 "\n|-\n| style=\"width: 20%;\" | "
set tr2 " || style=\"font-size: smaller; width: 80%;\" | "
set tf "\n|\}"
lassign {} lName lNS lDatierung lBeschreibung
foreach l $ll {
	unset -nocomplain Liste Name NS Datierung Beschreibung
	dict with l {
		foreach tab {Name NS Datierung Beschreibung} {
			if ![empty $tab] {
				lappend l$tab $tr1$Liste$tr2[set $tab]
			}
		}
	}
}
set conts "== Name ==\n\n$th[join $lName]$tf\n\n== NS/EW ==\n\n$th[join $lNS]$tf\n\n== Datierung ==\n\n$th[join $lDatierung]$tf\n\n== Beschreibung ==\n\n$th[join $lBeschreibung]$tf"
puts [edit {Benutzer:Z thomas/Kulturdenkmallisten Sachsen} {Bot: Aktualisierung} $conts / minor]
