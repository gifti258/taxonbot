#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

#catch {if {[exec pgrep -cxu taxonbot NeueArtikel5.tc] > 1} {exit}}

source api2.tcl
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl ; set db [get_db dewiki]

#exit

source QSWORKLIST/@qsdict.db
set qswkat [read [set f [open QSWORKLIST/@qswkat.db r]]] ; close $f
foreach key {lkkat kdkat rvkat qskat phkat} {
	set $key [dict get $qswkat $key]
}
set wkat [read [set f [open WORKLIST/@wkat.db r]]] ; close $f
foreach key {wUEkat wUVkat wLUEkat wLkat wQFkat wNkat wKATkat wVVkat} {
	set $key [dict get $wkat $key]
}
set wkat1 [read [set f [open WORKLIST/@wkat1.db r]]] ; close $f
foreach key {wDWkat wINTkat wWkat wRDkat wAZkat} {
	set $key [dict get $wkat1 $key]
}
set wkat2 [read [set f [open WORKLIST/@wkat2.db r]]] ; close $f
foreach key {wALTkat wGEOkat wVFkat wDFkat} {
	set $key [dict get $wkat2 $key]
}
set wkatVS [read [set f [open WORKLIST/@wkatVS.db r]]] ; close $f
set wVSkat [dict get $wkatVS wVSkat]
set wDFit [read [set f [open WORKLIST/@wDFit.db r]]] ; close $f
mysqlreceive $db "
	select page_title
	from page, categorylinks
	where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt'
	order by page_title
;" pt {
	lappend hidden Kategorie:[sql -> $pt]
}

mysqlreceive $db "
	select page_title
	from page, categorylinks
	where cl_from = page_id and page_namespace = 0 and cl_to = 'Begriffsklärung'
	order by page_title
;" pt {
	lappend bkl [sql -> $pt]
}

set tday [clock format [clock seconds] -format %m%d -timezone :Europe/Berlin]
set tmonth [clock format [clock seconds] -format %m -timezone :Europe/Berlin]
set tyear [clock format [clock seconds] -format %Y -timezone :Europe/Berlin]
#set bkl [template Begriffsklärung 0]
set lportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (NeueArtikel)} x]
set lqsportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (QSWORKLIST)} x]
set lwportal [cat {Kategorie:Wikipedia:MerlBot-Listen Typ (WORKLIST)} x]
#foreach portal $lqsportal {if {$portal ni $lportal} {lappend slqsportal $portal}}
#foreach portal $lwportal {if {$portal ni $lportal && $portal ni $slqsportal} {lappend slwportal $portal}}
#foreach portal $lportal {lremove lqsportal $portal}
#set nadb [read [set f [open NeueArtikel.match/NeueArtikel-$tday r]]] ; close $f
#set sdb [lrange [split $nadb \n] 1 end-1]
#if {{/leer/} ni [dict values [lindex $sdb end-2]]} {puts {Vorlage fehlerhaft} ; exit}
#set d {}
#foreach line $sdb {
#	dict with line {
#		if {[lsearch -exact $d $portal] == -1} {
#			lappend d $portal [list listformat $listformat alt $alt titles [list $hit $title $neu]]
#		} else {
#			dict lappend d $portal [list $hit $title $neu]
#		}
#	}
#}
#foreach {1 2} $d {lappend e $1 [join [list [lrange $2 0 4] [list [lrange $2 4 end]]]]}
#foreach qsportal $slqsportal {lappend e $qsportal x}
#foreach wportal $slwportal {lappend e $wportal x}

#set aaaa 0

