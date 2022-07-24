#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

package require http
package require tls
package require tdom

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

if {[utc -> seconds {} %H {}] ni {02 06 10 14 18 22} && $argv ne {test}} {exit}
if {[utc -> seconds {} %H {}] eq {22}} {exec ./tennis0.tcl >> tennis0.out 2>@1}

#exec ./tennis0.tcl

set dbmplayer [read [set f [open tennism0.db r]]] ; close $f
set dbfplayer [read [set f [open tennisf0.db r]]] ; close $f

proc d_player {p val} {
	set d_name {}
	set lbinding [lindex [[[dom parse -html [
		encoding convertfrom [
			getHTML https://query.wikidata.org/sparql?query=[curl::escape [format {
				select ?de_label ?de_article ?en_label ?en_article
				where {
					?item wdt:%s ?value . filter(?value = "%s")
					optional {?item rdfs:label ?de_label . filter(lang(?de_label) = "de")}
					optional {?de_article ^schema:name ?sitelink_de . ?sitelink_de schema:about ?item ; schema:isPartOf <https://de.wikipedia.org/> .}
					optional {?item rdfs:label ?en_label . filter(lang(?en_label) = "en")}
					optional {?en_article ^schema:name ?sitelink_en . ?sitelink_en schema:about ?item ; schema:isPartOf <https://en.wikipedia.org/> .}
				}
			} $p $val]]
		]
	]] documentElement] asList] 2 1 2 0 2]
	foreach binding [lreverse $lbinding] {
		lappend d_name [lindex $binding 1 1] [lindex $binding 2 0 2 0 1]
	}
	return $d_name
}

