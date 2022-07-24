#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db dewiki]

set katalt [scat {IUCN-Schutzgebiet der Kategorie V} 0]
set katneu [scat {Schutzgebiet der IUCN-Kategorie V} 0]

puts $katalt
puts $katneu

set katall [lsort -unique "$katalt $katneu"]
puts $katall

foreach item $katall {
#	puts \n$item
	if {$item in $katalt && $item ni $katneu} {
		puts \n[incr i]:$item
		puts [edit $item {Bot: [[:Kategorie:IUCN-Schutzgebiet der Kategorie V]] → [[:Kategorie:Schutzgebiet der IUCN-Kategorie V]]} [regsub -- {\[\[Kategorie:IUCN-Schutzgebiet der Kategorie V.*?\]\]} [conts t $item x] "\[\[Kategorie:Schutzgebiet der IUCN-Kategorie V\]\]"] / minor]
	}
}
exit
		set nc [string map [list "\[\[Kategorie:IUCN-Schutzgebiet der Kategorie II\]\]\n" {} "\[\[Kategorie:IUCN-Schutzgebiet der Kategorie II\]\]" {}] [conts t $item x]]
		regsub -- {\[\[Kategorie:IUCN-Schutzgebiet der Kategorie II\|.*?\]\]\n} $nc {} nc
		puts [set change [edit $item {Kat: Doppelkategorisierung entfernt} $nc / minor]]
		if {[string first nochange $change] > -1} {lappend nochange $item}
		if {[incr zz] < 3} {gets stdin}
	}
}
puts nochange:$nochange

exit

mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title = 'Review'
;" pt {puts $pt}

exit

set a [dcat list Politiker 14]
set f [open apopo w] ; puts $f $a ; close $f

exit

lassign {} lllt nlllt lit
set gcat [set lcat 'Deutschland']
while {$lcat ne {}} {
	set lcat1 {}
	mysqlreceive $db "
		select page_title
		from page, categorylinks
		where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
	;" pt {
		set lcat {}
		lappend gcat '[sql <- $pt]'
		lappend lcat1 '[sql <- $pt]'
	}
	set lcat $lcat1
}
puts $gcat ; exit
mysqlreceive $db "
	select page_title, ll_lang, ll_title
	from page, langlinks, categorylinks
	where ll_from = page_id and cl_from = page_id and page_namespace = 0 and cl_to in ([join $gcat ,])
	order by page_title
;" {pt lll llt} {
	dict lappend lllt [sql <- $pt] [list $lll [sql <- $llt]]
}
foreach {pt llt} $lllt {
	lappend nlllt $pt [lsort -unique $llt]
}
foreach {pt llt} $nlllt {
	puts \n$pt:$llt
	set db [get_db dewiki]
	mysqlreceive $db "
		select il_to
		from imagelinks, page
		where page_id = il_from and page_title = '$pt' and page_namespace = 0
	;" it {
		lappend lit '[sql <- $it]'
	}
puts lit:$lit
	set pic 0
	if ![empty lit] {
		foreach dblang {de commons} {
			set db [get_db $dblang\wiki]
			mysqlreceive $db "
				select img_name, img_size
				from image
				where img_name in ([join $lit ,])
			;" {in is} {
				if {[string tolower [lindex [split $in .] end]] ni {gif png svg} && $is > 25000} {
					incr pic ; break
				} else {
					continue
				}
			}
		}
	}
	if $pic {puts 1} else {puts 0}
	set lit {}
	mysqlclose
#	gets stdin
}
exit
puts $lpt
set db [get_db commonswiki]

mysqlreceive $db "
select img_size, img_height, img_width
from image
where img_name in ([join $lpt ,])
;" {is ih iw} {
puts "$is $ih $iw"
}

exit



set tyear 2017 ; set tmonth 01

#set include {'Wikipedia:geplantes_Vorhaben_ohne_Zeitziel','Wikipedia:Laufendes_Ereignis','Wikipedia:Veraltet'}
set lpt [set lcat 'Wikipedia:Lagewunsch']
while {$lcat ne {}} {
set lcat1 {}
mysqlreceive $db "
select page_title
from page, categorylinks
where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
;" pt {
set lcat {}
lappend lpt '$pt'
lappend lcat1 '$pt'
}
set lcat $lcat1
}
mysqlreceive $db "
select page_title, cl_to
from (
select page_id, page_title
from page, categorylinks a
where a.cl_from = page_id and page_namespace = 0 and a.cl_to in ([join $lpt ,])
) b, categorylinks c
where c.cl_from = b.page_id
order by page_title
;" {pt ct} {
dict lappend wGEOkat [sql -> $pt] Kategorie:[sql -> $ct]
}
foreach wAZ [dict keys $wAZkat] {lappend orpt '[sql <- $wAZ]'}
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
puts \n$wAZpt:$wAZlct
if {{Kategorie:Wikipedia:Veraltet} in $wAZlct} {
lappend ldate 1
} else {
foreach wAZct $wAZlct {
regexp -- {Veraltet nach (.*)} $wAZct -- odate
if {[string first Jahr $odate] == -1} {
set sdate [clock format [clock scan "01 $odate" -format {%d %B %Y} -locale de] -format %Y-%m]
set ndate [clock format [clock add [clock scan $sdate\-01 -format %Y-%m-%d] 1 month] -format %Y-%m]
if {[clock scan $ndate\-01 -format %Y-%m-%d] <= [clock scan $tyear\-$tmonth\-01 -format %Y-%m-%d]} {lappend ldate $sdate}
} else {
set sdate [clock format [clock scan "01 01 $odate" -format {%d %m Jahr %Y}] -format %Y]
set ndate [clock format [clock add [clock scan $sdate\-01-01 -format %Y-%m-%d] 1 year] -format %Y]
if {[clock scan $ndate\-01-01 -format %Y-%m-%d] <= [clock scan $tyear\-01-01 -format %Y-%m-%d]} {lappend ldate $sdate}
}
}
}
puts $ldate
}



