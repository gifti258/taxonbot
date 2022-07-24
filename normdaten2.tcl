#!/usr/bin/tclsh8.7
#exit

set editafter 1

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

proc resttnd keys {
	global lnd
	set resttnd {}
	if {$keys eq {rest}} {
		if {{GND} ni [dict keys $lnd]} {
			append resttnd |GND=
		}
		foreach {key val} $lnd {
			if {$key ni {TEMPLATE TYP GNDfehlt GNDCheck REMARK 1 2 3 4 5}} {
				append resttnd |$key=$val
			}
		}
	} elseif {$keys eq {remark}} {
		if {{REMARK} in [dict keys $lnd] && [dict get $lnd REMARK] ne {}} {
			set resttnd "|REMARK=[dict get $lnd REMARK]"
		}
	}
	return $resttnd
}

dict with argv {lassign [list $pgid $revid] pgid revid]}
regexp -nocase -line -- {\{\{ ?Normdaten.*\}\}} [set oconts [conts id $pgid x]] otnd
set lnd [parse_templ $otnd]
if {[string first [list \{\{] $lnd] > -1} {puts [page_title $pgid]:Vorlagenfehler ; exit}
dict with lnd {
	if {[exists TYP] && $TYP eq {p}} {
		if {[string first {{{Normdaten|TYP=p}}} $oconts] > -1} {
			after 1800000
			puts -nonewline [set pt [page_title $pgid]]
			if {![inuse $pt] && [dict get [join [page [post $wiki {*}$query / prop revisions / pageids $pgid] revisions]] revid] == $revid} {
				set oconts [conts id $pgid x]
				set nconts [string map [list \n\{\{Normdaten|TYP=p\}\}\n {}] $oconts]
				if {$nconts ne $oconts} {
					set comment {Bot: Einbindung einer leeren Normdatenvorlage laut [[Hilfe:Normdaten]] nicht erwünscht}
					puts [edid $pgid $comment $nconts / minor]
				}
			}
		} elseif {![exists GND] || [empty GND]} {
			if {![exists GNDCheck] || [empty GNDCheck]} {
				after 1800000
				puts -nonewline [set pt [page_title $pgid]]
				if {![inuse $pt] && [dict get [join [page [post $wiki {*}$query / prop revisions / pageids $pgid] revisions]] revid] == $revid} {
#					if {![exists GNDCheck] || ([exists GNDCheck] && [empty GNDCheck])} {
#						puts " (1):"
#						set GNDCheck [utc -> seconds {} %Y-%m-%d {}]
#					} elseif {![empty GNDCheck]} {
#						puts " (2):"
#					}
					puts " (1):"
#					set GNDCheck [utc -> seconds {} %Y-%m-%d {}]
					set GNDCheck 2001-01-14
					set ntnd \{\{$TEMPLATE|TYP=$TYP[resttnd rest]|GNDfehlt=ja|GNDCheck=$GNDCheck[resttnd remark]\}\}
					set comment {Bot: Normdatenvorlage nach [[Vorlage:Normdaten]] korrigiert. Was es mit dem Überprüfungsdatum auf sich hat, kannst Du [[:Kategorie:Wikipedia:GND fehlt 2001-01|hier im Seitenintro]] nachlesen.}
					if {[set nconts [string map [list $otnd $ntnd] $oconts]] ne $oconts} {
						puts [set edit [edid $pgid $comment $nconts / minor]]
if 0 {
						set ocontsiwg [conts id 10425032 x]
						if [exists GNDName] {
							if {![empty GNDName]} {
								set GNDName " \[https://d-nb.info/gnd/$GNDName $GNDName\] "
							}
						} else {
							set GNDName { }
						}
						if [exists LCCN] {
							if {![empty LCCN]} {
								set parse_LCCN [get [post $wiki {*}$format / action expandtemplates / text "\{\{LCCN|$LCCN\}\}" / prop wikitext] expandtemplates wikitext]
								set LCCN [string tolower [dict values [regexp -inline -- {\.gov/(.*?) } $parse_LCCN]]]
								set LCCN " \[https://lccn.loc.gov/$LCCN $LCCN\] "
							}
						} else {
							set LCCN { }
						}
						if [exists NDL] {
							if {![empty NDL]} {
								set NDL " \[https://id.ndl.go.jp/auth/ndlna/$NDL $NDL\] "
							}
						} else {
							set NDL { }
						}
						if [exists VIAF] {
							if {![empty VIAF]} {
								set VIAF " \[https://viaf.org/viaf/$VIAF/ $VIAF\] "
							}
						} else {
							set VIAF { }
						}
						if ![catch {set pp [get [post $wiki {*}$format / action query / pageids $pgid / prop pageprops] query pages $pgid pageprops wikibase_item]}] {
							set q " \[\[:d:$pp|$pp\]\] "
						} else {
							set q { }
						}
						set triwg "\n|-\n| $GNDCheck || \[\[$pt\]\] ||$GNDName||$LCCN||$NDL||$VIAF||$q\n|\}"
						set iwgcomment "Bot: + \[\[$pt\]\]"
						if {[set ncontsiwg [string map [list \n\|\} $triwg] $ocontsiwg]] ne $ocontsiwg} {
							puts [edid 10425032 $iwgcomment $ncontsiwg]
						}
}
					}
				} else {
					puts " (3):"
				}
			}
		}
	}
}