proc player {var tvar} {
	global $var $tvar
	switch [subst $$var] {
		{Gozal Ainitdinova}									{set $var	[set $tvar	{Gozal Ainitdinowa}]}
		{Carolina M. Rodrigues Alves}						{set $var	[set $tvar	{Carolina M. Alves}]}
		{Kevin Anderson}										{set $var	{Kevin Anderson (Tennisspieler)}}
		{Bianca Vanessa Andreescu}							{set $var	[set $tvar	{Bianca Andreescu}]}
		{Lara Arruabarrena Vecino}							{set $tvar	{Lara Arruabarrena}}
		{Dustin Brown}											{set $var	{Dustin Brown (Tennisspieler)}}
		{Karen Abgarowitsch Chatschanow}					{set $tvar	{Karen Chatschanow}}
		{Daniel Cox}											{set $var	{Daniel Cox (Tennisspieler)}}
		{Marat Deviatiarov}									{set $var	[set $tvar	{Marat Dewjatjarow}]}
		{Martin Dimitrow}										{set $var	{Martin Dimitrow (Tennisspieler)}}
		{Wesna Ratkowna Dolonz}								{set $tvar	{Wesna Dolonz}}
		{Jewgeni Jewgenjewitsch Donskoi}					{set $tvar	{Jewgeni Donskoi}}
		{Julieta Lara Estable}								{set $var	[set $tvar	{Julieta Estable}]}
		{Martin Fischer}										{set $var	{Martin Fischer (Tennisspieler)}}
		{Bjorn Fratangelo}									{set $var	[set $tvar	{Björn Fratangelo}]}
		{Magdalena Frech}										{set $var	[set $tvar	{Magdalena Fręch}]}
		{Teimuras Beisikowitsch Gabaschwili}			{set $tvar	{Teimuras Gabaschwili}}
		{Daniel Elahi Galan}									{set $var	[set $tvar	{Daniel Elahi Galán}]}
		{Margarita Melikowna Gasparjan}					{set $tvar	{Margarita Gasparjan}}
		{Darja Alexejewna Gawrilowa}						{set $tvar	{Darja Gawrilowa}}
		{Alejandro Gómez}										{set $var	{Alejandro Gómez (Tennisspieler)}}
		{Juan Sebastian Gomez}								{set $var	[set $tvar	{Juan Sebastián Gómez}]}
		{Alejandro González}									{set $var	{Alejandro González (Tennisspieler)}}
		{Arthur De Greef}										{set $var	{Arthur De Greef (Tennisspieler)}}
		{Alexandra Grinchishina}							{set $var	[set $tvar	{Alexandra Grintschischina}]}
		{Anna-Lena Groenefeld}								{set $var	[set $tvar	{Anna-Lena Grönefeld}]}
		{Yasmin Gulman}										{set $var	[set $tvar	{Yasmin Gülman}]}
		{Barbara Haas}											{set $var	{Barbara Haas (Tennisspielerin)}}
		{Jang Su Jeong}										{set $var	[set $tvar	{Jang Su-jeong}]}
		{Miki Jankovic}										{set $var	[set $tvar	{Miki Janković}]}
		{Justyna Jegiolka}									{set $var	[set $tvar	{Justyna Jegiołka}]}
		{Steve Johnson}										{set $var	{Steve Johnson (Tennisspieler)}}
		{Ivana Jorovic}										{set $var	[set $tvar	{Ivana Jorović}]}
		{Michail Michailowitsch Juschny}					{set $tvar	{Michail Juschny}}
		{Aslan Kasbekowitsch Karazew}						{set $tvar	{Aslan Karazew}}
		{Darja Sergejewna Kassatkina}						{set $tvar	{Darja Kassatkina}}
		{Kamila Kerimbayeva}									{set $var	[set $tvar	{Kamila Kerimbajewa}]}
		{Kim Dabin}												{set $var	[set $tvar	{Kim Da-bin}]}
		{Ekaterina Klyueva}									{set $var	[set $tvar	{Jekaterina Kljujewa}]}
		{Konstantin Wladimirowitsch Krawtschuk}		{set $tvar	{Konstantin Krawtschuk}}
		{Alexander Michailowitsch Kudrjawzew}			{set $tvar	{Alexander Kudrjawzew}}
		{Jelisaweta Dmitrijewna Kulitschkowa}			{set $tvar	{Jelisaweta Kulitschkowa}}
		{Andrei Alexandrowitsch Kusnezow}				{set $tvar	{Andrei Kusnezow}}
		{Swetlana Alexandrowna Kusnezowa}				{set $tvar	{Swetlana Kusnezowa}}
		{Vera Lapko}											{set $var	[set $tvar	{Wera Lapko}]}
		{Alexandar Lasarow}									{set $var	{Alexandar Lasarow (Tennisspieler)}}
		{Sofia Luini}											{set $var	[set $tvar	{Sofía Luini}]}
		{Vojislava Lukic}										{set $var	[set $tvar	{Vojislava Lukić}]}
		{Jekaterina Walerjewna Makarowa}					{set $tvar	{Jekaterina Makarowa}}
		{Vladyslav Manafov}									{set $var	[set $tvar	{Wladislaw Manafow}]}
		{Florian Mayer}										{set $var	{Florian Mayer (Tennisspieler)}}
		{Miloslav Mečíř}										{set $var	[set $tvar	{Miloslav Mečíř junior}]}
		{Daniil Sergejewitsch Medwedew}					{set $tvar	{Daniil Medwedew}}
		{Nikola Milojević}									{set $var	{Nikola Milojević (Tennisspieler)}}
		{Jessica Moore}										{set $var	{Jessica Moore (Tennisspielerin)}}
		{Silvia Njiric}										{set $var	[set $tvar	{Silvia Njirić}]}
		{Fanny Ostlund}										{set $var	[set $tvar	{Fanny Östlund}]}
		{Anastassija Sergejewna Pawljutschenkowa}		{set $tvar	{Anastassija Pawljutschenkowa}}
		{Matija Pecotic}										{set $var	[set $tvar	{Matija Pecotić}]}
		{José Pereira}											{set $var	{José Pereira (Tennisspieler)}}
		{Sviatlana Pirazhenka}								{set $var	[set $tvar	{Swjatlana Piraschenka}]}
		{Julija Antonowna Putinzewa}						{set $tvar	{Julija Putinzewa}}
		{Tim Van Rijthoven}									{set $var	[set $tvar	{Tim van Rijthoven}]}
		{Jewgenija Sergejewna Rodina}						{set $tvar	{Jewgenija Rodina}}
		{Anastassija Iwanowna Rodionowa}					{set $tvar	{Anastassija Rodionowa}}
		{Arina Iwanowna Rodionowa}							{set $tvar	{Arina Rodionowa}}
		{Cristian Rodríguez}									{set $var	{Cristian Rodríguez (Tennisspieler)}}
		{Victoria Rodriguez}									{set $var	[set $tvar	{Victoria Rodríguez}]}
		{Andrei Andrejewitsch Rubljow}					{set $tvar	{Andrei Rubljow}}
		{Michael Russell}										{set $var	{Michael Craig Russell}}
		{Roman Safiullin}										{set $var	{Roman Rischatowitsch Safiullin}}
		{Marija Jurjewna Scharapowa}						{set $tvar	{Marija Scharapowa}}
		{Jaroslawa Wjatscheslawowna Schwedowa}			{set $tvar	{Jaroslawa Schwedowa}}
		{Maria Shishkina}										{set $var	[set $tvar	{Maria Schischkina}]}
		{Adrian Sikora}										{set $var	{Adrian Sikora (Tennisspieler)}}
		{Artem Smirnov}										{set $var	[set $tvar	{Artem Smyrnow}]}
		{Carl Soderlund}										{set $var	[set $tvar	{Carl Söderlund}]}
		{Nina Stojanovic}										{set $var	[set $tvar	{Nina Stojanović}]}
		{Botic Van de Zandschulp}							{set $var	[set $tvar	{Botic van de Zandschulp}]}
		{James Ward}											{set $var	{James Ward (Tennisspieler)}}
		{Jelena Sergejewna Wesnina}						{set $tvar	{Jelena Wesnina}}
		{Marcela Zacarias}									{set $var	[set $tvar	{Marcela Zacarías}]}
		{Anton Zaitcev}										{set $var	[set $tvar	{Anton Zaitsev}]}
		{Miljan Zekic}											{set $var	[set $tvar	{Miljan Zekić}]}
		{Zhang Shuai}											{set $var	{Zhang Shuai (Tennisspielerin)}}
		{Zhu Lin}												{set $var	{Zhu Lin (Tennisspielerin)}}
	}
}