exit




		from page, categorylinks a
		where a.cl_from = page_id and page_namespace = 0 and a.cl_to in (
			select page_title
			from page, categorylinks 
	) b, categorylinks c
	where c.cl_from = b.page_id
	order by page_title
;" {pt ct} {
	dict lappend wAZkat [sql -> $pt] Kategorie:[sql -> $ct]
}
set z "[clock format [clock seconds] -format %T]: komplett"
#puts $wAZkat
puts $z

foreach wAZ [dict keys $wAZkat] {lappend orpt '[sql <- $wAZ]'}
set z1 "[clock format [clock seconds] -format %T]: komplett"

exit

mysqlreceive $db "
	select page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_namespace = 0 and page_title in ([join $orpt ,]) and ((cl_to like 'Wikipedia:Veraltet\_%' or cl_to in ($include)) and cl_to <> 'Wikipedia:Veraltete_Normdaten')
	order by page_title
;" {pt ct} {
	dict lappend wAZdict [sql -> $pt] Kategorie:[sql -> $ct]
}
set z2 "[clock format [clock seconds] -format %T]: komplett"

puts $wAZdict
foreach {wAZpt wAZlct} $wAZdict {
	puts \n$wAZpt
	set wAZly {}
	foreach wAZct $wAZlct {
		puts $wAZct
		if {[string first geplantes $wAZct] > -1} {lappend wAZly Plan}
		if {[string first Laufendes $wAZct] > -1} {lappend wAZly laufend}
		if {[string first zwei $wAZct] > -1} {lappend wAZly [clock format [clock add [clock seconds] 2 years] -format %Y]}
		if {[set wAZy [regexp -inline -- {\d{4}} $wAZct]] ne {}} {lappend wAZly $wAZy}
	}
	if ![empty wAZly] {lappend wAZblock "\[\[$wAZpt\]\]<small> ([join $wAZly { / }])</small>"} else {lappend wAZblock \[\[$wAZpt\]\]}
}

puts $wAZblock

puts $z1
puts $z2

exit

while 1 {

set litem1 [insource {S\. [1-9][0-9]*- [1-9]/} 0]
#puts $litem1

set litem2 [insource {S\. [1-9][0-9]* -[1-9]/} 0]
#puts $litem2

#set litem3 [insource {S\. [1-9][0-9]*-[1-9]/} 0]
#puts $litem3

set litem4 [lsort -unique [join [list $litem1 $litem2]]]
#puts $litem4

#&nbsp; hinter S. !ampersand

foreach item $litem4 {
#	if {$item in {Betsingmesse Gemeinschaftsmesse}} {continue}
	puts \n[edit $item {Bot: Korrektur Halbgeviertstrich} [regsub -all -- {(S\.(&nbsp;| )\d{1,20})( -|- )(\d{1,20})} [conts t $item x] \\1–\\4] / minor]
#	if {[incr i] < 6} {gets stdin}
}

}












exit


