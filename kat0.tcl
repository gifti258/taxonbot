#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#package require http
#package require tls
#package require tdom

source api.tcl ; set lang commons ; source langwiki.tcl ; #set token [login $wiki]

puts [get [token-post $wiki {*}$format / action move / from user:TaxonBot/Test3 / to user:TaxonBot/Test4 / reason reason / noredirect]]
puts [get [token-post $wiki {*}$format / action move / from user:TaxonBot/Test4 / to user:TaxonBot/Test3 / reason reason / noredirect]]

exit

catch {if {[exec pgrep -cxu taxonbot kat0.tcl] > 1} {exit}}

# Hinweise:
## falls beide Kategorien Diskussionsseiten haben, source Diskussionsbaum unter den target schieben
## Verschiebebegründungen
## bei content-Übertragung {{Umbenennungstext|...}} entfernen

if {$lang eq {beta}} {set wsid 2873} else {set wsid 6988261}

puts [edid $wsid {Bot: obsolete Steuerzeichen entfernt} [string map {\u200e {} \u200f {}} [conts id $wsid x]] / minor]

proc jobinput idx {
	global wsid
	return [contents id $wsid $idx]
}

proc donecheck {contents idx} {
	global wiki parse
	if ![string match *rledigt* $contents] {
		return [lsearch -glob [get [post $wiki {*}$parse / text $contents / prop templates] parse templates] *Vorlage:Erledigt*]
	} elseif [string match *rledigt* $contents] {
		return 0
	} else {
		return -1
	}
}