unset -nocomplain -- ltr mtab ftab mtop100dach ftop100dach
foreach {disc pageid} {singles 7943000 doubles 7943026} {
	set datahtml [getHTML https://www.atptour.com/en/rankings/$disc]
	set ldata [[[dom parse -html $datahtml] documentElement] asList]
	set mrankdate [string map {. -} [regexp -inline -- {\d{4}\.\d\d\.\d\d} $ldata]]
	regexp -- {tbody \{\} \{(\{tr.*?\}{6})\}\}\}} $ldata -- tbody
	set mtop10date [clock format [clock scan $mrankdate -format %Y-%m-%d] -format {%e. %B %Y} -locale de]
	set rank 0
	set ntab "| Stand      = $mrankdate\n"
#	if {$disc eq {singles}} {set mtab [set ftab "\n| style=\"vertical-align: top;\" |"]}
	foreach tr $tbody {
		incr rank
		if {[set ranknr [string trimright [string trim [lindex $tr 2 0 2 0 1]] T]] > 10} {
			if {[lindex $tr 2 2 2 0 2 0 2 0 1 3] in {AUT GER LIE SUI} && $disc eq {singles}} {
				set mplayer [lindex $tr 2 3 2 0 2 0 1]
				if [catch {set P536 [dict get $dbmplayer $mplayer]}] {
					if [catch {set P536 [dict get $dbmplayer [lrange $mplayer 0 end-1]]}] {
						set P536 [dict get $dbmplayer [lrange $mplayer 0 end-2]]
					}
				}
				unset -nocomplain de_article de_label en_article en_label
				set d_name [d_player P536 $P536]
				if [empty d_name] {set d_name [d_player P536 [string toupper $P536]]}
				if ![empty d_name] {
					dict with d_name {
						if [exists de_article] {
							if [exists de_label] {
								lassign [list $de_article $de_label] player tplayer
							} elseif {![exists de_label] && [exists en_label]} {
								lassign [list $de_article $en_label] player tplayer
							}
						} elseif [exists de_label] {
							set tplayer [set player $de_label]
						} elseif [exists en_label] {
							set tplayer [set player $en_label]
						}
					}
				} else {
					set tplayer [set player [page [post $wiki {*}$get / titles $mplayer / redirects] title]]
					player player tplayer
				}
				lappend mtop100dach "$rank.%%%nbsp;[expr {$tplayer eq $player ? "\[\[$tplayer\]\]" : "\[\[$player|$tplayer\]\]"}]"
			}
		} else {
			switch $rank {10 {set b =} default {set b { =}}}
			set mplayer [lindex $tr 2 3 2 0 2 0 1]
			if [catch {set P536 [dict get $dbmplayer $mplayer]}] {
				if [catch {set P536 [dict get $dbmplayer [lrange $mplayer 0 end-1]]}] {
					set P536 [dict get $dbmplayer [lrange $mplayer 0 end-2]]
				}
			}
			unset -nocomplain de_article de_label en_article en_label
			set d_name [d_player P536 $P536]
			if [empty d_name] {set d_name [d_player P536 [string toupper $P536]]}
			if ![empty d_name] {
				dict with d_name {
					if [exists de_article] {
						if [exists de_label] {
							lassign [list $de_article $de_label] player tplayer
						} elseif {![exists de_label] && [exists en_label]} {
							lassign [list $de_article $en_label] player tplayer
						}
					} elseif [exists de_label] {
						set tplayer [set player $de_label]
					} elseif [exists en_label] {
						set tplayer [set player $en_label]
					}
				}
			} else {
				set tplayer [set player [page [post $wiki {*}$get / titles $mplayer / redirects] title]]
				player player tplayer
			}
			regexp -line -- {^.*?Nation.*?=(.*)$} [conts t $player 0] -- rnplayer
			set nplayer [lindex [regexp -all -inline -- {\{\{(.*?)\}\}} $rnplayer] end]|$player|$tplayer
			set move [string trim [lindex $tr 2 1 2 1 2 0 1]]
			switch [lindex $tr 2 1 2 0 1 1] {
				move-none {set move 0}
				move-down {set move [expr - $move]}
			}
			append ntab "| Name$rank     $b \{\{$nplayer\}\}\n| Position$rank $b $ranknr\n| Änderung$rank $b $move\n"
			if {$disc eq {singles}} {append mtab "\n#\{\{$nplayer\}\}"}
		}
	}
	set nconts [set oconts [conts id $pageid x]]
	regsub -- {\| Stand.*?(\}\}<noincl)} $oconts $ntab\\1 nconts
	regsub -- {rankDate=\d{4}-\d{2}-\d{2}} $nconts rankDate=$mrankdate nconts
	if {$nconts ne $oconts} {
		puts [edid $pageid {Bot: Aktualisierung} $nconts]
	}
}