#set a {Alte_Sprache Altsprachlicher_Unterricht Assistenz_(Behindertenhilfe) Außenhandelspolitik Bahnstrecke_Mannheim–Saarbrücken Bahnstrom Balkentheorie Bandpassunterabtastung Bewältigungsstrategie Biegefestigkeit Biegemoment Biegezugfestigkeit Blitzsynchronisation Blitzsynchronzeit Buchenbach Central_Tejo_(Arbeitsverhältnisse) Central_Tejo_(Funktionsbeschreibung) Central_Tejo_(Geschichte) Conversion-Tracking Datenbankindex Desktop-Virtualisierung Deutsche_Vereinigung_für_Posen_und_Pommerellen Deutschtumsbund_zur_Wahrung_der_Minderheitenrechte Dichtung Digitale_Katastralmappe Dirigieren Doppelschneckenextruder Ehrbarkeit Elternverband Elternverein Engineering-Data-Management Ethisches_Investment Extruderschnecke Extrusion_(Verfahrenstechnik) Führungsinformationssystem_(Wirtschaft) Ghetto_Theresienstadt Gilgit_(Landschaft) Glukosesirup Groupware Grundstücksdatenbank Grüne_Route Handelspolitik Heißluftgebläse Holzextrusion Hypoidantrieb Indexstruktur Informant Invertierte_Datei Jahreserstlinge Juristische_Sekunde KZ_Theresienstadt Kasse Kegelrad-Achsgetriebe Kettenschluss Klassische_Sprache Kleine_Festung_Theresienstadt Koextrusion Komplexität_(Informatik) Komplexitätstheorie Konversion_(Marketing) Landau-Symbole Lieferbereitschaft Liste_der_olympischen_Medaillengewinner_aus_Argentinien Lutherbuche_(Altenstein) Management-Informationssystem Modus_Barbara Multicodalität Multimodalität Museu_da_Electricidade_(Lissabon) Olympische_Geschichte_Argentiniens Persönliche_Assistenz Poesie Produktdatenmanagement Rote_Armee Sabrina_Setlur Sampling_(Musik) Scandferries Scandlines Schneckenwelle Social_Investment Social_Investor Sowjetarmee Soziales_Netzwerk_(Soziologie) Soziales_Netzwerk_(Systemtheorie) Stressmanagement Unbuntaufbau Unterfarbenreduktion Virtual_Desktop_Infrastructure Virtueller_Projektraum Volksgrenadier Volksgrenadier-Division Volltextindexierung Volltextrecherche Vías_Verdes Wagensteige}

#foreach 1 $a {
#	puts $1
#	puts [regexp -inline -- {\{\{Redundanztext.*?\d{4}.*?\|(.*?)\}\}} [conts t $1 x]]
#}





mysqlreceive $db "
	select page_title
	from page, categorylinks
	where page_id = cl_from and page_namespace = 0 and cl_to like 'Wikipedia:Redundanz\_%'
	order by page_title
;" pt {
	lappend lpt $pt
}
foreach pt $lpt {
#	puts $pt
	set scont [split [string map [list \n {} \{\{ \n\{\{ \}\} \}\}\n] [conts t $pt x]] \n]
	foreach line $scont {
		if {[string first Redundanztext $line] > -1} {break}
	}
	set reddict1 [split [join [regsub -all {\[\[.*?\]\]} [string map [list \n {} style= {}] [dict values [
		regexp -inline -- {\{\{Redundanztext ??\| ?(\d.*?)\}\}} $line
	]]] ...]] |=]
	unset -nocomplain lparam i
	if {$reddict1 eq {}} {
		set reddict2 [split [join [regsub -all {\[\[.*?\]\]} [string map [list \n {} style= {}] [dict values [
			regexp -inline -- {\{\{Redundanztext ??\|(.*?)\}\}} $line
		]]] ...]] |=]
		foreach param $reddict2 {
			lappend lparam [incr i] [string trim $param]
		}
		puts r2:$lparam
		lappend llparam $lparam
	} else {
		foreach param $reddict1 {
			lappend lparam [string trim $param]
		}
		puts r1:$lparam
		lappend llparam $lparam
	}
}
foreach lparam $llparam {
#	puts $lparam
	if {[string first { (CE} [lindex $lparam end]] > -1 && [lindex $lparam end-1] != 1} {set lparam [linsert $lparam end-1 1]}
	unset -nocomplain ltitle nltitle nlsqltitle
	lassign {} 3 4 5 6 7 8 9 10
	dict with lparam {
		lappend ltitle $3 $4 $5 $6 $7 $8 $9 $10
	}
	foreach title $ltitle {
		if {$title ne {}} {
			lappend nltitle [sql -> $title]
			lappend nlsqltitle '[sql <- $title]'
		}
	}
	set dltitle [set nltitle "ltitle [list $nltitle] cat {}"]
	mysqlreceive $db "
		select cl_to
		from categorylinks, page
		where page_id = cl_from and page_title in ([join $nlsqltitle ,]) and page_namespace = 0
	;" {ct} {
		dict lappend dltitle cat Kategorie:[sql -> $ct]
	}
	puts $dltitle
}

exit

set lcat0 [set lcat 'Wikipedia:Staatslastig']
while {$lcat ne {}} {
   set lcat1 {}
   mysqlreceive $db "
      select page_title
      from page, categorylinks
      where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
   ;" pt {
      set lcat {}
      lappend lpt '[sql <- $pt]'
      lappend lcat1 '[sql <- $pt]'
   }
   set lcat $lcat1
}
set lcat [lappend lpt [join $lcat0]]
mysqlreceive $db "
   select page_title, cl_to
   from (
      select page_id, page_title
      from page, categorylinks a
      where a.cl_from = page_id and page_namespace = 0 and a.cl_to in ([join $lcat ,])
   ) b, categorylinks c
   where c.cl_from = page_id
   order by page_title
;" {pt ct} {
   dict lappend wINTkat [sql -> $pt] Kategorie:[sql -> $ct]
}


exit