proc getcat contents {
	global special scat tcat modus reason topic
	set contents [string map {\n\n \n} $contents]
	set splitcontent [split $contents \n]
	lassign [list [lindex $splitcontent 0] [lindex $splitcontent 1] {}] topic line1 reason
	if [string match *(Artikel)* $topic] {
		set special 1
	} elseif [string match *(Kategorie)* $topic] {
		set special 2
	} elseif [string match {* leeren*} $topic] {
		set special 3
	} elseif [string match {* duplizieren*} $topic] {
		set special 4
	} else {
		set special 0
	}
	if {$special == 3} {
		regexp -- {\[\[:(Kategorie:.*?)\]\]} $topic -- scat
		set modus catempty
	} else {
		set tcat [lremove lcat [set scat [lindex [set lcat [dict values [regexp -all -inline -- {\[\[:(Kategorie:.*?)\]\]} $topic]]] 0]]]
		if {$special in {0 1 2}} {
			set modus cattocat
		} elseif {$special == 4 && [llength $tcat] == 1} {
			set modus catdupl
		}
	}
	regexp -nocase -- {(\[\[.*\]\]|\[(?!\[).*\]){1,1}?} $line1 reason
	if {$reason eq {}} {regexp -line -- {^.*?\.} $line1 reason}
	set reason "laut $reason"
}

proc getitem scat {
	global special
	if {$special in {0 3 4}} {
		return [cat $scat *]
	} elseif {$special == 1} {
		return [cat $scat 0]
	} elseif {$special == 2} {
		return [cat $scat 14]
	}
}

proc deltempl {scat miss} {
	global llog
	if {$miss eq {0 1 0 1}} {return}
	regsub -- {\{\{Umbenennungstext.*?\}\}\n} [set ocontscat [contents t $scat x]] {} ncontscat
	regsub -- {<noinclude>\n\{\{Löschantragstext.*?noinclude>\n} $ncontscat {} ncontscat
	regsub -- {\{\{Löschantragstext.*?\}\}\n} $ncontscat {} ncontscat
	regsub -- {^\n} $ncontscat {} ncontscat
	regsub -all -- {\n{3,5}} $ncontscat \n\n ncontscat
	if {$ncontscat ne $ocontscat} {
		puts [katedit $scat {Bot: - Wartungsvorlagen} $ncontscat / minor]
		lappend llog "# Wartungsvorlagen und Leerzeilen auf Seite \[\[:$scat\]\] entfernt"
	}
}

proc cattocat litem {
	global llog scat tcat reason topic allcoord ~ wiki get format token
	foreach tc $tcat {
		set tc [join $tc]
		regsub {Kategorie:} $scat {Kategorie Diskussion:} stcat
		regsub {Kategorie:} $tc {Kategorie Diskussion:} ttcat
#		lassign [list "Kategorie Diskussion:[lindex [split $scat :] 1]" "Kategorie Diskussion:[lindex [split $tc :] 1]"] stcat ttcat
		set miss {}
		foreach 1 [list $scat $stcat $tc $ttcat] {
			if {[lsearch -exact [page [post $wiki {*}$get / list info / titles $1]] missing] == -1} {
				lappend miss 0
			} else {
				lappend miss 1
			}
		}
		set llog [list $topic]
#	lassign [list [list $topic] "\[\[$scat\]\] umbenannt in \[\[$tcat\]\]: $reason"] llog summary
		if [string match *true* [contents id 9498090 x]] {puts "\n*** Bot gesperrt ***\n" ; exit}
		switch $miss {
			{0 1 1 1} {
				deltempl $scat $miss
				puts [get [
					post $wiki {*}$format {*}$token / action move / from $scat / to $tc / reason $reason / noredirect
				]]
				lappend llog "# Seite \[\[:$scat\]\] nach \[\[:$tc\]\] verschoben"
			}
			{0 0 1 1} {
				deltempl $scat $miss
				puts [get [
					post $wiki {*}$format {*}$token / action move / from $scat / to $tc / reason $reason / movetalk true / noredirect
				]]
				lappend llog "# Seite \[\[:$scat\]\] nach \[\[:$tc\]\] verschoben"
				lappend llog "# Seite \[\[:$stcat\]\] nach \[\[:$ttcat\]\] verschoben"
			}
			{0 0 0 1} {
				puts [get [
					post $wiki {*}$format {*}$token / action move / from $stcat / to $ttcat / reason $reason / noredirect
				]]
				lappend llog "# Seite \[\[:$stcat\]\] nach \[\[:$ttcat\]\] verschoben"
			}
			{0 0 0 0} {
				puts [katedit $ttcat "Bot: $reason" "[contents t $ttcat x]\n\n== Diskussionen zur \[\[:$scat\]\] ==\n[contents t $stcat x]"]
				lappend llog "# Seiteinhalt der \[\[:$stcat\]\] nach \[\[:$ttcat\]\] angehängt"
			}
			 default	{
			}
		}
		catch {
			if {	  ![string match {*{{All Coordinates}}*} [contents t $tc x]]
					&& [string match {*{{All Coordinates}}*} [contents t $scat x]]} {
				puts [katedit $tc "Bot: + \{\{All Coordinates\}\}" {} / prependtext "\{\{All Coordinates\}\}\n\n" / minor]
			}
		}
	}
	foreach item $litem {
		set ncontent [set ocontent [contents t $item x]]
		foreach tc [lreverse $tcat] {
			set tc [join $tc]
			set delscat 0
			if {		[string first \[\[$tc\]\] $ncontent] != -1
					|| [string first \[\[$tc| $ncontent] != -1
					|| [string first \[\[$tc\u200e $ncontent] != -1
					|| [string first \[\[$tc\u200f $ncontent] != -1} {
				set pcontent {}
				foreach listline [split $ncontent \n] {
					if {		[string first \[\[$scat\]\] $listline] == -1
							&& [string first \[\[$scat| $listline] == -1
							&& [string first \[\[$scat\u200e $listline] == -1
							&& [string first \[\[$scat\u200f $listline] == -1} {
						lappend pcontent $listline
					}
				}
				set ncontent [join $pcontent \n]
				set summary "\[\[$scat\]\] entfernt: $reason"
				set delscat 1
			} elseif {		[string first \[\[$scat\]\] $ncontent] == -1
							&& [string first \[\[$scat| $ncontent] == -1
							&& [string first \[\[$scat\u200e $ncontent] == -1
							&& [string first \[\[$scat\u200f $ncontent] == -1} {
				set ncontent [string map [list \[\[$pcat\]\] \[\[$tc\]\]\n\[\[$pcat\]\] \[\[$pcat| \[\[$tc\]\]\n\[\[$pcat|] $ncontent]
				set v 1
			} else {
				set ncontent [string map [
					list \[\[$scat\]\] \[\[$tc\]\] \[\[$scat\u200e \[\[$tc \[\[$scat\u200f \[\[$tc \[\[$scat| \[\[$tc|
				] $ncontent]
				set v 0
			}
			set pcat $tc
			set summary "\[\[$scat\]\] umbenannt in \[\[$tc\]\]: $reason"
			if {$ncontent ne $ocontent} {
				if !$delscat {
					if ![dict get [page [post $wiki {*}$get / list info / titles $item]] ns] {
						if $v {
							lappend llog "# \[\[:$tc\]\] in den Artikel \[\[:$item\]\] hinzugefügt"
						} else {
							lappend llog "# Artikel \[\[:$item\]\] umkategorisiert"
						}
					} else {
						if $v {
							lappend llog "# \[\[:$tc\]\] in die Seite \[\[:$item\]\] hinzugefügt"
						} else {
							lappend llog "# Seite \[\[:$item\]\] umkategorisiert"
						}
					}
				} else {
					if ![dict get [page [post $wiki {*}$get / list info / titles $item]] ns] {
						lappend llog "# \[\[:$scat\]\] aus dem Artikel \[\[:$item\]\] entfernt"
					} else {
						lappend llog "# \[\[:$scat\]\] aus der Seite \[\[:$item\]\] entfernt"
					}
				}
			}
		}
		if {$ncontent ne $ocontent} {
			puts [katedit $item "Bot: $summary" $ncontent / minor]
		}
	}
	if {[lsearch -exact [page [post $wiki {*}$get / list info / titles $scat]] missing] == -1 && [catch {llength [cat $scat *]}]} {
		puts [katedit $scat "Bot: SLA: $reason" {} / prependtext "\{\{Löschen|1=SLA: $reason ${~}\}\}\n\n" / minor]
		lappend llog "# Schnelllöschantrag auf Seite \[\[:$scat\]\] gestellt"
	} else {
		puts "Item verblieben: [catch {cat $scat *}]"
	}
}

proc catempty litem {
	global llog scat reason topic ~ wiki get format token
	lassign [list [list $topic] "\[\[$scat\]\] entfernt: $reason"] llog summary
	foreach item $litem {
#puts $scat
#puts $item
		set rexscat [string map {( \\\( ) \\\)} "\n\\\[\\\[$scat.*?\\\]\\\]"]
		set ncontent [regsub -- $rexscat [set ocontent [contents t $item x]] {}]
		set rexscat [string map {( \\\( ) \\\)} "\\\[\\\[$scat.*?\\\]\\\]"]
		set ncontent [regsub -- $rexscat $ncontent {}]
		if {$ncontent ne $ocontent} {
			puts [katedit $item "Bot: $summary" $ncontent / minor]
			if ![dict get [page [post $wiki {*}$get / list info / titles $item]] ns] {
				lappend llog "# \[\[:$scat\]\] aus dem Artikel \[\[:$item\]\] entfernt"
			} else {
				lappend llog "# \[\[:$scat\]\] aus der Seite \[\[:$item\]\] entfernt"
			}
		}
	}
	if {[lsearch -exact [page [post $wiki {*}$get / list info / titles $scat]] missing] == -1 && [catch {llength [cat $scat *]}]} {
		puts [katedit $scat "Bot: SLA: $reason" {} / prependtext "\{\{Löschen|1=SLA: $reason ${~}\}\}\n\n" / minor]
		lappend llog "# Schnelllöschantrag auf Seite \[\[:$scat\]\] gestellt"
	} else {
		puts {Item verblieben}
	}
}

proc catdupl litem {
	global llog scat tcat reason topic wiki get format token
	set tcat [join $tcat]
	set llog [list $topic]
	foreach item $litem {
		set ncontent [string map [
			list \[\[$scat\]\] \[\[$tcat\]\]\n\[\[$scat\]\] \[\[$scat| \[\[$tcat\]\]\n\[\[$scat|
		] [set ocontent [contents t $item x]]]
		set summary "\[\[$tcat\]\] hinzugefügt: $reason"
		if {$ncontent ne $ocontent} {
			puts [katedit $item "Bot: $summary" $ncontent / minor]
			if ![dict get [page [post $wiki {*}$get / list info / titles $item]] ns] {
				lappend llog "# \[\[:$tcat\]\] in den Artikel \[\[:$item\]\] hinzugefügt"
			} else {
				lappend llog "# \[\[:$tcat\]\] in die Seite \[\[:$item\]\] hinzugefügt"
			}
		}
	}
}

proc log llog {
	global wsid idx topic ~ reason
	regsub -- {^(==.*?)[ ]?==} [contents id $wsid $idx] {\1 (erledigt) ==} nsect
	puts [set erl [lindex [
		katedid $wsid "[string trim [string map {== {}} $topic]]: erledigt" $nsect\n\{\{erledigt|${~}\}\} / section $idx
	] 1]]
	set top {= Kategorienlog am {{ers:#timel:j"." M" "Y", "H":"i":"s" ("T")"}} =}
	dict with erl {set diff "''in Bezug auf entsprechenden \[\[Special:Diff/$oldrevid/$newrevid|Warteschlangeneintrag\]\]: $reason''"}
	set llog [linsert $llog 1 $diff]
catch {
	puts [katedit "user:TaxonKatBot/Kategorienlog/[
		string map {Mai. Mai} [clock format [clock seconds] -format {%b. %Y} -locale de -timezone :Europe/Berlin]
	]" {Bot: Kategorienlog} {} / appendtext \n\n$top\n[join $llog \n]]
}}

while 1 {
	incr idx
	if [catch {jobinput $idx}] {
		exit
	} else {
		if {$idx == 1} {
			set token [login $wiki]
		}
	}
	if {[donecheck $contents $idx] == -1} {
		getcat $contents
		if ![string match {*Bot: *} $topic] {puts "kein \"Bot\": $topic" ; continue}
		if [catch {$modus [getitem $scat]}] {continue}
		log $llog
	}
#	catch {puts "$scat erledigt"}
}
