#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set vsgpage		{Wikipedia Diskussion:Hauptseite/Schon gewusst}
set hssgpage	{Wikipedia:Hauptseite/Schon gewusst}

proc get_nlvsg {} {
	global wiki parse vsgpage
	set lvsg [get [post $wiki {*}$parse / page $vsgpage / prop sections] parse sections]
	foreach vsg $lvsg {
		dict with vsg {
			if {{Hauptseitenvorschläge} in $line} {
				set top $number
				foreach vsg $lvsg {
					dict with vsg {
						if {[string first $top. $number] > -1} {
							set contsvsg [conts t $vsgpage $index]
							set fullline [regexp -line -inline -- {^==.*} $contsvsg]
							set lsgpage [dict values [regexp -all -inline -- {\[\[(.*?)[|\]#]} $fullline]]
							set vsgdate [join [string map {Mai Mai.} [regexp -inline -- {\d\d\:\d\d\, \d{1,2}\. \w{3,4}\.? \d{4}} $contsvsg]]]
							foreach sgpage $lsgpage {
								lappend nlvsg [list sgpage $sgpage vsgdate $vsgdate anchor [string map {_ { }} $anchor]]
							}
						}
					}
				}
			}
		}
	}
	return $nlvsg
}

if {$argv eq {obsolet}} {
	puts ...obsolet...
	set lpage [scat Wikipedia:Hauptseite/Schon-gewusst-Artikel 1]
	set sgconts [conts t $vsgpage x]
	foreach page $lpage {
		unset -nocomplain templ
		set sgdiskconts [conts t Diskussion:$page x]
		regexp -line -- {\{\{Schon gewusst.*?\}\}} $sgdiskconts templ
		if {[llength [split $templ |]] <= 4} {
			if {[string first "\[\[$page\]\]" $sgconts] == -1 && [string first "\[\[$page|" $sgconts] == -1} {
				set nsgdiskconts [string map [list $templ\n\n {} $templ\n {} "$templ \n" {} $templ {}] $sgdiskconts]
				if ![exists token] {set token [login $wiki]}
puts obsolet:$page
#				puts obsolet:\n[edit Diskussion:$page "Bot: Löschung des obsoleten SG?-Vorschlagbausteins" $nsgdiskconts / minor]\n
			}
		}
	}
}

if {$argv eq {Vorschlag}} {
	puts ...Vorschlag...
	foreach vsg [get_nlvsg] {
		dict with vsg {
			if {![matchtemplate Diskussion:$sgpage {Vorlage:Schon gewusst}] && [string first (erl $anchor] == -1} {
				if [catch {
					set templsg "\{\{Schon gewusst|[utc ^ $vsgdate {%H:%M, %e. %b. %Y} %Y|%m {}]|$anchor\}\}"
				}] {puts "... Signaturfehler in Vorschlag $sgpage ..." ; continue}
				set summary {Bot: Vorschlag für [[WP:SG?|Schon gewusst?]]}
				if ![exists token] {set token [login $wiki]}
				if [missing Diskussion:$sgpage] {
					puts Vorschlag:\n[edit Diskussion:$sgpage $summary $templsg / minor]\n
				} else {
					puts Vorschlag:\n[edit Diskussion:$sgpage $summary {} / prependtext $templsg\n / minor]\n
				}
			}
		}
	}
}

if {$argv eq {aufHS}} {
	puts ...auf_HS...
	set sgdayconts [conts t $hssgpage/[utc -> seconds {} %A {}] x]
	set sgday [string map {{| } |} [utc -> seconds {} %m|%Y|%e {}]]
	set sgsummday [string map {Mai. Mai} [utc -> seconds {} {%e. %b. %Y} {}]]
	set lsgdaypage [dict values [regexp -all -inline -line -- {^\*.*?\[\[(.*?)[|\]]} $sgdayconts]]
	foreach vsg [get_nlvsg] {
		dict with vsg {
			unset -nocomplain osgtempl
			if {$sgpage in $lsgdaypage} {
				set sgdiskconts [conts t Diskussion:$sgpage x]
				regexp -line -- {\{\{Schon gewusst.*?\}\}} $sgdiskconts osgtempl
				if {[llength [split $osgtempl |]] <= 4} {
					set nsgtempl "\{\{Schon gewusst|[utc ^ $vsgdate {%H:%M, %e. %b. %Y} %Y|%m {}]|$anchor|$sgday\}\}"
					set summary "Bot: Präsentation dieses Artikels am $sgsummday auf der \[\[WP:HS|Hauptseite\]\] unter \[\[WP:SG?|Schon gewusst?\]\]"
					if ![exists token] {set token [login $wiki]}
					puts auf_HS:\n[edit Diskussion:$sgpage $summary [string map [list $osgtempl $nsgtempl] $sgdiskconts] / minor]\n
				}
			}
		}
	}
}