proc computerspiele {portal nportal data} {
	global tmonth bkl nacount
	set linedateformat {%e.&nbsp;%B}
	dict with data {
		set altdate [clock scan $alt -format {%Y %m %d}]
		set locportal [string map {& {\&}} [join [dict values [
			regexp -inline -- {<!--MB-NeueArtikel-->(.*)<!--MB-NeueArtikel-->} $nportal
		]]]]
		foreach item [regexp -all -inline -- {\[\[.*?\]\]} $locportal] {
			regsub -all -- , $item @comma@ comma
			regsub -- [regexvar $item] $locportal $comma locportal
		}
		set locportal [string map {@comma@ , {\&} &} [split $locportal ,]]
		foreach 1 $locportal {lappend tlocportal [string trim $1]}
		foreach line $tlocportal {
			if ![empty line] {
				regsub -all -nocase -- {\[\[(?!Datei:|File:|:)} $line \[\[: nline
				regexp -- {\[\[(.*?)\]\] \((.*?)\)} $nline -- item linedate
				set linedate [string trim [
					clock format [clock scan $linedate -format $linedateformat -locale de] -format $linedateformat -locale de
				]]
				set lineday [clock format [clock scan $linedate -format $linedateformat -locale de] -format %d]
				set linemonth [clock format [clock scan $linedate -format $linedateformat -locale de] -format %m]
				set lineyear [clock format [clock scan $linedate -format $linedateformat -locale de] -format %Y]
				if {$linemonth eq {12} && $tmonth eq {01}} {
					set clinedate [clock scan "[incr lineyear -1] $linemonth $lineday" -format {%Y %m %d}]
				} else {
					set clinedate [clock scan "$lineyear $linemonth $lineday" -format {%Y %m %d}]
				}
				if {$clinedate > [expr $altdate - 86400] && ![missing $item] && ![redirect $item] && $item ni $bkl} {
					lappend lncportal $clinedate "\[\[$item\]\] ($linedate)"
				}
			}
		}
		foreach {hit lemma ts} [lrange [join [lsort -unique -decreasing $titles]] 1 end] {
			if {$lemma eq {/leer/}} {continue}
			if {$hit == 3} {
				lassign [list [lindex $lemma 0] [lindex $lemma 1]] src tgt
				if {[string first \[\[:$src\]\] $lncportal] > -1 || [string first \[\[$src\]\] $lncportal] > -1} {
					set lncportal [string map [list \[\[:$src\]\] \[\[:$tgt\]\] \[\[$src\]\] \[\[:$tgt\]\]] $lncportal]
					continue
				} else {
					set lemma $tgt
				}
			}
  			if {[redirect $lemma] || [missing $lemma] || $lemma in $bkl} {continue}
			if {[string first \[\[:$lemma\]\] $lncportal] == -1 && [string first \[\[$lemma\]\] $lncportal] == -1} {
				set neudate [clock scan $ts -format {%Y %m %d}]
				set linets [clock format $neudate -format $linedateformat -locale de]
				set neu [string trim [clock format $neudate -format {%e.&nbsp;%B} -locale de]]
				set lncportal [linsert $lncportal 0 $neudate "\[\[:$lemma\]\] ($neu)"]
			}
		}
		set nacount [regexp -all -- {\[\[:} $lncportal]
		return [string map {& {\&}} [join [dict values [lsort -stride 2 -integer -decreasing $lncportal]] ,\n]]
	}
}

proc portals {portal nportal data} {
	global tmonth bkl nacount
	set lncportal {}
	dict with data {
		if {$listformat eq {SHORTLIST}} {set linedateformat %d.%m.} else {set linedateformat {%d. %b}}
		set dateformat {%Y %m %d}
		set altdate [clock scan $alt -format $dateformat]
		set locportal [split [join [dict values [
			regexp -inline -- {<!--MB-NeueArtikel-->(.*)<!--MB-NeueArtikel-->} $nportal
		]]] \n]
		if {$locportal eq {{Der Inhalt (neue Artikel) wird in den nächsten Stunden bzw. Tagen aktualisiert.}}} {set locportal {}}
		foreach line $locportal {
			lassign {} nline2 nline12
			if ![empty line] {
				regsub -all -nocase -- {\[\[(?!Datei:|File:|:)} $line \[\[: nline
				if {$listformat eq {SHORTLIST}} {
					regexp -- {(\d{1,2}\.\d\d\.)} $nline -- olinedate
				} else {
					regexp -- {(\d{1,2}\. \w{3,4})} $nline -- olinedate
				}
				if {[string index $olinedate 1] eq {.}} {
					set linedate 0$olinedate
					set nline [string map [list $olinedate $linedate] $nline]
				} else {
					set linedate $olinedate
				}
				if {$linedate ne {}} {
					set lineday [clock format [clock scan $linedate -format $linedateformat -locale de] -format %d]
					set linemonth [clock format [clock scan $linedate -format $linedateformat -locale de] -format %m]
					set lineyear [clock format [clock scan $linedate -format $linedateformat -locale de] -format %Y]
					if {$linemonth eq {12} && $tmonth eq {01}} {
						set clinedate [clock scan "[incr lineyear -1] $linemonth $lineday" -format {%Y %m %d}]
					} else {
						set clinedate [clock scan "$lineyear $linemonth $lineday" -format {%Y %m %d}]
					}
					if {$clinedate > [expr $altdate - 86400]} {
						regexp -- {^(.*? )\[} $nline -- nline1
						set znline [dict values [regexp -all -inline -- {\[\[(.*?)\]\]} $nline]]
						foreach item $znline {if {![missing $item] && ![redirect $item] && $item ni $bkl} {lappend nline2 \[\[$item\]\]}}
					}
				}
				if ![empty nline2] {
					lappend lncportal $clinedate [append nline12 $nline1 [join $nline2 { - }]]
				}
			}
		}
		foreach {hit lemma ts} [lrange [join [lsort -unique -decreasing $titles]] 1 end] {
			if {$lemma eq {/leer/}} {continue}
			if {$hit == 3} {
				lassign [list [lindex $lemma 0] [lindex $lemma 1]] src tgt
				if {[string first \[\[:$src\]\] $lncportal] > -1 || [string first \[\[$src\]\] $lncportal] > -1} {
					set lncportal [string map [list \[\[:$src\]\] \[\[:$tgt\]\] \[\[$src\]\] \[\[:$tgt\]\]] $lncportal]
					continue
				} else {
					set lemma $tgt
				}
			}
			if {[redirect $lemma] || [missing $lemma] || $lemma in $bkl} {continue}
			if {[string first \[\[:$lemma\]\] $lncportal] == -1 && [string first \[\[$lemma\]\] $lncportal] == -1} {
				set neudate [clock scan $ts -format $dateformat]
				set linets [clock format $neudate -format $linedateformat -locale de]
				set reset 0
				foreach {tskey line} $lncportal {
					if {$tskey == $neudate} {
						set lncportal [string map [
							list >$linets</small> ">$linets</small> \[\[:$lemma\]\] -" "* $linets.:" "* $linets.: \[\[:$lemma\]\] -" "* $linets:" "* $linets: \[\[:$lemma\]\] -"
						] $lncportal]
						set reset 1
					}
				}
				if !$reset {
					if {$listformat eq {SHORTLIST}} {
						lappend lncportal $neudate "• <small>$linets</small> \[\[:$lemma\]\]"
					} elseif {[lindex $linets 1] eq {Mai}} {
						lappend lncportal $neudate "* $linets: \[\[:$lemma\]\]"
					} else {
						lappend lncportal $neudate "* $linets.: \[\[:$lemma\]\]"
					}
				}
			}
		}
		set nacount [regexp -all -- {\[\[:} $lncportal]
#puts $lncportal
		return [string map {& {\&}} [join [dict values [lsort -stride 2 -integer -decreasing $lncportal]] \n]]
	}
}

proc catselect {key kdbranch catdb icatdb} {
	global $key\kat
	lassign {} $key\match wDWmatch
	if {$key eq {kd}} {
		set keykat [dict get $kdkat $kdbranch]
		if [empty keykat] {return {}}
		foreach kdcat $keykat {
			set icheck 0
			if {$kdcat in $icatdb} {
				incr icheck
				break
			}
		}
		if !$icheck {
			foreach kdcat $keykat {
				if {$kdcat in $catdb} {
					lappend kdmatch $kdcat
				}
			}
		}
		return $kdmatch
	} else {
		set keykat [subst $$key\kat]
		foreach "$key l$key\cat" $keykat {
			set icheck 0
			if {$key eq {qs}} {set l$key\cat [dict get [subst $[subst l$key\cat]] pagecat]}
#foreach item [subst $[subst l$key\cat]] {set myarray($item) 1}
#foreach item $icatdb { if {$myarray($item)} { incr icheck ; break } }
#array unset myarray
			foreach $key\cat [subst $[subst l$key\cat]] {
				if {[subst $$key\cat] in $icatdb} {
					incr icheck
					break
				}
			}
#			set icheck [llength [struct::set intersect [subst $[subst l$key\cat]] $icatdb]]
			if !$icheck {
				foreach $key\cat [subst $[subst l$key\cat]] {
					if {[subst $$key\cat] in $catdb && [subst $$key] ni [subst $$key\match]} {
						lappend $key\match [subst $$key]
					}
				}
			}
			if {[llength $wDWmatch] == 50} {break}
		}
		return [subst $$key\match]
	}
}

proc qsw portal {
	global lkkat kdkat rvkat qskat phkat phdict qscount listformat
	lassign {0 LIST ALL {} {''Zurzeit keine''} {} {}} qscount listformat LISTS ALWAYSSHOW EMPTY IGNORE-QS QSWORKLIST
	set qswdb [read [set f [open QSWORKLIST/[string map {{ } _ ~ ~~~~~ / ~ ! ´´´´} $portal] r]]] ; close $f
	dict with qswdb {
		set listformat [dict get $param listformat]
		set LISTS [join [split [dict get $param LISTS] ,]]
		set ALWAYSSHOW [join [split [dict get $param ALWAYSSHOW] ,]]
		set EMPTY [dict get $param EMPTY]
		try {set IGNORE-QS [join [split [dict get $param IGNORE-QS] ,]]} on 1 {} {set IGNORE-QS {}}
#set LISTS ALL
		if {({ALL} in $LISTS && {-LK} ni $LISTS) || {LK} in $LISTS} {
			set lkblock {}
			set lkmatch [catselect lk -- $catdb $icatdb]
#puts lkmatch:$lkmatch
			foreach lk [lsort -unique $lkmatch] {
				if [matchtemplate $lk Vorlage:Löschantragstext] {catch {
					regexp -- {\{\{Löschantragstext\|tag=(.*?)\|monat=(.*?)\|jahr=(.*?)\|titel=(.*?)[|\}]} [conts t $lk x] -- dy mo yr tx
					set ladate1 [string map {{ } {}} [clock format [
						set c [clock scan [list $dy $mo $yr] -format {%e %B %Y} -locale de]
					] -format %e.%N.]]
					set ladate2 [string trim [clock format $c -format {%e. %B %Y} -locale de]]
					lappend lkblock [format {{{W-Link| %s |Wikipedia:Löschkandidaten/%s#%s|LA-%s}}} $lk $ladate2 $tx $ladate1]
				}}
			}
			incr qscount [set lkcount [llength $lkblock]]
			set lkblock [join $lkblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set lkbranch ";\[\[Datei:Fairytale Trash Question.svg|30x15px|text-unten|Löschkandidat|link=:Kategorie:Wikipedia:Löschkandidat\]\]&nbsp;Löschkandidat<small> ([tdot $lkcount])</small>"
			if ![empty lkblock] {
				append QSWORKLIST \n$lkbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$lkblock
			} elseif {({ALL} in $ALWAYSSHOW && {-LK} ni $ALWAYSSHOW) || {LK} in $ALWAYSSHOW} {
				append QSWORKLIST \n$lkbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-KD} ni $LISTS) || {KD} in $LISTS} {
			set kdblock {}
			foreach kdbranch {kdla kdub kdzf kdqs} {
				set kdmatch [catselect kd $kdbranch $catdb $icatdb]
#puts kdmatch:$kdmatch
				foreach kd [lsort -unique $kdmatch] {
					catch {
						set kdc [conts t $kd x]
#						puts $kdbranch:$kd
						switch $kdbranch {
							kdla	{
										if [matchtemplate $kd Vorlage:Löschantragstext] {
											regexp -- {Löschantragstext\|tag=(.*?)\|monat=(.*?)\|jahr=(.*?)\|titel=(.*?)[|\}]} $kdc -- dy mo yr tx
											set ladate1 [string map {{ } {}} [clock format [
												set c [clock scan [list $dy $mo $yr] -format {%e %B %Y} -locale de]
											] -format %e.%N.]]
											set ladate2 [string map {{ } {}} [clock format $c -format %Y/%B/%e -locale de]]
											lappend kdblock [format {{{W-Link| %s |Wikipedia:WikiProjekt Kategorien/Diskussionen/%s#%s|LA-%s}}} $kd $ladate2 $tx $ladate1]
										}
									}
							kdub	{
										if [matchtemplate $kd Vorlage:Umbenennungstext] {
											regexp -- {Umbenennungstext\|tag=(.*?)\|monat=(.*?)\|jahr=(.*?)\|ziel=(.*?)[|\}]} $kdc -- dy mo yr tx
											set ladate1 [string map {{ } {}} [clock format [
												set c [clock scan [list $dy $mo $yr] -format {%e %B %Y} -locale de]
											] -format %e.%N.]]
											set ladate2 [string map {{ } {}} [clock format $c -format %Y/%B/%e -locale de]]
											lappend kdblock [format {{{W-Link| %s |Wikipedia:WikiProjekt Kategorien/Diskussionen/%s#%s nach Kategorie:%s|KU-%s}}} $kd $ladate2 $kd $tx $ladate1]
										}
									}
							kdzf	{
										if [matchtemplate $kd Vorlage:Zusammenführungstext] {
											regexp -- {Zusammenführungstext\|tag=(.*?)\|monat=(.*?)\|jahr=(.*?)\|ziel=(.*?)[|\}]} $kdc -- dy mo yr tx
											set ladate1 [string map {{ } {}} [clock format [
												set c [clock scan [list $dy $mo $yr] -format {%e %B %Y} -locale de]
											] -format %e.%N.]]
											set ladate2 [string map {{ } {}} [clock format $c -format %Y/%B/%e -locale de]]
											lappend kdblock [format {{{W-Link| %s |Wikipedia:WikiProjekt Kategorien/Diskussionen/%s#%s nach Kategorie:%s|KZ-%s}}} $kd $ladate2 $kd $tx $ladate1]
										}
									}
							kdqs	{
										if [matchtemplate $kd Vorlage:QS-Antrag-Kategorien] {
											regexp -- {QS-Antrag-Kategorien\|tag=(.*?)\|monat=(.*?)\|jahr=(.*?)[|\}]} $kdc -- dy mo yr
											set ladate1 [string map {{ } {}} [clock format [
												set c [clock scan [list $dy $mo $yr] -format {%e %B %Y} -locale de]
											] -format %e.%N.]]
											set ladate2 [string map {{ } {}} [clock format $c -format %Y/%B/%e -locale de]]
											lappend kdblock [format {''{{W-Link| %s |Wikipedia:WikiProjekt Kategorien/Diskussionen/%s#%s|KQS-%s}}''} $kd $ladate2 $kd $ladate1]
										}
									}
						}
					}
				}
			}
			incr qscount [set kdcount [llength $kdblock]]
			set kdblock [join $kdblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set kdbranch ";\[\[Datei:Categorisation-hierarchy-left2right.svg|30x15px|text-unten|Kategoriendiskussion|link=:Kategorie:Wikipedia:Kategorienwartung\]\]&nbsp;Kategoriendiskussion<small> ([tdot $kdcount])</small>"
			if ![empty kdblock] {
				append QSWORKLIST \n$kdbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$kdblock
			} elseif {({ALL} in $ALWAYSSHOW && {-KD} ni $ALWAYSSHOW) || {KD} in $ALWAYSSHOW} {
				append QSWORKLIST \n$kdbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-RV} ni $LISTS) || {RV} in $LISTS} {
			set rvblock {}
			set rvmatch [catselect rv -- $catdb $icatdb]
#puts rvmatch:$rvmatch
			foreach rv [lsort -unique $rvmatch] {
#puts $rv
				if {[matchtemplate $rv Vorlage:Review] || [matchtemplate $rv Vorlage:Schreibwettbewerb] || [matchtemplate $rv Vorlage:UIBK-Bio]} {
					regexp -- {\{\{(Review\|(.*?)|Schreibwettbewerb|UIBK-Bio)??\}\}} [conts t $rv x] -- rvpage rvlink
#puts $rvpage:$rvlink ; gets stdin
					if {$rvpage eq {Schreibwettbewerb}} {
						lappend rvblock [format {[[:%s]]<small> [[WP:SW|(SW)]]</small>} $rv]
					} elseif {[string first Review $rvpage] > -1} {
						lappend rvblock [format {[[:%s]]<small> [[WP:RV%s#%s|(%s)]]</small>} $rv $rvlink $rv $rvlink]
					} elseif {$rvpage eq {UIBK-Bio}} {
						lappend rvblock [format {[[:%s]]<small> [[WD:WikiProjekt UIBK Biologie#%s|(UIBK-Bio)]]</small>} $rv $rv]
					}
				}
			}
			incr qscount [set rvcount [llength $rvblock]]
			set rvblock [join $rvblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set rvbranch ";\[\[Datei:Qsicon inArbeit blue.svg|30x15px|text-unten|Review|link=:Kategorie:Wikipedia:Reviewprozess\]\]&nbsp;Review<small> ([tdot $rvcount])</small>"
			if ![empty rvblock] {
				append QSWORKLIST \n$rvbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$rvblock
			} elseif {({ALL} in $ALWAYSSHOW && {-RV} ni $ALWAYSSHOW) || {RV} in $ALWAYSSHOW} {
				append QSWORKLIST \n$rvbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-QS} ni $LISTS) || {QS} in $LISTS} {
			set qsblock {}
			set qsmatch [catselect qs -- $catdb $icatdb]
#puts qsmatch:$qsmatch
			foreach qs [lsort -unique $qsmatch] {
				set qsdict [dict get $qskat $qs]
				dict with qsdict {
					if {[matchtemplate $qs Vorlage:$qstempl] && ((${IGNORE-QS} ne {ALL} && $qstempl ni ${IGNORE-QS}) || $qsshort eq {0})} {
						switch $qsshort {
							0			{
											regexp -- {\{\{QS-Antrag\|(.*?)[|\}]} [conts t $qs x] -- qsdate1
											set qsdate2 [string map {{ } {}} [
												clock format [clock scan $qsdate1 -format {%e. %B %Y} -locale de] -format %e.%N.
											]]
											lappend qsblock [
												format {{{W-Link| %s |Wikipedia:Qualitätssicherung/%s#%s|QS-%s}}} $qs $qsdate1 $qs $qsdate2
											]
										}
							AUG		{
											lappend qsblock [format {''{{W-Link| %s |Diskussion:%s|%s}}''} $qs $qs $qsshort]
										}
							BKP		{
											set nut {}
											regexp -- {\{\{QS-BKS\|(.*?)[|\}]} [conts t $qs x] -- nut
											if {[string tolower $nut] eq {knacknüsse=ja}} {set qslong WP:BKF/K}
											lappend qsblock [format {''{{W-Link| %s |%s#%s|%s}}''} $qs $qslong $qs $qsshort]
										}
							C			{
											set nut {}
											regexp -- {\{\{QS-Chemie\|(.*?)[|\}]} [conts t $qs x] -- nut
											if {[string tolower $nut] eq {knacknüsse=ja}} {set qslong WP:RC/K}
											lappend qsblock [format {''{{W-Link| %s |%s#%s|%s}}''} $qs $qslong $qs $qsshort]
										}
							FF			{
											regexp -- {\{\{QS-FF\|(.*?)[|\}]} [conts t $qs x] -- qsdate
											if ![catch {clock scan [string trim $qsdate] -format {%B %Y} -locale de}] {
												lappend qsblock [format {''{{W-Link| %s |%s#%s|%s}}''} $qs $qslong $qsdate $qsshort]
											} else {
												lappend qsblock [format {''{{W-Link| %s |%s|%s}}''} $qs $qslong $qsshort]
											}
										}
							MIL		{
											lappend qsblock [format {''{{W-Link| %s |Diskussion:%s|%s}}''} $qs $qs $qsshort]
										}
							SCHIFF	{
											lappend qsblock [format {''{{W-Link| %s |Diskussion:%s|%s}}''} $qs $qs $qsshort]
										}
							U			{
											lappend qsblock [format {''{{W-Link| %s |Diskussion:%s|%s}}''} $qs $qs $qsshort]
										}
							USA		{
											regexp -- {\{\{QS-USA\|(.*?)[|\}]} [conts t $qs x] -- state
											lappend qsblock [format {''{{W-Link| %s |%s#%s|%s}}''} $qs $qslong $state $qsshort]
										}
							WF			{
											lappend qsblock [format {''{{W-Link| %s |Diskussion:%s|%s}}''} $qs $qs $qsshort]
										}
							§			{
											set nut {}
											regexp -- {\{\{QS-Recht\|(.*?)[|\}]} [conts t $qs x] -- nut
											if {[string tolower $nut] eq {knacknüsse=ja}} {append qslong /Knacknüsse}
											lappend qsblock [format {''{{W-Link| %s |%s#%s|%s}}''} $qs $qslong $qs $qsshort]
										}
							default	{
											lappend qsblock [format {''{{W-Link| %s |%s#%s|%s}}''} $qs $qslong $qs $qsshort]
										}
						}
					}
				}
			}
			incr qscount [set qsqscount [llength $qsblock]]
			set qsblock [join $qsblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : $listformat eq {CLIST} ? {#} : {*}}] "]
			set qsbranch ";\[\[Datei:Qsicon Fokus2.svg|30x15px|text-unten|Qualitätssicherung|link=:Kategorie:Wikipedia:Qualitätssicherung\]\]&nbsp;Qualitätssicherung<small> ([tdot $qsqscount])</small>"
			if ![empty qsblock] {
				append QSWORKLIST \n$qsbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$qsblock
			} elseif {({ALL} in $ALWAYSSHOW && {-QS} ni $ALWAYSSHOW) || {QS} in $ALWAYSSHOW} {
				append QSWORKLIST \n$qsbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-PH} ni $LISTS) || {PH} in $LISTS} {
			set phblock {}
			set phmatch [catselect ph -- $catdb $icatdb]
#puts phmatch:$phmatch
			foreach ph [lsort -unique $phmatch] {
				if {[matchtemplate $ph Vorlage:Portalhinweis] || [matchtemplate $ph Vorlage:Projekthinweis] || [matchtemplate $ph Vorlage:Redaktionshinweis]} {
					regexp -- {\{\{((Portal|Projekt|Redaktions)??hinweis)\|(.*?)(\|(.*?)\}|\})} [conts t $ph x] -- -- type proj -- sub
					switch $type {
						Portal		{set project PD:$proj}
						Projekt		{set project "WD:WikiProjekt $proj"}
						Redaktions	{set project "WP:Redaktion $proj"}
					}
					catch {
						set phdictval [dict get $phdict $type:$proj]
						set proj [lindex $phdictval 0]
						set project [lindex $phdictval 1]
					}
					switch $type {
						Portal		{
											lappend phblock [format {{{W-Link| %s |%s#%s|%s}}} $ph $project $ph $proj]
										}
						Projekt		{
											if ![empty sub] {
												lappend phblock [format {{{W-Link| %s |%s/%s#%s|%s}}} $ph $project $sub $ph $proj]
											} else {
												lappend phblock [format {{{W-Link| %s |%s#%s|%s}}} $ph $project $ph $proj]
											}
										}
						Redaktions	{
											if ![empty sub] {
												lappend phblock [format {{{W-Link| %s |%s#%s|%s}}} $ph $project $sub $proj]
											} else {
												lappend phblock [format {{{W-Link| %s |%s#%s|%s}}} $ph $project $ph $proj]
											}
										}
					}
				}
			}
			incr qscount [set phcount [llength $phblock]]
			set phblock [join $phblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set phbranch ";\[\[Datei:Icon tools.svg|30x15px|text-unten|Projekthinweis|link=:Kategorie:Wikipedia:Qualitätssicherung\]\]&nbsp;Projekthinweis<small> ([tdot $phcount])</small>"
			if ![empty phblock] {
				append QSWORKLIST \n$phbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$phblock
			} elseif {({ALL} in $ALWAYSSHOW && {-PH} ni $ALWAYSSHOW) || {PH} in $ALWAYSSHOW} {
				append QSWORKLIST \n$phbranch\n$EMPTY
			}
		}
		puts $QSWORKLIST
#		puts qscount:$qscount
#puts $listformat
		return [string map {& {\&}} $QSWORKLIST]
#		puts [edit user:TaxonBota/qstest "Bot: QSWORKLIST: $qscount" $QSWORKLIST]
	}
}

proc w portal {
	global db tyear tmonth wUEkat wUVkat wLUEkat wLkat wQFkat wNkat wKATkat wVVkat wDWkat wVSkat wINTkat wWkat wRDkat wAZkat wALTkat
	global wGEOkat wVFkat wDFkat wDFit hidden wcount listformat
	lassign {0 LIST ALL {} {''Zurzeit keine''} {}} wcount listformat LISTS ALWAYSSHOW EMPTY WORKLIST
	set wdb [read [set f [open WORKLIST/[string map {{ } _ / ~} $portal] r]]] ; close $f
	dict with wdb {
		set listformat [dict get $param listformat]
		set LISTS [join [split [dict get $param LISTS] ,]]
		set ALWAYSSHOW [join [split [dict get $param ALWAYSSHOW] ,]]
		set EMPTY [dict get $param EMPTY]
#set LISTS ALL
#set ALWAYSSHOW ALL
		if {({ALL} in $LISTS && {-UE} ni $LISTS) || {UE} in $LISTS} {
			set wUEblock {}
			set wUEmatch [catselect wUE -- $catdb $icatdb]
#puts wUEmatch:$wUEmatch
			if ![empty wUEmatch] {
				foreach wUE [lsort -unique $wUEmatch] {lappend orpt '[sql <- $wUE]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to = 'Wikipedia:Überarbeiten'
					order by page_title
				;" pt {
					lappend wUEblock "\[\[:[sql -> $pt]\]\]"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wUEcount [llength $wUEblock]]
			set wUEblock [join $wUEblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wUEbranch ";\[\[Datei:Qsicon Ueberarbeiten.svg|30x15px|text-unten|Überarbeiten|link=:Kategorie:Wikipedia:Überarbeiten\]\]&nbsp;Überarbeiten<small> ([tdot $wUEcount])</small>"
			if ![empty wUEblock] {
				append WORKLIST \n$wUEbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wUEblock
			} elseif {({ALL} in $ALWAYSSHOW && {-UE} ni $ALWAYSSHOW) || {UE} in $ALWAYSSHOW} {
				append WORKLIST \n$wUEbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-UV} ni $LISTS) || {UV} in $LISTS} {
			set wUVblock {}
			set wUVmatch [catselect wUV -- $catdb $icatdb]
#puts wUVmatch:$wUVmatch
			if ![empty wUVmatch] {
				foreach wUV [lsort -unique $wUVmatch] {lappend orpt '[sql <- $wUV]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to = 'Wikipedia:Unverständlich'
					order by page_title
				;" pt {
					set pt [sql -> $pt]
					lappend wUVblock "\[\[:$pt\]\]<small> \[\[Diskussion:$pt|(Disk)\]\]</small>"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wUVcount [llength $wUVblock]]
			set wUVblock [join $wUVblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wUVbranch ";\[\[Datei:Qsicon Unverstaendlich.svg|30x15px|text-unten|Allgemeinverständlichkeit|link=:Kategorie:Wikipedia:Unverständlich\]\]&nbsp;Allgemeinverständlichkeit<small> ([tdot $wUVcount])</small>"
			if ![empty wUVblock] {
				append WORKLIST \n$wUVbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wUVblock
			} elseif {({ALL} in $ALWAYSSHOW && {-UV} ni $ALWAYSSHOW) || {UV} in $ALWAYSSHOW} {
				append WORKLIST \n$wUVbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-LUE} ni $LISTS) || {LUE} in $LISTS} {
			set wLUEblock {}
			set wLUEmatch [catselect wLUE -- $catdb $icatdb]
#puts wLUEmatch:$wLUEmatch
			if ![empty wLUEmatch] {
				foreach wLUE [lsort -unique $wLUEmatch] {lappend orpt '[sql <- $wLUE]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to = 'Wikipedia:Lückenhaft'
					order by page_title
				;" pt {
					lappend wLUEblock "\[\[:[sql -> $pt]\]\]"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wLUEcount [llength $wLUEblock]]
			set wLUEblock [join $wLUEblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wLUEbranch ";\[\[Datei:Qsicon Lücke.svg|30x15px|text-unten|Lückenhaft|link=:Kategorie:Wikipedia:Lückenhaft\]\]&nbsp;Lückenhaft<small> ([tdot $wLUEcount])</small>"
			if ![empty wLUEblock] {
				append WORKLIST \n$wLUEbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wLUEblock
			} elseif {({ALL} in $ALWAYSSHOW && {-LUE} ni $ALWAYSSHOW) || {LUE} in $ALWAYSSHOW} {
				append WORKLIST \n$wLUEbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-L} ni $LISTS) || {L} in $LISTS} {
			set wLblock {}
			set wLmatch [catselect wL -- $catdb $icatdb]
#puts wLmatch:$wLmatch
			if ![empty wLmatch] {
				foreach wL [lsort -unique $wLmatch] {lappend orpt '[sql <- $wL]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to = 'Wikipedia:Nur_Liste'
					order by page_title
				;" pt {
					lappend wLblock "\[\[:[sql -> $pt]\]\]"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wLcount [llength $wLblock]]
			set wLblock [join $wLblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wLbranch ";\[\[Datei:QSicon Formatierung.svg|30x15px|text-unten|NurListe|link=:Kategorie:Wikipedia:Nur Liste\]\]&nbsp;Nur Liste<small> ([tdot $wLcount])</small>"
			if ![empty wLblock] {
				append WORKLIST \n$wLbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wLblock
			} elseif {({ALL} in $ALWAYSSHOW && {-L} ni $ALWAYSSHOW) || {L} in $ALWAYSSHOW} {
				append WORKLIST \n$wLbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-QF} ni $LISTS) || {QF} in $LISTS} {
			set wQFblock {}
			set wQFmatch [catselect wQF -- $catdb $icatdb]
#puts wQFmatch:$wQFmatch
			if ![empty wQFmatch] {
#				foreach wQF [lsort -unique $wQFmatch] {lappend wQFblock \[\[:$wQF\]\]}
				foreach wQF [lsort -unique $wQFmatch] {lappend orpt '[sql <- $wQF]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to = 'Wikipedia:Belege_fehlen'
					order by page_title
				;" pt {
					lappend wQFblock "\[\[:[sql -> $pt]\]\]"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wQFcount [llength $wQFblock]]
			set wQFblock [join $wQFblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wQFbranch ";\[\[Datei:Qsicon Quelle.svg|30x15px|text-unten|Belege fehlen|link=:Kategorie:Wikipedia:Belege fehlen\]\]&nbsp;Belege fehlen<small> ([tdot $wQFcount])</small>"
			if ![empty wQFblock] {
				append WORKLIST \n$wQFbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wQFblock
			} elseif {({ALL} in $ALWAYSSHOW && {-QF} ni $ALWAYSSHOW) || {QF} in $ALWAYSSHOW} {
				append WORKLIST \n$wQFbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-N} ni $LISTS) || {N} in $LISTS} {
			set wNblock {}
			set wNmatch [catselect wN -- $catdb $icatdb]
#puts wNmatch:$wNmatch
			if ![empty wNmatch] {
				foreach wN [lsort -unique $wNmatch] {lappend orpt '[sql <- $wN]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to = 'Wikipedia:Neutralität'
					order by page_title
				;" pt {
					lappend wNblock "\[\[:[sql -> $pt]\]\]"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wNcount [llength $wNblock]]
			set wNblock [join $wNblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wNbranch ";\[\[Datei:Qsicon Achtung.svg|30x15px|text-unten|Neutralität|link=:Kategorie:Wikipedia:Neutralität\]\]&nbsp;Neutralität<small> ([tdot $wNcount])</small>"
			if ![empty wNblock] {
				append WORKLIST \n$wNbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wNblock
			} elseif {({ALL} in $ALWAYSSHOW && {-N} ni $ALWAYSSHOW) || {N} in $ALWAYSSHOW} {
				append WORKLIST \n$wNbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-KAT} ni $LISTS) || {KAT} in $LISTS} {
			set wKATblock {}
			set wKATmatch [catselect wKAT -- $catdb $icatdb]
#puts wKATmatch:$wKATmatch
			if ![empty wKATmatch] {
				foreach wKAT [lsort -unique $wKATmatch] {
					if {![missing $wKAT] && ![redirect $wKAT]} {
						set lpagecat [pagecat $wKAT]
						foreach cat $lpagecat {
							if {$cat in $hidden} {
								lremove lpagecat $cat
							}
						}
						if {$lpagecat eq {}} {
							lappend wKATblock "\[\[:$wKAT\]\]"
						}
					}
				}
			}
			incr wcount [set wKATcount [llength $wKATblock]]
			set wKATblock [join $wKATblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wKATbranch ";\[\[Datei:Nuvola filesystems folder red open.png|30x15px|text-unten|Kategorisieren|link=:Wikipedia:Kategorien\]\]&nbsp;Nicht kategorisierte Seite<small> ([tdot $wKATcount])</small>"
			if ![empty wKATblock] {
				append WORKLIST \n$wKATbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wKATblock
			} elseif {({ALL} in $ALWAYSSHOW && {-KAT} ni $ALWAYSSHOW) || {KAT} in $ALWAYSSHOW} {
				append WORKLIST \n$wKATbranch\n$EMPTY
			}
		}
if 0 {
		if {({ALL} in $LISTS && {-VV} ni $LISTS) || {VV} in $LISTS} {
			set wVVblock {}
			set wVVmatch [catselect wVV -- $catdb $icatdb]
#puts wVVmatch:$wVVmatch
			if ![empty wVVmatch] {
				foreach wVV [lsort -unique $wVVmatch] {
					#Blacklist vom Portal gewünscht, bis 01.01.2019 befristet
					if {$portal eq {Portal:Schach/Werkstatt} && [lindex $wVV 0] eq {Zoltán Sárosy} && $tyear < 2019} {continue}
					lassign [list [lindex $wVV 0] [lindex $wVV 1]] wVV0 wVV1
					if {[string first Gestorben [pagecat $wVV0]] == -1} {
						if {[lindex $wVV1 0] ne {}} {
							foreach {lll llt} $wVV1 {
								lappend lwVV1 "\[\[:$lll:$llt|$lll\]\]"
							}
							lappend wVVblock "\[\[:$wVV0\]\]<small> ([join $lwVV1 { / }])</small>"
						} else {
							lappend wVVblock "\[\[:$wVV0\]\]"
						}
					}
				}
			}
			incr wcount [set wVVcount [llength $wVVblock]]
			set wVVblock [join $wVVblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wVVbranch ";\[\[Datei:Gnome-face-angel.svg|30x15px|text-unten|Verstorben|link=:Benutzer:MerlBot/Vermutlich verstorben\]\]&nbsp;Vermutlich verstorben<small> ([tdot $wVVcount])</small>"
			if ![empty wVVblock] {
				append WORKLIST \n$wVVbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wVVblock
			} elseif {({ALL} in $ALWAYSSHOW && {-VV} ni $ALWAYSSHOW) || {VV} in $ALWAYSSHOW} {
				append WORKLIST \n$wVVbranch\n$EMPTY
			}
		}
}
		#wVS
		if {({ALL} in $LISTS && {-VS} ni $LISTS) || {VS} in $LISTS} {
			set wVSblock {}
			set wVSmatch [catselect wVS -- $catdb $icatdb]
#puts wVSmatch:$wVSmatch
			if ![empty wVSmatch] {
				foreach wVS [lsort -unique $wVSmatch] {lappend orplt '[sql <- $wVS]'}
				mysqlreceive $db "
					select pl_title
					from pagelinks, page
					where page_id = pl_from and pl_title in ([join $orplt ,]) and pl_from_namespace = 2 and pl_namespace = 0 and page_title = 'MerlBot/Verwaiste_Artikel' and page_namespace = 2
					order by pl_title
				;" plt {
					lappend wVSblock "\[\[:[sql -> $plt]\]\]"
				}
				unset -nocomplain orplt
			}
			incr wcount [set wVScount [llength $wVSblock]]
			set wVSblock [join $wVSblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wVSbranch ";\[\[Datei:Qsicon empty.svg|30x15px|text-unten|Verwaiste Artikel|link=:Wikipedia:WikiProjekt Verwaiste Seiten\]\]&nbsp;Verwaist<small> ([tdot $wVScount])</small>"
			if ![empty wVSblock] {
				append WORKLIST \n$wVSbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wVSblock
			} elseif {({ALL} in $ALWAYSSHOW && {-VS} ni $ALWAYSSHOW) || {VS} in $ALWAYSSHOW} {
				append WORKLIST \n$wVSbranch\n$EMPTY
			}
		}
		#wSOL
		if {({ALL} in $LISTS && {-INT} ni $LISTS) || {INT} in $LISTS} {
			set wINTblock {}
			set wINTmatch [catselect wINT -- $catdb $icatdb]
#puts wINTmatch:$wINTmatch
			if ![empty wINTmatch] {
				foreach wINT [lsort -unique $wINTmatch] {lappend orpt '[sql <- $wINT]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to like '%lastig'
					order by page_title
				;" pt {
					lappend wINTblock "\[\[:[sql -> $pt]\]\]"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wINTcount [llength $wINTblock]]
			set wINTblock [join $wINTblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wINTbranch ";\[\[Datei:German-Language-Flag.svg|30x15px|text-unten|Internationalisierung|link=:Kategorie:Wikipedia:Staatslastig\]\]&nbsp;Internationalisierung<small> ([tdot $wINTcount])</small>"
			if ![empty wINTblock] {
				append WORKLIST \n$wINTbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wINTblock
			} elseif {({ALL} in $ALWAYSSHOW && {-INT} ni $ALWAYSSHOW) || {INT} in $ALWAYSSHOW} {
				append WORKLIST \n$wINTbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-W} ni $LISTS) || {W} in $LISTS} {
			set wWblock {}
			set wWmatch [catselect wW -- $catdb $icatdb]
#puts wWmatch:$wWmatch
			if ![empty wWmatch] {
				foreach wW [lsort -unique $wWmatch] {lappend orpt '[sql <- $wW]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to = 'Wikipedia:Widerspruch'
					order by page_title
				;" pt {
					lappend wWblock "\[\[:[sql -> $pt]\]\]"
				}
				unset -nocomplain orpt
			}
			incr wcount [set wWcount [llength $wWblock]]
			set wWblock [join $wWblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wWbranch ";\[\[Datei:Split-arrows.svg|30x15px|text-unten|Widerspruch|link=:Kategorie:Wikipedia:Widerspruch\]\]&nbsp;Widerspruch<small> ([tdot $wWcount])</small>"
			if ![empty wWblock] {
				append WORKLIST \n$wWbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wWblock
			} elseif {({ALL} in $ALWAYSSHOW && {-W} ni $ALWAYSSHOW) || {W} in $ALWAYSSHOW} {
				append WORKLIST \n$wWbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-RD} ni $LISTS) || {RD} in $LISTS} {
			set wRDblock {}
			set wRDmatch [catselect wRD -- $catdb $icatdb]
#puts wRDmatch:$wRDmatch
			if ![empty wRDmatch] {
				foreach wRDpair [lsort -unique $wRDmatch] {
					foreach wRD $wRDpair {lappend orpt '[sql <- [join [dict values [regexp -inline -- {^(.*?)(?:#|$)} $wRD]]]]'}
					lassign {} lwRDpair lct
					mysqlreceive $db "
						select cl_to
						from page, categorylinks
						where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to like 'Wikipedia:Redundanz\_%'
						order by page_title
					;" ct {
						if ![empty ct] {lappend lct "<small> \[\[:[string map {{Redundanz } Redundanz/} [sql -> $ct]]|(Disk)\]\]</small>"}
					}
					foreach wRDpairitem $wRDpair {lappend lwRDpair \[\[:$wRDpairitem\]\]}
					lappend wRDblock "[join $lwRDpair { ⇄ }][join [lsort -unique $lct]]"
					unset -nocomplain orpt lct
				}
			}
			incr wcount [set wRDcount [llength $wRDblock]]
			set wRDblock [join [lsort -unique $wRDblock] "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wRDbranch ";\[\[Datei:Merge-arrows.svg|30x15px|text-unten|Redundanz|link=:Kategorie:Wikipedia:Redundanz\]\]&nbsp;Redundanz<small> ([tdot $wRDcount])</small>"
			if ![empty wRDblock] {
				append WORKLIST \n$wRDbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wRDblock
			} elseif {({ALL} in $ALWAYSSHOW && {-RD} ni $ALWAYSSHOW) || {RD} in $ALWAYSSHOW} {
				append WORKLIST \n$wRDbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-GEO} ni $LISTS) || {GEO} in $LISTS} {
			set wGEOblock {}
			set wGEOmatch [catselect wGEO -- $catdb $icatdb]
#puts wGEOmatch:$wGEOmatch
			if ![empty wGEOmatch] {
				foreach wGEO [lsort -unique $wGEOmatch] {lappend orpt '[sql <- $wGEO]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and cl_to like 'Wikipedia:Lagewunsch%'
					order by page_title
				;" pt {
					lappend wGEOblock "\[\[:[sql -> $pt]\]\]"
				}
				set wGEOblock [lsort -unique $wGEOblock]
				unset -nocomplain orpt
			}
			incr wcount [set wGEOcount [llength $wGEOblock]]
			set wGEOblock [join $wGEOblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wGEObranch ";\[\[Datei:Georeference.svg|30x15px|text-unten|Lagewunsch|link=:Kategorie:Wikipedia:Lagewunsch\]\]&nbsp;Lagewunsch<small> ([tdot $wGEOcount])</small>"
			if ![empty wGEOblock] {
				append WORKLIST \n$wGEObranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wGEOblock
			} elseif {({ALL} in $ALWAYSSHOW && {-GEO} ni $ALWAYSSHOW) || {GEO} in $ALWAYSSHOW} {
				append WORKLIST \n$wGEObranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-AZ} ni $LISTS) || {AZ} in $LISTS} {
			lassign {} wAZdict wAZblock
			set wAZmatch [catselect wAZ -- $catdb $icatdb]
#puts wAZmatch:$wAZmatch
			if ![empty wAZmatch] {
				foreach wAZ [lsort -unique $wAZmatch] {lappend orpt '[sql <- $wAZ]'}
				mysqlreceive $db "
					select page_title, cl_to
					from page, categorylinks
					where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and ((cl_to like 'Wikipedia:Veraltet\_%' or cl_to = 'Wikipedia:Veraltet') and cl_to <> 'Wikipedia:Veraltete_Normdaten')
					order by page_title
				;" {pt ct} {
   				dict lappend wAZdict [sql -> $pt] Kategorie:[sql -> $ct]
				}
				foreach {wAZpt wAZlct} $wAZdict {
					set ldate {}
					if {{Kategorie:Wikipedia:Veraltet} in $wAZlct} {
						lappend ldate 1
					} else {
						foreach wAZct $wAZlct {
							regexp -- {Veraltet nach (.*)} $wAZct -- odate
							if ![exists odate] {continue}
							if {[string first Jahr $odate] == -1} {
								set sdate [clock format [clock scan "01 $odate" -format {%d %B %Y} -locale de] -format %Y-%m]
								set ndate [clock format [clock add [clock scan $sdate\-01 -format %Y-%m-%d] 1 month] -format %Y-%m]
								if {[clock scan $ndate\-01 -format %Y-%m-%d] <= [clock scan $tyear\-$tmonth\-01 -format %Y-%m-%d]} {
									lappend ldate $sdate
								}
							} else {
								set sdate [clock format [clock scan "01 01 $odate" -format {%d %m Jahr %Y}] -format %Y]
								set ndate [clock format [clock add [clock scan $sdate\-01-01 -format %Y-%m-%d] 1 year] -format %Y]
								if {[clock scan $ndate\-01-01 -format %Y-%m-%d] <= [clock scan $tyear\-01-01 -format %Y-%m-%d]} {
									lappend ldate $sdate
								}
							}
						}
					}
					if ![empty ldate] {
						if {$ldate == 1} {
							lappend wAZblock \[\[$wAZpt\]\]
						} else {
							lappend wAZblock "\[\[$wAZpt\]\]<small> ([join [lsort -unique $ldate] { / }])</small>"
						}
					}
				}
				unset -nocomplain orpt wAZdict ldate
			}
			incr wcount [set wAZcount [llength $wAZblock]]
			set wAZblock [join $wAZblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wAZbranch ";\[\[Datei:QSicon rot Uhr.svg|30x15px|text-unten|Veraltet|link=:Kategorie:Wikipedia:Veraltet\]\]&nbsp;Veraltet<small> ([tdot $wAZcount])</small>"
			if ![empty wAZblock] {
				append WORKLIST \n$wAZbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wAZblock
			} elseif {({ALL} in $ALWAYSSHOW && {-AZ} ni $ALWAYSSHOW) || {AZ} in $ALWAYSSHOW} {
				append WORKLIST \n$wAZbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-ALT} ni $LISTS) || {ALT} in $LISTS} {
			lassign {} lwALTblock wALTblock
			set wALTmatch [catselect wALT -- $catdb $icatdb]
#puts wAZmatch:$wAZmatch
			if ![empty wALTmatch] {
				foreach wALT [lsort -unique $wALTmatch] {lappend orpt '[sql <- $wALT]'}
				mysqlreceive $db "
					select page_title, tl_title
					from page b, templatelinks
					where tl_from = b.page_id and b.page_title in ([join $orpt ,]) and b.page_namespace = 0 and tl_title in (
						select page_title
						from page a, categorylinks
						where cl_from = a.page_id and a.page_namespace = 10 and a.page_title <> 'Veraltete_Vorlage' and cl_to = 'Vorlage:Veraltet'
					) and tl_from_namespace = 0 and tl_namespace = 10
					order by b.page_title
				;" {pt tt} {
					dict lappend lwALTblock "\[\[:[sql -> $pt]\]\]" "\{\{Vorlage|$tt\}\}"
				}
				unset -nocomplain orpt
			}
			foreach {pt ltt} $lwALTblock {
				lappend wALTblock "$pt<small> [join [lsort -unique $ltt] { / }]</small>"
			}
			unset -nocomplain lwALTblock
			incr wcount [set wALTcount [llength $wALTblock]]
			set wALTblock [join $wALTblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wALTbranch ";\[\[Datei:Template superseded.svg|30x15px|text-unten|Vorlage veraltet|link=:Kategorie:Vorlage:Veraltet\]\]&nbsp;Vorlage veraltet<small> ([tdot $wALTcount])</small>"
			if ![empty wALTblock] {
				append WORKLIST \n$wALTbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wALTblock
			} elseif {({ALL} in $ALWAYSSHOW && {-ALT} ni $ALWAYSSHOW) || {ALT} in $ALWAYSSHOW} {
				append WORKLIST \n$wALTbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-VF} ni $LISTS) || {VF} in $LISTS} {
			lassign {} lwVFblock wVFblock
			set wVFmatch [catselect wVF -- $catdb $icatdb]
#puts wGEOmatch:$wGEOmatch
			if ![empty wVFmatch] {
				foreach wVF [lsort -unique $wVFmatch] {lappend orpt '[sql <- $wVF]'}
				mysqlreceive $db "
					select page_title, tl_title
					from page b, templatelinks
					where b.page_id = tl_from and tl_from_namespace = 0 and tl_namespace = 10 and tl_title not in (
						select page_title
						from page a
						where a.page_namespace = 10
					) and b.page_title in ([join $orpt ,]) and b.page_namespace = 0
					order by b.page_title
				;" {pt tt} {
					dict lappend lwVFblock "\[\[:[sql -> $pt]\]\]" "\{\{Vorlage|$tt\}\}"
				}
				unset -nocomplain orpt
			}
			foreach {pt ltt} $lwVFblock {
				lappend wVFblock "$pt<small> [join [lsort -unique $ltt] { / }]</small>"
			}
			unset -nocomplain lwVFblock
			incr wcount [set wVFcount [llength $wVFblock]]
			set wVFblock [join $wVFblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wVFbranch ";\[\[Datei:Template-X.svg|30x15px|text-unten|Fehlende Vorlage|link=:Wikipedia:WikiProjekt Vorlagen/Arbeitsliste\]\]&nbsp;Nicht existierende Vorlageneinbindung<small> ([tdot $wVFcount])</small>"
			if ![empty wVFblock] {
				append WORKLIST \n$wVFbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wVFblock
			} elseif {({ALL} in $ALWAYSSHOW && {-VF} ni $ALWAYSSHOW) || {VF} in $ALWAYSSHOW} {
				append WORKLIST \n$wVFbranch\n$EMPTY
			}
		}
		if {({ALL} in $LISTS && {-DF} ni $LISTS) || {DF} in $LISTS} {
			lassign {} wDFblock lpt
			set wDFmatch [catselect wDF -- $catdb $icatdb]
#puts wDFmatch:$wDFmatch
			if ![empty wDFmatch] {
				foreach wDF [lsort -unique $wDFmatch] {lappend orpt '[sql <- $wDF]'}
				mysqlreceive $db "
					select page_title, il_to
					from page c, imagelinks
					where il_from = c.page_id and c.page_title in ([join $orpt ,]) and c.page_namespace = 0 and il_from_namespace = 0 and il_to not in (
						select page_title
						from page a
						where a.page_namespace = 6
					) and il_to not in (
						select page_title
						from commonswiki_p.page b
						where b.page_namespace = 6
					)
					order by page_title
				;" {pt it} {
					if {$it in $wDFit} {dict lappend lpt \[\[:[sql -> $pt]\]\] \[\[:Datei:[sql -> $it]\]\]}
				}
				if ![empty lpt] {
					foreach {pt lit} $lpt {
						lappend wDFblock "$pt<small> ([join [lsort -unique $lit] { / }])</small>"
					}
				}
				unset -nocomplain orpt lpt
			}
			incr wcount [set wDFcount [llength $wDFblock]]
			set wDFblock [join $wDFblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wDFbranch ";\[\[Datei:Qsicon image red.svg|30x15px|text-unten|Fehlende Bilder|link=:Wikipedia:Redaktion Bilder/Arbeitsliste fehlende Bilder\]\]&nbsp;Nicht existierende Dateien oder -Seiten<small> ([tdot $wDFcount])</small>"
			if ![empty wDFblock] {
				append WORKLIST \n$wDFbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wDFblock
			} elseif {({ALL} in $ALWAYSSHOW && {-DF} ni $ALWAYSSHOW) || {DF} in $ALWAYSSHOW} {
				append WORKLIST \n$wDFbranch\n$EMPTY
			}
		}
#wDW ans Ende
		if {({ALL} in $LISTS && {-DW} ni $LISTS) || {DW} in $LISTS} {
			set wDWblock {}
			set wDWmatch [catselect wDW -- $catdb $icatdb]
#puts wDWmatch:$wDWmatch
			if ![empty wDWmatch] {
				foreach wDW $wDWmatch {lappend orpt '[sql <- $wDW]'}
				mysqlreceive $db "
					select page_title
					from page, categorylinks
					where cl_from = page_id and page_namespace in (0, 1) and page_title in ([join $orpt {, }]) and (cl_to like 'Wikipedia:Weblink_offline%' or cl_to like 'Wikipedia:Defekte_Weblinks%')
					order by page_title
				;" pt {
					set pt [sql -> $pt]
					if {[string first {Defekte Weblinks} [pagecat Diskussion:$pt]] > -1} {
						lappend wDWblock "\[\[:$pt\]\]<small> \[\[Diskussion:$pt|(Disk)\]\]</small>"
					} else {
						lappend wDWblock \[\[:$pt\]\]
					}
				}
				unset -nocomplain orpt
			}
			incr wcount [set wDWcount [llength [set wDWblock [lsort -unique $wDWblock]]]]
			set wDWblock [join $wDWblock "\n[expr {$listformat eq {SHORTLIST} ? {·} : {*}}] "]
			set wDWbranch ";\[\[Datei:Qsicon Weblink red.svg|30x15px|text-unten|Defekter Weblink|link=:Kategorie:Wikipedia:Defekte Weblinks\]\]&nbsp;Defekter Weblink<small> ([expr $wDWcount < 50 ? [tdot $wDWcount] : {{auf max. 50 Artikel beschränkt}}])</small>"
			if ![empty wDWblock] {
				append WORKLIST \n$wDWbranch\n[expr {$listformat eq {SHORTLIST} ? {} : $listformat eq {CLIST} ? {# } : {* }}]$wDWblock
			} elseif {({ALL} in $ALWAYSSHOW && {-DW} ni $ALWAYSSHOW) || {DW} in $ALWAYSSHOW} {
				append WORKLIST \n$wDWbranch\n$EMPTY
			}
		}
		return [string map {& {\&}} $WORKLIST]
	}
}

set portal	[lindex $argv 0 0]
set data		[lindex $argv 0 1]

#puts $portal
#puts $data


	set repeat 0
	while 1 {
		if {[catch {
			set summary {}
#			set portal {Portal:Berlin/Arbeitsliste}
#			set portal {Benutzer:Flominator/Freiburg}
#			set portal {Portal:Österreich/Baustellen}
#			set portal {Portal:Leichtathletik/Neue Artikel}
#			set portal {Portal:Tod/Verbesserungswürdige Artikel}
#			set portal {Benutzerin:TaxonBota/qstest}
#			set portal {Portal:Muntenien/Neue Artikel}
#			set portal {Wikipedia:Redaktion Religion/Wartung/Gesamtübersicht}
#			set data [dict get $e $portal]
			puts \n$portal:
#			puts $data
#			if {$portal ni $lwportal} {continue}
#			if {$portal ne {Portal:Bahn/Mitmachen/Löschkandidaten und QS}} {continue}
#			if {$portal ne {Benutzer:Bungert55/Wartungsseiten/Eifel} && !$aaaa} {continue} else {incr aaaa}
			if {$portal in {{Wikipedia:WikiProjekt Fußball/Kader-Navigationsleisten} {Wikipedia:WikiProjekt Eishockey/Kaderwartung}}} {continue}
			set oconts [conts t $portal x]
#			puts [edit user:TaxonBota/qstest1 test [string map {{\&} &} $oconts]]
			set nportal $oconts
			if {$data ne {x}} {
				set br 1
				if {$portal eq {Portal:Computerspiele/Neue Artikel}} {
					set lncportal [computerspiele $portal $nportal $data]
				} else {
					set lncportal [portals $portal $nportal $data]
				}
				if ![empty lncportal] {set lncportal \n$lncportal}
				set nportal [string map {{\&} &} [regsub -- {(<!--MB-NeueArtikel-->).*<!--MB-NeueArtikel-->} $nportal \\1$lncportal\n\\1]]
				set summary "Bot: NeueArtikel: [tdot $nacount]"
			}
#			if {$data ne {x} && $portal in $lqsportal} {
#set br 1
#				set QSWORKLIST [qsw $portal]
#				if {$listformat ne {TABLE}} {
#					set nportal [string map {{\&} &} [regsub -- {(<!--MB-QSWORKLIST-->).*<!--MB-QSWORKLIST-->} $nportal \\1$QSWORKLIST\n\\1]]
#					set summary "Bot: NeueArtikel: [tdot $nacount]; QSWORKLIST: [tdot $qscount]"
#				} else {
#					set summary "Bot: NeueArtikel: [tdot $nacount]"
#				}
#			} elseif {$data eq {x} &&} {
#set br 2
#				set QSWORKLIST [qsw $portal]
#				if {$listformat eq {TABLE}} {continue}
#				set nportal [string map {{\&} &} [regsub -- {(<!--MB-QSWORKLIST-->).*<!--MB-QSWORKLIST-->} $nportal \\1$QSWORKLIST\n\\1]]
#				set summary "Bot: QSWORKLIST: [tdot $qscount]"
#			} else {
#set br 3
#				set summary "Bot: NeueArtikel: [tdot $nacount]"
#			}

			if {$portal in $lqsportal} {
				set br 2
				set QSWORKLIST [qsw $portal]
#puts $WORKLIST
				if {$listformat ne {TABLE}} {
					set nportal [string map {{\&} &} [regsub -- {(<!--MB-QSWORKLIST-->).*<!--MB-QSWORKLIST-->} $nportal \\1$QSWORKLIST\n\\1]]
					if ![empty summary] {
						append summary "; QSWORKLIST: [tdot $qscount]"
					} else {
						set summary "Bot: QSWORKLIST: [tdot $qscount]"
					}
				}
			}

			if {$portal in $lwportal} {
				set br 3
				set WORKLIST [w $portal]
#puts $WORKLIST
				if {$listformat ne {TABLE}} {
					set nportal [string map {{\&} &} [regsub -- {(<!--MB-WORKLIST-->).*<!--MB-WORKLIST-->} $nportal \\1$WORKLIST\n\\1]]
					if ![empty summary] {
						append summary "; WORKLIST: [tdot $wcount]"
					} else {
						set summary "Bot: WORKLIST: [tdot $wcount]"
					}
				}
			}
#set WORKLIST [w $portal]
#puts $WORKLIST\n$wcount
#puts [edit user:TaxonBota/qstest1 test [string map {{\&} &} $WORKLIST]] ; exit


			if {$nportal ne $oconts} {
#puts [edit user:TaxonBota/qstest1 "$summary|\[\[$portal\]\]" $nportal / minor]
#if {$br != 3} {puts [edit user:TaxonBota/qstest "$summary|\[\[$portal\]\]" $nportal / minor] ; gets stdin}
				puts $br:[edit $portal $summary $nportal / minor]
#if {[incr xx] < 15} {gets stdin}
			}
		}] != 1} {
			break
		} else {
			if {[incr repeat] == 1} {
	         set lang test ; source langwiki.tcl ; #set token [login $wiki]
				puts [edid 63277 {Log: NeueArtikel} {} / appendtext "\n* '''[
					clock format [clock seconds] -format %Y-%m-%dT%TZ
				] NeueArtikel: Fehler in \[\[:w:de:$portal\]\]!'''"]
				set lang dea ; source langwiki.tcl ; #set token [login $wiki]
				if {$portal eq {Wikipedia:WikiProjekt Kategorien/Arbeitsliste}} {break}
			}
			if {$repeat == 10} {
	         set lang test ; source langwiki.tcl ; #set token [login $wiki]
				puts [edid 63277 {Log: NeueArtikel} {} / appendtext "\n* <span style=\"color:red\">'''[
					clock format [clock seconds] -format %Y-%m-%dT%TZ
				] NeueArtikel: Fehler in \[\[:w:de:$portal\]\]!'''</span>"]
				set lang dea ; source langwiki.tcl ; #set token [login $wiki]
				break
			}
		}
	}


#puts "\nend of task"
#set lang test ; source langwiki.tcl ; #set token [login $wiki]
#puts [edid 63277 {Log: MB4} {} / appendtext "\n* '''[clock format [clock seconds] -format %Y-%m-%dT%TZ] NeueArtikel4: Task finished!'''"]