set lconts [lrange [split [conts id 9708855 x] \n] 4 end]
for {set x 0} {$x < 10} {incr x} {
	lappend litem [lindex $lconts [expr round(rand() * [llength $lconts])]]
}
set in {Auf diese Seiten verweisen entweder nur Seiten aus anderen Namensräumen, Weiterleitungsseiten, Begriffsklärungsseiten und ähnliche und gelten damit noch als verwaist. Hilf bitte mit, die Mängel zu beheben:}
puts [edit WP:LKH {Bot: Verwaiste Seiten} {} / appendtext "\n\n== Verwaiste Seiten ==\n$in\n[join [lsort -unique $litem] \n]\n\n${~}" / minor true / redirect true]

exit



set lcat0 [set lcat 'Wikipedia:Staatslastig']
while {$lcat ne {}} {
   set lcat1 {}
   mysqlreceive $db "
      select page_title
      from page, categorylinks
      where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
   ;" pt {
      set lcat {}
      lappend lpt '[sql <- $pt]'
      lappend lcat1 '[sql <- $pt]'
   }
   set lcat $lcat1
}
set lcat [lappend lpt [join $lcat0]]
puts $lcat
mysqlreceive $db "
	select page_title, cl_to
	from (
		select page_id, page_title
		from page, categorylinks a
		where a.cl_from = page_id and page_namespace = 0 and a.cl_to in ([join $lcat ,])
	)b , categorylinks c
	where c.cl_from = page_id
	order by page_title
;" {pt ct} {
	dict lappend wINTkat $pt $ct
}
puts $wINTkat



puts [clock format [clock seconds] -format %T]




exit

#SOL
mysqlreceive $db "
	select page_id, page_title
	from page c
	where c.page_id not in (
		select page_id
		from page a, categorylinks b
		WHERE b.cl_from = a.page_id and b.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')
	) and c.page_namespace = 0 and c.page_is_redirect = 0
	order by page_title
;" {pgid pgt} {
	lappend lpgid $pgid
	lappend lpgt '[sql <- $pgt]'
}
lassign [list [lrange $lpgid 0 999999] [lrange $lpgid 1000000 end]] lpgid1 lpgid2
lassign [list [lrange $lpgt 0 999999] [lrange $lpgt 1000000 end]] lpgt1 lpgt2
	mysqlreceive $db "
		select page_id, count(pl_title)
		from page, pagelinks
		where pl_from = page_id and page_id in ([join $lpgid2 ,]) and page_namespace = 0 and pl_title in ([join $lpgt1 ,]) and pl_from_namespace = 0 and pl_namespace = 0
		group by page_id
		having count(pl_title) = 0
	;" {pgid plt} {
		puts $pgt:$plt
	}


#puts [llength $lpgid]
#puts [llength $lpgt]
puts [clock format [clock seconds] -format %T]


exit
mysqlreceive $db "
select page_id, page_title from (select page_id, page_title from page c where c.page_id not in (select page_id from page a, categorylinks b WHERE b.cl_from = a.page_id and b.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')) and c.page_namespace = 0 and c.page_is_redirect = 0) d, pagelinks where d.page_id = pl_from and pl_namespace = 0 and pl_from_namespace = 0 and (d.page_title = 'William_Hudson' or d.page_title = 'Zistrosengewächse') and pl_title in (select page_title from page g where g.page_id not in (select page_id from page e, categorylinks f WHERE f.cl_from = e.page_id and f.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')) and g.page_namespace = 0 and g.page_is_redirect = 0) group by page_id
;" {p t c} {puts $p:$t:$c}

exit

mysqlreceive $db "
SELECT page_title, cl_to
FROM (
   SELECT page_title, page_id, (
      SELECT COUNT((
         SELECT page_id
         FROM page X
         WHERE X.page_id = P.pl_from AND X.page_namespace = 0 AND X.page_is_redirect = 0
      ))
      FROM pagelinks P
      WHERE P.pl_title = A.page_title AND P.pl_namespace = 0 AND P.pl_from_namespace = 0
   ) AS pl_field
   FROM page A
   WHERE A.page_namespace = 0 AND A.page_is_redirect = 0
   HAVING pl_field = 0
) B, categorylinks Z
WHERE B.page_id NOT IN (
   SELECT page_id
   FROM page C, categorylinks D
   WHERE D.cl_from = C.page_id AND D.cl_to IN ('Abkürzung','Begriffsklärung','Wikipedia:Falschschreibung','Wikipedia:Obsolete_Schreibung')
) AND Z.cl_from = B.page_id
ORDER BY B.page_title
;" {pt ct} {dict lappend lpct $pt $ct}

puts $lpct
puts [llength $lpct]
puts [clock format [clock seconds] -format %T]
exit






mysqlreceive $db "select page_title from (select A.page_title, (select (SELECT page_id FROM page X WHERE X.page_id=P.pl_from and X.page_namespace=0 and X.page_is_redirect=0 LIMIT 1) from pagelinks P where P.pl_title=A.page_title and P.pl_namespace=0 and P.pl_from_namespace=0 limit 1) as pl_field from page A where A.page_namespace=0 and page_is_redirect=0 having pl_field IS NULL) B  ORDER BY B.page_title DESC;" pt {lappend lpt $pt}

