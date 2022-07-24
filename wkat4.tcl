#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

catch {if {[exec pgrep -cxu taxonbot wkat1.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
while 1 {if [catch {set db [get_db dewiki]}] {after 60000 ; continue} else {break}}

puts [clock format [clock seconds] -format %T]
set lpt [set lcat 'Wikipedia:Defekte_Weblinks']
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
mysqlreceive $db "
	select page_title
	from page, categorylinks
	where cl_from = page_id and page_namespace in (0,1) and cl_to in ([join $lpt ,])
;" pt {
	lappend lpt1 '[sql <- $pt]'
}
mysqlreceive $db "
	select page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_namespace = 0 and page_title in ([join $lpt1 ,])
	order by page_title
;" {pt ct} {
	dict lappend wDWkat [sql -> $pt] Kategorie:[sql -> $ct]
}
puts "[clock format [clock seconds] -format %T]:wDWkat komplett"
unset -nocomplain lpt lcat1 lpt1

set exclude {'Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung'}
mysqlreceive $db "
	SELECT page_title, cl_to
	FROM (
		SELECT page_title, page_id, (
			SELECT COUNT((
				SELECT page_id
				FROM page X
				WHERE X.page_id = P.pl_from AND X.page_namespace = 0
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
		WHERE D.cl_from = C.page_id AND D.cl_to IN ($exclude)
	) AND Z.cl_from = B.page_id
	ORDER BY B.page_title
;" {pt ct} {
	dict lappend wVSkat [sql -> $pt] Kategorie:[sql -> $ct]
	lappend lpt "# \[\[[sql -> $pt]\]\]"
}
set lpt [lsort -unique $lpt]
set count [llength $lpt]
set in {Als Ergänzung zu [[Spezial:Verwaiste Seiten]], die nur Seiten ganz ohne Verlinkung listet, werden auf dieser Seite alle ''verwaisten Artikel'' dargestellt:}
set upd "[clock format [clock seconds] -format {%Y-%m-%d %T} -timezone :Europe/Berlin] by \[\[Benutzerin:TaxonBota|TaxonBota\]\]"
edid 9708855 "Bot: WORKLIST: $count" "$in\n\nStand: $upd\n\n[join $lpt \n]" / minor
puts "[clock format [clock seconds] -format %T]:wVSkat komplett"
unset -nocomplain lpt
#SOL
#select page_title from page b where b.page_namespace = 0 and b.page_is_redirect = 0 and b.page_id not in (select page_id from page c, categorylinks d WHERE d.cl_from = c.page_id AND d.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')) ORDER by b.page_title;

#;[[Datei:German-Language-Flag.svg|30x15px|text-unten|Internationalisierung|link=:Kategorie:Wikipedia:Deutschsprachig]]&nbsp;'''Internationalisierung''':

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
	where c.cl_from = b.page_id
	order by b.page_title
;" {pt ct} {
	dict lappend wINTkat [sql -> $pt] Kategorie:[sql -> $ct]
}
puts "[clock format [clock seconds] -format %T]:wINTkat komplett"
unset -nocomplain lpt lcat1

mysqlreceive $db "
	select page_title, cl_to
	from (
		select page_id, page_title
		from page, categorylinks a
		where a.cl_from = page_id and page_namespace = 0 and a.cl_to = 'Wikipedia:Widerspruch'
	) b, categorylinks c
	where c.cl_from = b.page_id
	order by b.page_title
;" {pt ct} {
	dict lappend wWkat [sql -> $pt] Kategorie:[sql -> $ct]
}
puts "[clock format [clock seconds] -format %T]:wWkat komplett"

mysqlreceive $db "
   select page_title
   from page, categorylinks
   where page_id = cl_from and page_namespace = 0 and cl_to like 'Wikipedia:Redundanz\_%'
   order by page_title
;" pt {
   lappend lpt $pt
}
foreach pt $lpt {
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
      lappend llparam $lparam
   } else {
      foreach param $reddict1 {
         lappend lparam [string trim $param]
      }
      lappend llparam $lparam
   }
}
foreach lparam $llparam {
   if {[string first { (CE} [lindex $lparam end]] > -1 && [lindex $lparam end-1] != 1} {set lparam [linsert $lparam end-1 1]}
   unset -nocomplain ltitle nltitle nlsqltitle
   lassign {} 3 4 5 6 7 8 9 10
   dict with lparam {
      lappend ltitle $3 $4 $5 $6 $7 $8 $9 $10
   }
   foreach title [lsort -unique $ltitle] {
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
   ;" ct {
      dict lappend dltitle cat Kategorie:[sql -> $ct]
   }
   lappend ldltitle $dltitle
}
foreach dltitle [lsort -unique $ldltitle] {
   dict with dltitle {
      lappend wRDkat $ltitle $cat
   }
}
puts "[clock format [clock seconds] -format %T]:wRDkat komplett"
unset -nocomplain lparam llparam nltitle nlsqltitle dltitle ldltitle ltitle

set lpt [set lcat 'Wikipedia:Veraltet']
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
dict lappend wAZkat [sql -> $pt] Kategorie:[sql -> $ct]
}
puts "[clock format [clock seconds] -format %T]:wAZkat komplett"
unset -nocomplain lpt lcat1

mysqlreceive $db "
select page_title, cl_to
from page c, templatelinks, categorylinks d
where tl_from = c.page_id and d.cl_from = c.page_id and c.page_namespace = 0 and tl_from_namespace = 0 and tl_namespace = 10 and tl_title in (
select page_title
from page a, categorylinks b
where b.cl_from = a.page_id and a.page_namespace = 10 and b.cl_to = 'Vorlage:Veraltet'
)
order by c.page_title
;" {pt ct} {
dict lappend wALTkat [sql -> $pt] Kategorie:[sql -> $ct]
}
puts "[clock format [clock seconds] -format %T]:wALTkat komplett"

lappend wkat1 wDWkat $wDWkat wVSkat $wVSkat wINTkat $wINTkat wWkat $wWkat wRDkat $wRDkat wAZkat $wAZkat wALTkat $wALTkat

set f [open WORKLIST/@wkat1.db w] ; puts $f $wkat1 ; close $f