foreach {disc pageid} {Singles 7744893 Doubles 7744908 Doubles 7728321} {
	set portalconts [conts id 3808675 x]
	regexp -all -- {Stand: (.*?)\)} $portalconts -- ofrankdate
	set ipdf 0
	http::geturl http://wtafiles.wtatennis.com/pdf/rankings/$disc\_Numeric.pdf -channel [
		set fl [open wta-$disc.pdf wb]
	]
	close $fl
	exec pdftotext -raw wta-$disc.pdf
	set data [read [set fl [open wta-$disc.txt r]]] ; close $fl
	set data [string map {{ ,} , {PAAR, LAURA IOANA} {ANDREI, LAURA IOANA}} $data]
	set frankdate [clock format [clock scan [lindex [split $data \n] 0] -format {%e %B %Y}] -format %Y-%m-%d]
	set ftop10date [string trim [clock format [clock scan $frankdate -format %Y-%m-%d] -format {%e. %B %Y} -locale de]]
	unset -nocomplain ldata
#puts $disc
	if {$disc eq {Singles}} {
		regsub -all -- {(Please.*?RANK)\n\d} $data {} data
		regsub -- {Please.*} $data {} data
		regsub -- {(.*?Rankings\n)\d} $data {} data
		set ldata [split [string trim $data] \n]
	} else {
		set data [string range [string map [list "\n \n" \n \n\n \n] [join [dict values [regexp -all -inline -- {RANK NAME(.*?)Printed} $data]]]] 1 end-1]
		set data [split $data \n]
		foreach {nation fplayer rank} $data {
			if {[string first {(} $rank] == -1} {
				set rank "$rank ($rank)"
			}
#	puts $fplayer
#	puts [regsub -- {\d.*} $fplayer {}]
			lappend ldata -- $nation [string trim [regsub -- {\d.*} $fplayer {}]] $rank
		}
#		regsub -- {Printed.*} $data {} data
#		regsub -- {.*?\n(\w{3} \d)} $data \\1 data
#		set lbdata [split [string trim $data] \n]
#		set ldata {}
#		foreach {bdata1 bdata2} $lbdata {
#			set bdata20 [lindex $bdata2 0]
#			if {[string first {(} $bdata2] == -1} {
#				set bdata2 [string map [list $bdata20 "$bdata20 ($bdata20)"] $bdata2]
#			}
#			lappend ldata -- [lindex $bdata1 0] [lrange $bdata2 2 end] [lrange $bdata2 0 1]
#		}
	}
#puts $ldata ; exit
#puts $disc
	lassign {0 0} rank0 drank0
	set ntab "| Stand      = $frankdate\n"
	foreach {-- nation fplayer rank} $ldata {
#puts $disc:$nation:$fplayer:$rank
#puts $dbfplayer
#if {[string first {JIANG, XINYU} $dbfplayer] > -1} {puts 1} else {puts 0}
#puts $nation:$fplayer:$rank
		if {[string first ANDREI, $fplayer] > -1} {continue}
		if {$fplayer eq {WU, FANG-HSIEN}} {gets stdin ; continue}
		if {$fplayer eq {CHEN, PEI HSUAN}} {gets stdin ; continue}
		if [catch {set P597 [dict get $dbfplayer $fplayer]}] {
			if [catch {set P597 [dict get $dbfplayer [lrange $fplayer 0 end-1]]}] {
				set P597 [dict get $dbfplayer [lrange $fplayer 0 end-2]]
			}
		}
		unset -nocomplain de_article de_label en_article en_label
if {$fplayer eq {MAKAROVA, EKATERINA}} {set P597 311604}
		set d_name [d_player P597 $P597]
		incr rank0
		set ranknr [lindex $rank 0]
		if {$pageid == 7744908 && $ranknr > 10} {break}
		if {$nation ni {CHN KOR TPE}} {set cname [join [lreverse [split $fplayer ,]]]} else {set cname [join [split $fplayer ,]]}
		unset -nocomplain names
		foreach name $cname {
			lassign [list [string tolower $name 1 end] {}] name dname
			if {[string match *-* $name] && $nation ni {KOR TPE}} {
				foreach hname [split $name -] {lappend dname [string toupper $hname 0]}
				set name [join $dname -]
			}
			lappend names $name
		}
		if ![empty d_name] {
			dict with d_name {
				if [exists de_article] {
					if [exists de_label] {
						lassign [list $de_article $de_label] player tplayer
					} elseif {![exists de_label] && [exists en_label]} {
						lassign [list $de_article $en_label] player tplayer
					}
				} elseif [exists de_label] {
					set tplayer [set player $de_label]
				} elseif [exists en_label] {
					set tplayer [set player $en_label]
				}
			}
		} else {
			set tplayer [set player [page [post $wiki {*}$get / titles $names / redirects] title]]
			player player tplayer
		}
		if {$player ne $tplayer} {
			set tplayer $player|$tplayer
			set f100player $tplayer
		} else {
			set tplayer $tplayer|$tplayer
			set f100player $player
		}
		try {
			regexp -line -- {^.*?Nation.*?=(.*)$} [conts t $player 0] -- rnplayer
			set rnplayer [lindex [regexp -all -inline -- {\{\{(.*?)\}\}} $rnplayer] end]
		} on 1 {} {
			set rnplayer $nation
		}
		if [empty rnplayer] {set rnplayer $nation}
		set nplayer $rnplayer|$tplayer
		if {[llength $rank] == 2} {
			set move [expr [lindex $rank 1] - $ranknr]
		} else {
			set move 0
		}
		switch $rank0 {10 {set b =} default {set b { =}}}
		set rntab "| Name$rank0     $b \{\{$nplayer\}\}\n| Position$rank0 $b $ranknr\n| Änderung$rank0 $b $move\n"
		if {$disc eq {Singles}} {
			lappend flntab $nation $rntab
		} elseif {$pageid == 7728321 && $nation eq {GER}} {
			lappend fldntab $nation $rntab
			if {[incr drank0] == 10} {break}
		}
		if {$ranknr <= 10 && $pageid != 7728321} {
			append ntab $rntab
		}
		if {$disc eq {Singles}} {
			if {$ranknr <= 10} {append ftab "\n#\{\{$nplayer\}\}"}
			if {$ranknr >  10 && $ranknr <= 100 && $nation in {AUT GER LIE SUI}} {
				lappend ftop100dach "$ranknr.%%%nbsp;\[\[$f100player\]\]"
			}
		}
	}
	if {$pageid != 7728321} {
		set nconts [set oconts [conts id $pageid x]]
		regsub -- {\| Stand.*?(\}\}<noincl)} $oconts $ntab\\1 nconts
		if {$nconts ne $oconts} {
			puts [edid $pageid {Bot: Aktualisierung} $nconts]
		}
	}
}