puts $lpt
if {[string first !distain $lpt] > -1} {puts 1} else {puts 0}

exit

mysqlreceive $db "SELECT l.page_title FROM page l WHERE l.page_namespace = 0 AND l.page_is_redirect = 0 AND l.page_title NOT IN (       SELECT r.page_title       FROM page r, pagelinks       WHERE  r.page_id = pl_from AND r.page_namespace = 0 AND r.page_is_redirect = 0 AND pl_from_namespace = 0 AND pl_namespace = 0    )    ORDER BY l.page_title;" pt {puts $pt ; lappend lpt $pt}

puts $lpt
puts [llength $lpt]
puts [clock format [clock seconds] -format %T]
exit



mysqlreceive $db "
	SELECT DISTINCT l.page_title
	FROM page l
	WHERE NOT EXISTS (
   	SELECT r.page_title
     	FROM page r, pagelinks
      WHERE  r.page_title = l.page_title AND r.page_id = pl_from AND pl_title = l.page_title AND r.page_namespace = 0 AND r.page_is_redirect = 0 AND pl_from_namespace = 0 AND pl_namespace = 0
	) AND l.page_namespace = 0 AND l.page_is_redirect = 0
	ORDER BY l.page_title
;" pt {
	set pc [pagecat $pt]
	if {{Kategorie:Begriffsklärung} ni $pc && {Kategorie:Wikipedia:Falschschreibung} ni $pc && {Kategorie:Abkürzung} ni $pc && {Kategorie:Wikipedia:Obsolete Schreibung} ni $pc} {puts $pt ; lappend lpt $pt}
}
puts $lpt
puts [llength $lpt]
puts [clock format [clock seconds] -format %T]
exit




mysqlreceive $db "select l.page_title from page l where not exists (select r.page_title from page r, pagelinks where r.page_id = pl_from and pl_from_namespace = 0 and pl_namespace = 0 and r.page_namespace = 0 and r.page_is_redirect = 0 and r.page_id = l.page_id) and l.page_namespace = 0 and l.page_is_redirect = 0;" pt {puts $pt}




exit

mysqlreceive $db "select page_id, page_title from page, (select page_id as bkpage_id from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to <> 'Begriffsklärung') as bkpage where page.page_id = bkpage.bkpage_id and page.page_namespace = 0 and page.page_is_redirect = 0;" {pgid pt} {lappend slpt '[sql <- $pt]' ; lappend lpt $pt}
puts [llength $lpt]
puts [llength [set lpt [lsort -unique $lpt]]]
puts [llength [set slpt [lsort -unique $slpt]]]
puts [clock format [clock seconds] -format %T]

foreach {A B} {0 999999 1000000 end} {

	mysqlreceive $db "select distinct page_title from page, pagelinks, (select page_id as bkpage_id from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to <> 'Begriffsklärung') as bkpage where pl_from = page.page_id and bkpage.bkpage_id = page.page_id and page.page_namespace = 0 and pl_namespace = 0 and page.page_is_redirect = 0 and pl_title in ([join [lrange $slpt $A $B] ,]);" pt1 {lappend lpt1 $pt1}

puts [llength $lpt1]
puts [llength [set lpt1 [lsort -unique $lpt1]]]
puts [clock format [clock seconds] -format %T]


}

foreach pt $lpt1 {if {$pt ni $lpt} {lappend mpt $pt}
puts $mpt
puts [llength $mpt]
puts [clock format [clock seconds] -format %T]

exit
#select page_title, pl_title from page left join pagelinks on pl_from = page_id where page_namespace = 0 and pl_namespace = 0 and page_title not in ([join $lpt {, }])

mysqlreceive $db "select page_title from page where page_namespace = 0 and page_is_redirect = 0;" pt {lappend lpt $pt}
puts [llength $lpt]

mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to = 'Begriffsklärung';" pt {lappend lbks $pt}
puts [llength $lbks]

foreach bks $lbks {
	lremove lpt $bks
}
puts [llength $lpt]


#select page_title from pagelinks, page where page_id = pl_from and pl_namespace = 0 and page_namespace = 0 and page_is_redirect = 0;

exit

set lcat [list {cl_to = 'Wikipedia:Defekte_Weblinks'}]
while {$lcat ne {}} {
	set lcat1 {}
	mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and ([join $lcat { or }]) and page_namespace = 14;" pt {
		set lcat {}
		lappend lpt "cl_to = '$pt'"
		lappend lcat1 "cl_to = '$pt'"
	}
	set lcat $lcat1
}
mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and (page_namespace = 0 or page_namespace = 1) and ([join $lpt { or }]) order by page_title;" pt {
	lappend lpt1 $pt
}
foreach pt1 $lpt1 {
	mysqlreceive $db "select page_title, cl_to from page, categorylinks where cl_from = page_id and (page_namespace = 0 or page_namespace = 1) and page_title = '[string map {' \\'} $pt1]';" {pt ct} {
		dict lappend wDWkat [string map {_ { }} $pt] Kategorie:[string map {_ { }} $ct]
	}
}
set t1 [clock format [clock seconds] -format %T]
puts $wDWkat
puts [llength $wDWkat]
puts $t1

