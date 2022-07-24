#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

catch {if {[exec pgrep -cxu taxonbot wkat1.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

puts [clock format [clock seconds] -format %T]

set db [get_db dewiki]
mysqlreceive $db "
	select page_title
	from page, categorylinks
	where cl_from = page_id and page_namespace in (0,1) and cl_to like 'Wikipedia:Defekte_Weblinks/Bot%'
;" pt {
	lappend lpt1 '[sql <- $pt]'
}
mysqlclose $db
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, cl_to
	from page, categorylinks
	where cl_from = page_id and page_namespace = 0 and page_title in ([join $lpt1 ,])
	order by page_title
;" {pt ct} {
	dict lappend wDWkat [sql -> $pt] Kategorie:[sql -> $ct]
}
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wDWkat komplett"
unset -nocomplain lpt1

#SOL
#select page_title from page b where b.page_namespace = 0 and b.page_is_redirect = 0 and b.page_id not in (select page_id from page c, categorylinks d WHERE d.cl_from = c.page_id AND d.cl_to IN ('Abkürzung', 'Begriffsklärung', 'Wikipedia:Falschschreibung', 'Wikipedia:Obsolete_Schreibung')) ORDER by b.page_title;

#;[[Datei:German-Language-Flag.svg|30x15px|text-unten|Internationalisierung|link=:Kategorie:Wikipedia:Deutschsprachig]]&nbsp;'''Internationalisierung''':

set lcat0 [set lcat 'Wikipedia:Staatslastig']
while {$lcat ne {}} {
	set lcat1 {}
	set db [get_db dewiki]
	mysqlreceive $db "
		select page_title
		from page, categorylinks
		where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
	;" pt {
		set lcat {}
		lappend lpt '[sql <- $pt]'
		lappend lcat1 '[sql <- $pt]'
	}
	mysqlclose $db
	set lcat $lcat1
}
set lcat [lappend lpt [join $lcat0]]
set db [get_db dewiki]
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
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wINTkat komplett"
unset -nocomplain lpt lcat1

set db [get_db dewiki]
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
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wWkat komplett"

set db [get_db dewiki]
mysqlreceive $db "
   select page_title
   from page, categorylinks
   where page_id = cl_from and page_namespace = 0 and cl_to like 'Wikipedia:Redundanz\_%'
   order by page_title
;" pt {
   lappend lpt $pt
}
mysqlclose $db
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
	catch {
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
		set db [get_db dewiki]
		mysqlreceive $db "
			select cl_to
			from categorylinks, page
			where page_id = cl_from and page_title in ([join $nlsqltitle ,]) and page_namespace = 0
		;" ct {
			dict lappend dltitle cat Kategorie:[sql -> $ct]
		}
		mysqlclose $db
		lappend ldltitle $dltitle
	}
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
	set db [get_db dewiki]
	mysqlreceive $db "
		select page_title
		from page, categorylinks
		where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
	;" pt {
		set lcat {}
		lappend lpt '$pt'
		lappend lcat1 '$pt'
	}
	mysqlclose $db
	set lcat $lcat1
}
set db [get_db dewiki]
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
mysqlclose $db
puts "[clock format [clock seconds] -format %T]:wAZkat komplett"
unset -nocomplain lpt lcat1

lappend wkat1 wDWkat $wDWkat wINTkat $wINTkat wWkat $wWkat wRDkat $wRDkat wAZkat $wAZkat

set f [open WORKLIST/@wkat1.db w] ; puts $f $wkat1 ; close $f