set oconts [conts id 3808675 x]
set otab [regexp -all -inline -line -- {^#.*} $oconts]
lassign [list [lrange $otab 0 9] [lrange $otab 10 19]] omtab oftab
set omtab \n[join $omtab \n] ; set oftab \n[join $oftab \n]
#regsub -- {\n\| style=\"vertical-align: top;\" \|.*?(\|\})} [set oconts [conts id 3808675 x]] $mtab$ftab\n\\1 nconts
set nconts [string map [list $omtab $mtab $oftab $ftab] $oconts]
regsub -- {(Herren-Welt.*?Stand: ).*?(\).*?Damen-Welt.*?Stand: ).*?(\))} $nconts \\1[string trim $mtop10date]\\2[string trim $ftop10date]\\3 nconts
set otop100 [regexp -all -inline -- {\n(\d{2}\..*?)\n\|} $oconts]
lassign [list [lindex $otop100 1] [lindex $otop100 3]] omtop100dach oftop100dach
set nconts [string map [list $omtop100dach [join $mtop100dach ",\n"] $oftop100dach [join $ftop100dach ",\n"]] $nconts]
#regsub -- {(48%.*?\n).*?(\n\|.*?48%.*?\n).*?(\n\|)} $nconts \\1[join $mtop100dach ",\n"]\\2[join $ftop100dach ",\n"]\\3 nconts
set nconts [string map {%%% &} $nconts]
if {$nconts ne $oconts} {puts [edid 3808675 {Bot: Aktualisierung} $nconts]}