exit

mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and ([join $lpt { or }]) order by page_title;" pt {
	puts $pt
	lappend lpt2 "page_title = '$pt'"
	
#mysqlreceive $db "select page_title, cl_to from page, categorylinks where cl_from = page_id and (page_namespace = 0 or page_namespace = 0) and ([join $lpt { or }]) order by page_title;" {pt ct} {}
}
#puts $lpt
exit

mysqlreceive $db "select page_title from page, categorylinks where cl_from = page_id and page_namespace = 0 and cl_to = 'Mineral' order by page_title;" pt {
	lappend lpt $pt
}
foreach pt $lpt {
	if {$pt in {Graphit}} {continue}
	set c [conts t $pt x]
	set nc $c
	if {[string first \{\{Literatur\n $c] > -1} {
		puts \n$pt
		set lrx [regexp -all -inline -- {\{\{Literatur\n.*?\}\}} $c]
		foreach rx $lrx {
			set nrx {}
			if {[regexp -all -- {\{} $rx] > 2} {puts \a$rx\nerror ; exit}
#			puts $rx
			foreach line [split $rx \n] {
				regsub -- {(\||\| )} [string trim $line] { | } line
				append nrx $line
			}
#			puts $nrx
			set nc [string map [list $rx $nrx] $nc]
		}
#		puts $nc
		puts [edit $pt {Bot: Literaturvorlagen begradigt} $nc / minor]
		if {[incr i] < 5} {gets stdin}
	}
}

exit

set cl1 [clock format [clock seconds] -format %T]
set yr [clock format [clock seconds] -format %Y]
mysqlreceive $db "select page_title, cl_to from page, categorylinks where cl_from = page_id and page_namespace = 0 and (cl_to like 'Geboren%') order by page_title;" {pt ct} {
	dict lappend lpd $pt $ct
}
foreach {pt pd} $lpd {
	if {[llength $pd] == 1 && [string first Geboren $pd] > -1} {
		unset -nocomplain born
		regexp -- {\d{4}} $pd born
		catch {
			if {[expr $yr - $born] > 105} {
				lappend lpt "page_title = '$pt'"
			}
		}
	}
}
puts $lpt
mysqlreceive $db "select page_title, ll_lang, ll_title, cl_to from page left join langlinks on ll_from = page_id left join categorylinks on cl_from = page_id where page_namespace = 0 and ([join $lpt { or }]);" {pt lll llt ct} {
	dict lappend lwVVkat [string map {_ { }} $pt] [list $lll [string map {_ { }} $llt]]
	dict lappend cwVVkat [string map {_ { }} $pt] Kategorie:[string map {_ { }} $ct]
#	Kategorie:[string map {_ { }} $ct]
}
foreach {pt ll} $lwVVkat {lappend nlwVVkat $pt [join [lsort -unique $ll]]}
foreach {pt ct} $cwVVkat {lappend ncwVVkat $pt [lsort -unique $ct]}
set wVVkat [join [lmap pt [dict keys $nlwVVkat] ll [dict values $nlwVVkat] ct [dict values $ncwVVkat] {list [list $pt $ll] $ct}]]
set cl2 [clock format [clock seconds] -format %T]

puts $wVVkat
puts "$cl1 - $cl2"
exit

mysqlreceive $db "select page_title, cl_to from page, templatelinks, categorylinks where tl_from = page_id and page_namespace = 0 and tl_title = 'Personendaten' order by page_title;" {pt ct} {
#	puts [string map {_ { }} $pt]:[string map {_ { }} $ct]
}
puts [clock format [clock seconds] -format %T]
mysqlreceive $db "select page_title, cl_to from (select page_title, page_id from page, templatelinks where tl_from = page_id and page_namespace = 0 and tl_title = 'Personendaten') as page, categorylinks where cl_from = page_id order by page_title;" {pt ct} {
#	puts $pt:$ct
}
puts [clock format [clock seconds] -format %T]

exit

mysqlreceive $db "
	select page_title, page_is_redirect
	from page
	where page_namespace = 12
;" {pt pir} {
	puts $pt:$pir
#	if {$prt ne {}} {gets stdin}
}
#puts $l4

exit

set debug 1
set verbose 1
while 1 {
	if [catch {
		puts [clock format [clock seconds] -format %T]
		conts t {GP 1890} x
	}] {
		puts 502err:[incr i]
	}
}

exit

mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks, templatelinks where cl_from = page_id and tl_from = page_id and (tl_title = 'Portalhinweis' or tl_title = 'Projekthinweis' or tl_title = 'Redaktionshinweis') order by page_title;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend phkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts $phkat

exit

foreach ei {Portalhinweis Projekthinweis Redaktionshinweis} {lappend ph [template $ei p]}
foreach ph [lsort -unique [join $ph]] {
	lappend phkat $ph [pagecat $ph]
}
puts $phkat


exit

	mysqlreceive $db 	"
		select page_id
		from page
		where page_namespace = 0 and page_title = 'Mainz'
	;" pgid {
		lappend lkeyid "page_id = $pgid"
	}

puts $lkeyid

exit

source QSWORKLIST/@qsdict.db
foreach key [dict keys $qsdict] {
	lappend lkey "tl_title = '[string map {{ } _ {\'} {\'} {'} {\'}} $key]'"
}
mysqlreceive $db "select page_title, tl_title, cl_to from page, templatelinks, categorylinks where tl_from = page_id and cl_from = page_id and page_namespace = 0 and ([join $lkey { or }]) order by page_title;" {pt tl ct} {
	dict lappend lsnak [list $pt $tl] Kategorie:[string map {_ { }} $ct]
}
foreach {pttl lcat} $lsnak {
	lappend qskat [string map {_ { }} [lindex $pttl 0]] [list pagecat $lcat qstempl [set key [string map {_ { }} [lindex $pttl 1]]] qsshort [lindex [set val [dict get $qsdict $key]] 0] qslong [lindex $val 1]]
}
puts $qskat
puts [clock format [clock seconds] -format %T]

	
exit
	
	mysqlreceive $db "select page_id from page where page_namespace = 10 and page_title = '$key';" pgid {
		lappend lkeyid "page_id = $pgid"
	}
#	lappend lkeyid [join [mysqlsel $db "select page_id from page where page_namespace = 10 and page_title = '$key';" -list]]
}

