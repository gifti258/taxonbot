#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

set editafter 1
source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

lassign {} date page alttlemma
set n 0
states {
   t    {   input task "\nl:   Artikel löschen\nla:  Abschnitt löschen\nerl: Abschnitt erledigen\nbf:  Belege fehlen\ni:   Import\nu:   Upload\nb:   BIBR \
               \nbot: Botanfragen\nlk:  Löschkandidaten\na:   LKU Archivierung\nx:   Exit\n\nAuswahl: "
            if {$task in {la erl i u b bot lk}} {
               goto k
            } elseif {$task eq "l"} {
               goto l
            } elseif {$task eq "bf"} {
               goto bf
            } elseif {$task eq "a"} {
               goto a
            } elseif {$task eq "x"} {
               puts {}
               exit
            } else {
               goto t
            }
        }

   k    {   if {$task in {la erl}} {
               if {$page eq {}} {
                  input page "\nArtikel: "
               } else {
                  input sel "\nselber Artikel (j/n): "
                  if {$sel ne "j"} {
                     set page {}
                     goto k
                  }
               }
            } elseif {$task eq "i"} {
               set page {Wikipedia:Importwünsche}
            } elseif {$task eq "u"} {
               set page {Wikipedia:Importwünsche/Importupload}
            } elseif {$task eq "b"} {
               set page {Wikipedia:Bibliotheksrecherche/Anfragen}
            } elseif {$task eq "bot"} {
               set page {Wikipedia:Bots/Anfragen}
            } elseif {$task eq "lk"} {
               if {$date eq {}} {
                  input date "\nDatum: "
                  set page "Wikipedia:Löschkandidaten\/$date 2014"
               } else {
                  input date "\nl: weiterer Kandidat\nx: Menü\n\nAuswahl: "
                  if {$date eq "l"} {
                     set date {}
                     goto k
                  } else {
                     goto t
                  }
               }
            } else {
               goto t
            }
            set parsing [post $wiki {*}$format {*}$parse / page $page / prop sections / redirects true / format json]
            set page [get $parsing parse title]
            set sects [get $parsing parse sections]
            set lines [join [lmap index $sects summarytitle $sects {list [dict get $index index] [dict get $summarytitle line]}]]
            puts {}
            foreach {x y} $lines {
               puts "$x: $y"
            }
            if {$task eq "i"} {
               puts "u: Upload"
            } elseif {$task eq "u"} {
               puts "i: Import"
            }
            if {$task in {la erl}} {
               input section "x: Menü\n\nAbsatz Nr.: "
					if {$section == 0} {goto la}
            } else {
               input section "x: Menü\n\nAntrag Nr.: "
            }
            if {$section eq "u"} {
               set task u
               goto k
            } elseif {$section eq "i"} {
               set task i
               goto k
            } elseif {$section eq "x"} {
               goto t
            } elseif {$section eq {}} {
               goto k
            } else {
               set summarytitle [dict get $lines $section]
               puts "\n$section: $summarytitle"
            }
            set sectioncontent [content [post $wiki {*}$get / titles $page / rvsection $section]]
            set sectiondata [
               regexp -line -inline -all -- {^(?:==[ ]?\[\[.+?\[\[)(.+?)(?:\]\].+?\[\[)(.+?)(?:\]\][ ]?==)$} $sectioncontent
            ]
#            rex swiki,slemma -- 1,2 i [lindex $sectiondata end-1] {(?:\:[\:]?)(.+?)(?:\:)(.+?)$}
#            set tlemma [lindex $sectiondata end]
            set user [join [dict values [regexp -inline -- {none">(.+?)<} $sectioncontent]]]
            set importdata [dict values [regexp -all -inline -- {fullurl\:(.+?)\|} [string map {:: :} $sectioncontent]]]
            if {[llength $importdata] > 2} {
               set importdata [lreplace $importdata 0 0]
            }
            set swiki [lindex [split [lindex $importdata 0] :] 0]
            if [empty swiki] {
               set swiki de
            }
				set slemma [sql -> [join [lrange [split [lindex $importdata 0] :] 1 end] :]]
#            set slemma [sql -> [lindex [split [lindex $importdata 0] :] 1]]
            set tlemma [sql -> [lindex $importdata 1]]
            if {$task eq "la"} {
               goto la
            } elseif {$task eq {erl}} {
            	goto erl
            } elseif {$task eq "i" || $task eq "u" || $task eq "bot"} {
               goto km
            } elseif {$task eq "b"} {
               goto b
            } elseif {$task eq "lk"} {
               input status "\nbleibt/zurückgewiesen/löschen: "
               goto lk
            } else {
               goto t
            }
        }

   bf   {   input page "\nArtikel: "
            input inf "Hinweis: "
            if {$inf != {}} {
               set text "\{\{Belege|$inf\}\}\n\n"
            } else {
               set text "\{\{Belege\}\}\n\n"
            }
            set summary {Belege fehlen}
            puts "\n$page\n$text"
            input okay "Bitte bestätigen: "
            if {$okay == "j"} {
               puts "\n[edit $page $summary {} / prependtext $text]\n\n>>> Hinweis eingetragen!"
            }
            input more "\nanderer Artikel: (j\/n) "
            if {$more == "j"} {
               goto bf
            } else {
               goto t
            }
        }

   la   {   input reason "\nLöschgrund: "
				if {$section == 0} {set summary "Abschnitt 0 gelöscht: $reason"} else {set summary "/* $summarytitle */ gelöscht: $reason"}
            puts "\nSummary: $summary" ; gets stdin
            puts "[edit $page $summary {} / section $section / text {}]\n\n>>> Absatz gelöscht!"
            input more "\nweiterer Absatz: (j/n) "
            if {$more == "j"} {
               goto k
            } else {
               goto t
            }
        }

   erl  {   set summary "/* $summarytitle */ erledigt"
            puts "\nSummary: $summary" ; gets stdin
            puts "[edit $page $summary {} / appendtext \n\{\{erledigt|~~~~\}\} / section $section / minor]\n\n>>> Absatz erledigt!"
            input more "\nweiterer Absatz: (j/n) "
            if {$more == "j"} {
               goto k
            } else {
               goto t
            }
        }

   km   {   input task1 "\nr: Reservierung\nb: ImportBot\nv: Versionsimport\ni: Importartikel\nn: Nachricht\nl: Löschen\nx: Menü\n\nAuswahl: "
            if {$task1 == "r"} {
               goto ir
            } elseif {$task1 == "b"} {
               goto ib
            } elseif {$task1 == "v"} {
               goto iv
            } elseif {$task1 == "i"} {
               goto ii
            } elseif {$task1 == "n"} {
               goto in
            } elseif {$task1 == "l"} {
               goto il
            } else {
               goto t
            }
        }

   ir   {   set summary "\/* $summarytitle *\/ in Bearbeitung"
            if {$task eq "bot"} {
               set botwork "'''Anmerkung''': <u><span style=\"background-color:yellow\;\">'''Anfrage zur Erledigung durch\
                  \[\[user:TaxonBot\|TaxonBot\]\] in Bearbeitung!'''<\/span><\/u> ${~}"
               puts "\n$sectioncontent\n\n$botwork\n\nSummary: $summary" ; gets stdin
               puts "[edit $page $summary {} / section $section / appendtext "\n\n$botwork"]\n\n>>> Antrag reserviert!"
            } else {
               regsub -line -- {^(<span style.+?)$} $sectioncontent "\{\{\/In Arbeit\|Doc Taxon\|~~~~~\}\}\n\\1" sectioncontent
               puts "\n$sectioncontent\n\nSummary: $summary" ; gets stdin
               puts "[edit $page $summary {} / section $section / text [string map {<!--Exists--> {}} $sectioncontent]]\n\n>>> Antrag reserviert!"
               input impnews "\nb: ImportBot\ni: Importartikel\nn: Nachricht\nl: Antrag löschen\nx: Menü\n\nAuswahl: "
               if {$impnews eq "b"} {
                  goto ib
               } elseif {$impnews == "i"} {
                  goto ii
               } elseif {$impnews eq "n"} {
                  goto in
               } elseif {$impnews eq "l"} {
                  goto il
               }
            }
            goto k
        }

   ib   {   source importbot.tcl
            input news "\nBenachrichtigung? (j\/n): "
            if {$news eq "j"} {
               goto in
            } else {
               goto k
            }
        }

   iv   {   incr v
            source import.tcl
            set v 0
        }

   ii   {   rex iuser -- 1 i $sectioncontent {(?:Signatur.+?[=|\[\[])(Benutzer(in)?\:.+?)(?:\||\/)}
            set tlemma [lindex $sectiondata end]
            puts "\n$tlemma\n$iuser"
            input bnr "\nBNR: "
            input alttlemma "alternatives Ziel-Lemma: "
            if {![empty alttlemma] || $bnr eq "b" || $bnr eq "j"} {
               if ![empty alttlemma] {
                  set tlemma $alttlemma
               } else {
                  set tlemma "$iuser\/$tlemma"
               }
               puts "\n$tlemma"
            }
            set oldcontent [content [post $wiki {*}$get / titles $tlemma]]
            set newcontent "\{\{Importartikel\}\}\n\n$oldcontent"
            regsub -all -- {\[\[Cat[eé]gorie:|\[\[[CK]ateg[oó]r[ií][j]?a:|\[\[Category:|\[\[Κατηγορία:|\[\[Kategori[e]?:|\[\[Категор[іи]я:|\[\[カテゴリ:|\[\[Luokka:} \
               $newcontent "\[\[\:Kategorie\:" newcontent
            set summary {Importartikel}
            puts "\n$newcontent\n\n$summary"
            gets stdin
            puts "[edit $tlemma $summary {} / text $newcontent]\n\n>>> Importartikel!"
            input news "\nBenachrichtigung? (j\/n): "
            switch $news {j {goto in} n {goto il} default {goto k}}
        }

   in   {   if {$task eq "bot"} {
               set summary "\/* $summarytitle *\/ + InuseBot: \[\[TaxonBot|TaxonBot\]\]"
               set botworking "\{\{InuseBot\|TaxonBot\|Doc Taxon\}\}"
               puts "\n[edit $page $summary {} / section $section / appendtext "\n$botworking"]\n\n>>> Bot läuft!"
            } else {
               regsub -- #.* $slemma {} slemma
               regsub -- #.* $tlemma {} tlemma
#               rex user -- 2 i $sectioncontent {(?:Signatur.+?[=|\[\[]Benutzer(in|[ _]Diskussion|in[ _]Diskussion)?\:)(.+?)(?:\||\/)}
               input altuser "\nalternativer Benutzer: "
               if ![empty altuser] {
                  set user $altuser
               }
               set bluser [dict filter [regexp -all -inline -line -- {^#.*?\:(.*?)\].*?$} [
                  content [post $wiki {*}$get / titles Wikipedia:Importwünsche/Robinson]
               ]] value $user]
               if [empty bluser] {
                  set userdisk "Benutzer Diskussion:$user"
                  input altswiki "\nalternatives Quell-Wiki:  "
                  input altslemma "alternatives Quell-Lemma: "
                  input alttlemma "alternatives Ziel-Lemma:  "
                  input stock "\nBestand (j/n): "
                  if {$stock eq "n"} {
                     input nr "Namensraum: "
                  } else {
                     set nr a
                  }
                  input extra "\nZusatztext: "
                  if ![empty altswiki] {
                     set swiki $altswiki
                  }
                  if ![empty altslemma] {
                     set slemma $altslemma
                  }
                  if ![empty alttlemma] {
                     set tlemma $alttlemma
                  }
                  if {$nr eq "b" && [regexp -nocase -- {(Benutzer|User)} $tlemma] == 0} {
                     set tlemma "Benutzer:$user\/$tlemma"
                  }
                  if {$swiki ne "de"} {
                     set nswiki $swiki:
                  } else {
                     set nswiki {}
                  }
                  if {$stock eq "n"} {
                     set userdisktext "\n\n== Dein Importwunsch von \[\[:$nswiki$slemma\]\] nach \[\[:$tlemma\]\] ==\nHallo $user,\n\nDein Importwunsch ist erfüllt worden. Es wurde folgende Seite angelegt:\n* \[\[$tlemma\]\]"
                  } else {
                     set userdisktext "\n\n== Dein Importwunsch von \[\[:$nswiki$slemma\]\] nach \[\[:$tlemma\]\] ==\nHallo $user,\n\nDein Importwunsch ist erfüllt worden."
                  }
                  if {$extra eq "b"} {
                     set extra {Bitte bearbeite den Artikel zunächst in Deinem [[WP:BNR|Benutzernamensraum]] und verschiebe ihn dann in den [[WP:ANR|Artikelnamensraum]].}
                  }
                  if ![empty extra] {
                     set userdisktext "$userdisktext\n\n$extra"
                  }
                  set userdisktext "$userdisktext\n\nViel Spaß beim Editieren weiterhin,\n${~}<br \/>\n<small>ps: Wenn Du künftig nicht mehr über erledigte Importe informiert werden möchtest, trage Dich bitte in die \[\[WP:Importwünsche\/Robinson\|Robinson-Liste\]\] ein.<\/small>"
                  set summary "/* Dein Importwunsch von $nswiki$slemma nach $tlemma */ bearbeitet"
                  puts "$userdisktext\n\nSummary: $summary"
                  input okay "\nBitte bestätigen: "
                  if {$okay eq "j"} {
                     puts "\n[edit $userdisk $summary {} / appendtext $userdisktext / redirect true] \
                        \n\n>>> Antragsteller wurde benachrichtigt!"
                  } else {
                     goto k
                  }
               } else {
                  puts "\n$user möchte nicht benachrichtigt werden!"
               }
            }
            if {$task eq "bot"} {
               input del "\nAntrag erledigt (j/n): "
            } else {
               input del "\nAntrag löschen (j/n): "
            }
            if {$del eq "j" || $del eq "l"} {
               goto il
            } else {
               goto k
            }
        }

   il   {   set summary "\/* $summarytitle *\/ abgearbeitet"
            puts "\nSummary: $summary"
            gets stdin
            if {$task eq "bot"} {
               set botworking "\{\{InuseBot\|TaxonBot\|Doc Taxon\}\}"
               regsub -- $botworking $sectioncontent {} sectioncontent
               set erl "$sectioncontent\n\{\{erledigt\|1\=${~}\}\}"
               puts "\n$erl\n\nSummary: $summary" ; gets stdin
               puts "[edit $page $summary {} / section $section / text $erl]\n\n>>> BotJob erledigt!"
            } else {
               puts "[edit $page $summary {} / section $section / text {}]\n\n>>> Antrag gelöscht!"
            }
            if {$task eq "i" || $task eq "u" || $task eq "bot"} {
               goto k
            } else {
               goto t
            }
        }

   b    {   set page {Wikipedia:Bibliotheksrecherche/Anfragen}
            input btask "\ni: Info\nw: in Arbeit\nv: versandt\nx: Menü\ne: erledigt\n\nAuswahl: "
            if {$btask == "x"} {
               goto k
            }
            if {$btask in {i v w}} {
               set sectioncontent [content [post $wiki {*}$get / titles $page / rvsection $section]]
               regexp -- {\[\[(User|Benutzer(?:in)?)?\:(.+?)(/|\||\]\])} $sectioncontent -- user
               regexp -nocase -- {\[\[(User|Benutzer).*?\:(.+?[/\]\|]?)} $sectioncontent -- -- user
					set user [lindex [split {*}[dict values [
						regexp -nocase -inline -- {(?:User|Benutzer).*?\:(.*?)[/\|\]]} $sectioncontent
					]] /|\]] 0]
					if {$btask eq {i}} {
	               input text "Text: "
	            } else {
	               input extra "\nZusatztext: "
   	            if {$extra ne {}} {
      	            set extra " – $extra"
         	      }
         	   }
            }
            if {$btask eq {i}} {
					source api2.tcl ; set lang de1 ; source langwiki.tcl
					set token [login $wiki]
               set message "\n\n\{\{info\}\} \{\{ping\|1=$user\}\} $text ${~}"
               set summary "\/* $summarytitle *\/ Info"
               puts "\n$message\n\nSummary: $summary" ; gets stdin
               puts "[edit $page $summary {} / section $section / appendtext $message]\n\n>>> Info hinzugefügt!"
					source api.tcl ; set lang de ; source langwiki.tcl
					set token [login $wiki]
            } elseif {$btask eq {w}} {
					source api2.tcl ; set lang de1 ; source langwiki.tcl
					set token [login $wiki]
               set message "\n\n\{\{ping\|1=$user\}\} \{\{s\|working\}\}$extra ${~}"
               set summary "\/* $summarytitle *\/ in Arbeit"
               puts "\n$message\n\nSummary: $summary" ; gets stdin
               puts "[edit $page $summary {} / section $section / appendtext $message]\n\n>>> Anfrage in Arbeit!"
					source api.tcl ; set lang de ; source langwiki.tcl
					set token [login $wiki]
            } elseif {$btask eq {v}} {
					source api2.tcl ; set lang de1 ; source langwiki.tcl
					set token [login $wiki]
               set message "\n\n\{\{ping\|1=$user\}\} \{\{s\|mail\}\}$extra ${~}"
               set summary "\/* $summarytitle *\/ versandt"
               puts "\n$message\n\nSummary: $summary" ; gets stdin
               puts "[edit $page $summary {} / section $section / appendtext $message]\n\n>>> Artikel versandt!"
					source api.tcl ; set lang de ; source langwiki.tcl
					set token [login $wiki]
            } elseif {$btask eq {e}} {
               set message "\n\n\{\{erledigt\|1=${~}\}\}"
               set summary "\/* $summarytitle *\/ erledigt"
               puts "\n$message\n\nSummary: $summary" ; gets stdin
               puts "[edit $page $summary {} / section $section / appendtext $message]\n\n>>> Anfrage erledigt!"
            }
            goto k
        }

   lk   {   set lkcontent [content [post $wiki {*}$get / titles $page / rvsection $section]]
            set lktitle [join [dict values [regexp -inline -line -- {^(?:==[ ]?)(.+?)(?:[ ]?==)$} $lkcontent]]]
            if {$status == "b"} {
               set lknewtitle "\=\= [regsub -- {==[ ]?(.+?)[ ]?==} $lktitle {\1}] \(bleibt\) \=\="
               regsub -- {==[ ]?(.+?)[ ]?==} $lkcontent {== \1 (bleibt) ==} lknewcontent
            } elseif {$status == "z"} {
               set lknewtitle "\=\= [regsub -- {==[ ]?(.+?)[ ]?==} $lktitle {\1}] \(LAE\) \=\="
               regsub -- {==[ ]?(.+?)[ ]?==} $lkcontent {== \1 (LAE) ==} lknewcontent
            } elseif {$status == "l"} {
               set lknewtitle "\=\= [regsub -- {==[ ]?(.+?)[ ]?==} $lktitle {\1}] \(gelöscht\) \=\="
               regsub -- {==[ ]?(.+?)[ ]?==} $lkcontent {== \1 (gelöscht) ==} lknewcontent
            }
            regsub -all -- {\[\[.+?\||\[\[[:]?|\]\]|''|} $title($section) {} sectiontitle
            regsub -all -- {\[\[.+?\||\[\[[:]?|\]\]|''|\ \(bleibt\)|\ \(LAE\)|\ \(gelöscht\)} $lktitle {} summ
            input newsumm "\nalternativer Artikeltitel: "
            puts "\n$lknewtitle"
            input reason "\nGrund: "
            if {$status == "b"} {
               set reason "$lknewcontent\n\n\{\{Kasten\|1\='''Artikel bleibt\!''' $reason ${~}\}\}"
               set summary "\/* $summ \(bleibt\) *\/"
            } elseif {$status == "z"} {
               set reason "$lknewcontent\n\n\{\{Kasten\|1\='''L\öschantrag zurückgewiesen\!''' $reason ${~}\}\}"
               set summary "\/* $summ \(LAE\) *\/"
            } elseif {$status == "l"} {
               set reason "$lknewcontent\n\n\{\{Kasten\|1\='''Artikel gelöscht\!''' $reason ${~}\}\}"
               set summary "\/* $summ \(gelöscht\) *\/"
            }
            puts "\n$reason\n\n$summary"
            input ok "\nGrund okay? (j\/n) "
            if {$ok != "j"} {
               goto l
            }
            puts "\n[edit $page $summary {} / section $section / text $reason]"
            if {$newsumm != {}} {
               set summ $newsumm
            }
            set disk "Diskussion\:$summ"
            if {$status != "l"} {
               set content [content [post $wiki {*}$get / titles $summ / rvsection 0]]
               if {[regexp -- {\<\/noinclude\>\n\n} $content] == 1} {
                  regsub -- {^.+?\<\/noinclude\>\n\n} $content {} new
               } elseif {[regexp -- {\<\/noinclude\>\n} $content] == 1} {
                  regsub -- {^.+?\<\/noinclude\>\n} $content {} new
               } elseif {[regexp -- {\<\/noinclude\>} $content] == 1} {
                  regsub -- {^.+?\<\/noinclude\>} $content {} new
               }
               if {$status == "b"} {
                  set box "\{\{war L\öschkandidat\|$date 2014\}\}"
                  set summary "\[\[$page\#$summ \(bleibt\)\|Artikel war L\öschkandidat\]\]"
               } elseif {$status == "z"} {
                  set box "\{\{LAE\|$date 2014\}\}"
                  set summary "\[\[$page\#$summ \(LAE\)\|L\öschantrag zur\ückgewiesen\]\]"
               }
               puts "\n$new\n\n$box\n\n$summary" ; gets stdin
               puts "\n[edit $summ $summary {} / section 0 / text $new]\n\>\>\> LA ist raus\!\n"
               puts "\n[edit $disk $summary {} / prependtext "$box\n\n"]\n\>\>\> Artikel \"$summ\" bleibt\!\n"
               unset summ
               unset disk
            } else {
               goto l
            }
            goto k
        }

   l    {   if ![exists summ] {
               input title "\nLöschkandidat: "
               set disk "Diskussion:$title"
            } else {
               set title $summ
            }
            input reason "\ngelöscht wegen: "
            set reason "\[\[user:TaxonBot|TaxonBot\]\]: gelöscht wegen $reason"
            input check "\nArtikel $title und Disk $disk wegen $reason wirklich löschen? (j\/n) "
            if {$check == "j"} {
					source api2.tcl ; set lang de1 ; source langwiki.tcl
					set token [login $wiki]
               puts "\n[post $wiki {*}$format {*}$token / action delete / title $title / reason $reason]\n\>\>\> $title gelöscht"
               puts "\n[post $wiki {*}$format {*}$token / action delete / title $disk / reason $reason]\n\>\>\> $disk gelöscht"
					source api.tcl ; set lang de ; source langwiki.tcl
					set token [login $wiki]
            }
            goto k
        }

   a    {   set page {Wikipedia:Löschkandidaten/Urheberrechtsverletzungen}
            set sectioncontent [content [post $wiki {*}$get / titles $page / rvsection 5]]
            regexp -- {(?:==[ ]?)(.+?)(?:[ ]?==)} $sectioncontent -- date
            set amonth [lindex $date 1]
            set ayear $year
            if {$month == "01" && $amonth == "Dezember"} {
               set ayear [expr {$year - 1}]
            }
            input sure "\nTag $date wirklich nach $amonth $ayear archivieren? (j\/n): "
            if {$sure == "j"} {
               puts "\n[edit $page "\/* $date *\/ Bot: Archivierung" {} / section 5 / text {}]"
               puts ">>> Tag $date auf WP\:LKU archiviert."
               puts "\n[edit "$page\/Archiv\/$amonth $ayear" "\/* $date *\/ Bot: Archivierung" {} / appendtext "\n\n$sectioncontent"]"
               puts ">>> Tag $date auf Archivseite $amonth $ayear eingefügt."
            }
            goto t
        }
}

puts {}