set datahtml [getHTML https://www.atptour.com/en/rankings/singles?rankRange=1-5000]
set ldata [[[dom parse -html $datahtml] documentElement] asList]
set mrankdate [string map {. -} [regexp -inline -- {\d{4}\.\d\d\.\d\d} $ldata]]
regexp -- {tbody \{\} \{(\{tr.*?\}{6})\}\}\}} $ldata -- tbody
set ntab "| Stand      = $mrankdate\n"
foreach tr $tbody {
	set nation [lindex $tr 2 2 2 0 2 0 2 0 1 3]
	set rank [string trim [lindex $tr 2 0 2 0 1]]
	set mplayer [lindex $tr 2 3 2 0 2 0 1]
	if [catch {set P536 [dict get $dbmplayer $mplayer]}] {
		if [catch {set P536 [dict get $dbmplayer [lrange $mplayer 0 end-1]]}] {
			set P536 [dict get $dbmplayer [lrange $mplayer 0 end-2]]
		}
	}
	unset -nocomplain de_article de_label en_article en_label
	set d_name [d_player P536 $P536]
	if [empty d_name] {set d_name [d_player P536 [string toupper $P536]]}
	if ![empty d_name] {
		dict with d_name {
			if [exists de_article] {
				if [exists de_label] {
					lassign [list $de_article $de_label] player tplayer
				} elseif {![exists de_label] && [exists en_label]} {
					lassign [list $de_article $en_label] player tplayer
				}
			} elseif [exists de_label] {
				set tplayer [set player $de_label]
			} elseif [exists en_label] {
				set tplayer [set player $en_label]
			}
		}
	} else {
		set tplayer [set player [page [post $wiki {*}$get / titles $mplayer / redirects] title]]
		player player tplayer
	}
	if {$player ne $tplayer} {set tplayer "$player\{\{!\}\}$tplayer"}
	set move [string trim [lindex $tr 2 1 2 1 2 0 1]]
	switch [lindex $tr 2 1 2 0 1 1] {
		move-none {set move 0}
		move-down {set move [expr - $move]}
	}
	dict lappend lmplayers $nation [list rank $rank tplayer $tplayer move $move]
}