puts $lkeyid
exit


foreach key [dict keys $qsdict] {lappend lqs [templids $key 0]}
set fi [clock format [clock seconds] -format %T]
puts $lqs
puts $fi
exit


foreach rvid [catids Wikipedia:Reviewprozess -kat] {lappend lrvid "page_id = $rvid"}
mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ([join $lrvid { or }]) order by page_title;" {pns pt ct} {
	if {[set pt [nssort -kat $pns $pt]] ne {}} {dict lappend rvkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts [clock format [clock seconds] -format %T]
puts $rvkat
puts [llength $rvkat]

exit

lassign [list [catitems Wikipedia:Kategorienlöschung 14] [catitems Wikipedia:Kategorienumbenennung 14] [catitems Wikipedia:Kategorienzusammenführung 14] [catitems {Wikipedia:Qualitätssicherung Kategorien} 14] [catitems Wikipedia:Kategorienklassifizierung 14]] kdla kdub kdzf kdqs kdkl
lappend kdkat kdla $kdla kdub $kdub kdzf $kdzf kdqs $kdqs kdkl $kdkl
puts $kdkat
puts [clock format [clock seconds] -format %T]
exit


lassign [list [cat {Kategorie:Wikipedia:Kategorienlöschung} 14] [cat {Kategorie:Wikipedia:Kategorienumbenennung} 14] [cat {Kategorie:Wik
ipedia:Kategorienzusammenführung} 14] [cat {Kategorie:Wikipedia:Qualitätssicherung Kategorien} 14] [cat {Kategorie:Wikipedia:Kategorienk
lassifizierung} 14]] kdla kdub kdzf kdqs kdkl



foreach lkid [join "[catids Wikipedia:Löschkandidat -kat] [catids {Wikipedia:Löschkandidat/Benutzer- und Metaseiten} -kat] [catids Wikipedia:Löschkandidat/Vorlagen -kat] [catids {Wikipedia:Löschkandidat Bahn} -kat]"] {lappend llkid "page_id = $lkid"}
mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ([join $llkid { or }]) order by page_title;" {pns pt ct} {
   if {[set pt [nssort -kat $pns $pt]] ne {}} {dict lappend lkkat $pt Kategorie:[string map {_ { }} $ct]}
}
puts "[clock format [clock seconds] -format %T]:lkkat komplett"
puts $lkkat
puts [llength $lkkat]




exit

foreach pgid [catids Wikipedia:Überarbeiten p] {lappend lnpgid "page_id = $pgid"}
#set lnpgid [join $lnpgid { or }]
mysqlreceive $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ([join $lnpgid { or }]) order by page_title;" {pns pt ct} {
	if {[set pt [nssort p $pns $pt]] ne {}} {dict lappend lwUE $pt Kategorie:[string map {_ { }} $ct]}
}
puts $lwUE


exit

mysqlreceive $db "select  page_id from page, categorylinks where cl_from = page_id and cl_to = 'Wikipedia:Überarbeiten';" pgid {lappend lpid "page_id = $pgid"} ; set lpid [join $lpid { or }]
mysqlsel $db "select page_namespace, page_title, cl_to from page, categorylinks where cl_from = page_id and ($lpid);" -list




exit