set lnation {ARG 7138796 AUS 7138996 AUT 7139018 BEL 7139144 BRA 7138982 BUL 9487362 CAN 7158679 COL 7139212 CRO 7158441 CZE 7158400
				 ESP 7135365 FRA 7137488 GBR 7158067 GER 7135452 ITA 7138933 JPN 7158649 NED 7158710 RUS 7138965 SRB 7158371 SUI 7158106
				 SVK 7158744 SWE 7390927 UKR 7158776 USA 7138756}
foreach {nation pageid} $lnation {
	lassign [list 1 "| Stand      = $mrankdate\n" " ="] i ntab b
	foreach mplayer [dict get $lmplayers $nation] {
		dict with mplayer {
			append ntab "| Name$i     $b $tplayer\n| Position$i $b [string trimright $rank T]\n| Änderung$i $b $move\n"
			if {[incr i] == 10} {set b =}
			if {$i == 11} {break}
		}
	}
	regsub -- {\| Stand.*?(\}\}<noincl)} [contents id $pageid x] $ntab\\1 ncontent
	regsub -- {(rankDate=).*?(&.*?countryCode=).*?( ATP)} $ncontent \\1$mrankdate\\2$nation\\3 ncontent
	if {$ncontent ni [list $contents {}]} {puts [edid $pageid Aktualisierung $ncontent]\n}
}

set lnation {ARG 7126344 AUS 7126374 AUT 7126408 BEL 7126875 BLR 7133701 BRA 8497233 BUL  7968981 CAN 7899465 CHN 7130254 CRO 7134697
				 CZE 7132898 ESP 7132869 FRA 7130320 GBR 7133793 GER 7126313 HUN 8797556 IND 10047423 ITA 7130284 JPN 7134142 KAZ 7969015
				 KOR 9237753 MEX 8622202 NED 7744832 POL 7134282 ROU 7130874 RUS 7133400 SLO  9009122 SRB 7130867 SUI 7269671 SVK 7134762
				 SWE 7692952 THA 9060433 TPE 7746091 TUR 8917558 UKR 7134799 USA 7131161}
foreach {nation pageid} $lnation {
	lassign [list 1 "| Stand      = $frankdate\n" {\{\{[A-Z]{3}\|.*?\}\}}] i ntab rex
	foreach {rnation rtab} $flntab {
		if {$rnation eq $nation} {
			regexp -- {\{\{[A-Z]{3}\|(.*?)\|(.*?)\}\}} $rtab name0 name1 name2
			if {$name1 eq $name2} {
				regsub -- [format %s $rex] $rtab $name1 rtab
			} else {
				regsub -- [format %s $rex] $rtab $name1\{\{!\}\}$name2 rtab
			}
			regsub -- {Name\d{1,4}} $rtab Name$i rtab
			regsub -- {Position\d{1,4}} $rtab Position$i rtab
			regsub -- {Änderung\d{1,4}} $rtab Änderung$i rtab
			regsub -all -- {([eng]10) } $rtab \\1 rtab
			append ntab $rtab
			if {[incr i] == 11} {break}
		}
	}
	regsub -- {\| Stand.*?(\}\}<noincl)} [contents id $pageid x] $ntab\\1 ncontent
	if {$ncontent ni [list $contents {}]} {puts [edid $pageid Aktualisierung $ncontent]\n}
}

lassign {GER 7728321} nation pageid
lassign [list 1 "| Stand      = $frankdate\n" {\{\{[A-Z]{3}\|.*?\}\}}] i dntab rex
foreach {rnation rtab} $fldntab {
	if {$rnation eq $nation} {
		regexp -- {\{\{[A-Z]{3}\|(.*?)\|(.*?)\}\}} $rtab name0 name1 name2
		if {$name1 eq $name2} {
			regsub -- [format %s $rex] $rtab $name1 rtab
		} else {
			regsub -- [format %s $rex] $rtab $name1\{\{!\}\}$name2 rtab
		}
		regsub -- {Name\d{1,4}} $rtab Name$i rtab
		regsub -- {Position\d{1,4}} $rtab Position$i rtab
		regsub -- {Änderung\d{1,4}} $rtab Änderung$i rtab
		regsub -all -- {([eng]10) } $rtab \\1 rtab
		append dntab $rtab
		if {[incr i] == 11} {break}
	}
}
regsub -- {\| Stand.*?(\}\}<noincl)} [contents id $pageid x] $dntab\\1 ncontent
if {$ncontent ni [list $contents {}]} {puts [edid $pageid Aktualisierung $ncontent]\n}