puts [clock format [clock seconds] -format %T]
set hidden [join [mysqlsel $db "select page_title from page, categorylinks where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt';" -list]]
mysqlreceive $db "select page_id, cl_to from page left join categorylinks on cl_from = page_id where page_namespace = 0 and page_is_redirect = 0 order by page_title;" {pt cl} {
	if {$cl in $hidden} {set cl {}}
	dict lappend lwKAT $pt $cl
}
puts [clock format [clock seconds] -format %T]
foreach {pt cl} $lwKAT {
	foreach item $cl {
		if {$item eq {}} {lremove cl $item}
	}
	if {$cl eq {}} {lappend nlwKAT $pt}
}
unset hidden lwKAT
puts $nlwKAT
foreach item $nlwKAT {
	puts $item
	set lcat {}
	set conts [conts id $item 0]
	set lwlink [dict values [regexp -all -inline -- {\[\[(.*?)[|#\]]} $conts]]
	foreach wlink [lsort -unique $lwlink] {
		puts $wlink
		if [catch {if ![ns $wlink] {lappend lcat [pagecat $wlink]}}] {continue}
	}
	set lcat [lsort -unique [join $lcat]]
	set pt [string map {_ { }} [mysqlsel $db "select page_title from page where page_id = $item;" -list]]
	lappend wKATkat $pt $lcat
}
puts $wKATkat
exit

set allpageswc [lsort -unique $allpageswc]
foreach pt $allpages {
	puts [incr i]
	if {$pt in $allpageswc} {continue} else {lappend allpageswoc $pt}
}
puts [llength $allpages]
puts [llength $allpageswc]
puts [llength $allpageswoc]
#puts [llength $lwKAT]
puts [clock format [clock seconds] -format %T]

gets stdin

puts $allpageswoc

exit

foreach {pgid pgt} $lpg {
	lappend nlpg $pgt [pagecat $pgt]
}



exit

mysqlreceive $db "select page_title from page, categorylinks where page_namespace = 0 and page_id = 936587;" pt {
#	puts $pt
#   if {$cl in $hidden} {set cl {}}
#   dict lappend lwKAT $pt $cl
	puts $pt
}
puts $lwKAT

exit

set hidden [join [mysqlsel $db "select page_title from page, categorylinks where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt';" -list]]
mysqlreceive $db "select page_title, cl_to from page, categorylinks where page_namespace = 0 and cl_from = page_id;" {pt cl} {
   if {$cl in $hidden} {set cl {}}
   dict lappend lwKAT $pt $cl
}
foreach {pt cl} $lwKAT {
   foreach item $cl {
      if {$item eq {}} {
         lremove cl $item
      }
   }
   if {$cl eq {}} {
      lappend nlwKAT [string map {_ { }} $pt]
   }
}
puts [lsort -unique $nlwKAT]

foreach page [lsort -unique $nlwKAT] {
	set conts [conts t $page 0]
	puts $conts
	gets stdin
}





exit

set hidden [join [mysqlsel $db "select page_title from page, categorylinks where page_namespace = 14 and cl_from = page_id and cl_to = 'Kategorie:Versteckt';" -list]]

mysqlreceive $db "select page_title, cl_to from page, categorylinks where page_namespace = 0 and cl_from = page_id;" {p c} {
	if {$c in $hidden} {set c {}}
	dict lappend b $p $c
}

#puts [lsort $b]

foreach {p c} $b {
	foreach item $c {
		if {$item eq {}} {
			lremove c $item
		}
	}
	if {$c eq {}} {
		puts [string map {_ { }} $p]
	}
}

exit

foreach {p c} $d {
	if {$c eq {}} {
		puts [string map {_ { }} $p]
	}
}


#puts [edit user:TaxonBota/Test1 test [lrange $d 1266 1367]]

#foreach {1 2} $b {
#	if {[string first Datei:\{ $1] > -1} {
#		puts $1:$2
#	}
#}

exit

puts [mysqlreceive $db "select page_title, cl_to from page, categorylinks where page_namespace = 0 and cl_from = page_id" -list]


exit

set db [get_db enwiki]
set db [get_db tools s51837__MerlBot]

set catlemma {Animated film stubs}
set catns 14
set lcat14 [format {{%s}} $catlemma]
lassign {0 1} olenlcat14 lenlcat14
while {$lenlcat14 != $olenlcat14} {
#	if {$lenlcat14 == $olenlcat14} {break}
	set olenlcat14 $lenlcat14
	set lcat14 [split $lcat14]
	foreach cat14 [join $lcat14] {lappend lcat14 [sqlcat $cat14 14]}
	set lcat14 [lsort -unique [join $lcat14]]
	set lenlcat14 [llength $lcat14]
}
#lremove lcat14 $catlemma
foreach cat14 $lcat14 {lappend lcat [sqlcat $cat14 $catns]}
puts [lsort -unique [join $lcat]]:[llength [lsort -unique [join $lcat]]]

exit

#set revc [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_title = \"[join $src _]\" and page_namespace = 0" -list]

#puts [mysqlsel $db "select page_title from page, categorylinks where page_id = cl_from and cl_type = 'subcat' and cl_to = 'Mineralogie';" -list]

#puts [mysqlsel $db "select * from page where page_title = 'ABC';;" -list]

set data [mysqlsel $db "select page_title from page, categorylinks where page_id = cl_from and cl_to = 'Stage_actors' and page_namespace = 14 ;" -list]
puts $data\n[llength $data]


