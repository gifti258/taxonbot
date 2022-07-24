#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

catch {if {[exec pgrep -cxu taxonbot wkatVS.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

puts [clock format [clock seconds] -format %T]

# Ignores und Exclude
set    ipt   [dcat sql Abkürzung 0]
append ipt  ,[dcat sql Begriffsklärung 0]
append ipt  ,[dcat sql Liste 0]
append ipt  ,[dcat sql Personenname 0]
append ipt  ,[dcat sql Wikipedia:Falschschreibung 0]
append ipt  ,[dcat sql Wikipedia:Liste 0]
append ipt	,[dcat sql Wikipedia:Liste_erstellt_mit_Wikidata 0]
append ipt  ,[dcat sql Wikipedia:Obsolete_Schreibung 0]
set exclude 'Liste',[dcat sql Liste 14],[dcat sql Personenname 14],'Abkürzung','Begriffsklärung','Wikipedia:Falschschreibung','Wikipedia:Liste','Wikipedia:Liste_erstellt_mit_Wikidata','Wikipedia:Obsolete_Schreibung'

if 0 {

set lpgid {}
mysqlreceive $db "
	select page_id
	from $db0.page e, $db0.pagelinks
	where pl_from = e.page_id and e.page_id not in (
		select page_id
		from $db0.page a, $db0.categorylinks b
		where b.cl_from = a.page_id and a.page_namespace = 0 and b.cl_to in ($exclude)
	) and e.page_namespace = 0 and e.page_is_redirect = 0 and pl_from_namespace = 0 and pl_namespace = 0 and page_title = 'Josef_Frenken' and pl_title not in (
		select page_title
		from $db0.page c, $db0.categorylinks d
		where d.cl_from = c.page_id and c.page_namespace = 0 and d.cl_to in ($exclude)
	)
	group by page_id
;" pgid {
	lappend lpgid |$pgid|
}
puts $lpgid
if {[string first |2932680| $lpgid] > -1} {puts Radlow}
if {[string first |3580756| $lpgid] > -1} {puts Amur-Fetthenne}
puts "[clock format [clock seconds] -format %T]:wVSkat komplett"

exit

	select page_title
	from page b
	where b.page_id not in (
		select page_id
		from page a, categorylinks
		where cl_from = a.page_id and a.page_namespace = 0 and cl_to in ($exclude)
	) and b.page_namespace = 0
;" pgid {
	lappend lpgid $pgid
}

puts [llength $lpgid]

mysqlreceive $db "
	select page_id
	from page
	where page_id in ($lpgid)
;" pgid {}


exit

mysqlreceive $db "
		select page_id, (
			select count((
				select page_id
				from page x
				where x.page_id = p.pl_from and x.page_id < 1000000 and x.page_namespace = 0 and x.page_is_redirect = 0
			))
			from pagelinks p
			where p.pl_title = a.page_title and a.page_namespace = 0 and p.pl_namespace = 0 and p.pl_from_namespace = 0
		) as pl_field
		from page a
		where a.page_namespace = 0 and a.page_is_redirect = 0
		having pl_field = 0
;" {pgid --} {puts $pgid ; lappend lpgid $pgid}
puts [llength $lpgid]




exit

}

set db [get_db dewiki]
mysqlreceive $db "
	select page_id from page, categorylinks
	where cl_from = page_id and !page_namespace and cl_to in ($exclude)
;" pid {
	lappend lpid $pid
}
mysqlclose $db

#	WHERE B.page_id NOT IN (
#		SELECT page_id
#		FROM page C, categorylinks D
#		WHERE D.cl_from = C.page_id AND page_namespace = 0 AND D.cl_to IN ($exclude)
# ) ...

set db [get_db dewiki]
set pl_row [mysqlsel $db "
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
;" -list]
mysqlclose $db

puts $pl_row
puts [llength $pl_row]



set db [get_db dewiki]
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
	WHERE B.page_id NOT IN ([join $lpid ,]) AND Z.cl_from = B.page_id
	ORDER BY B.page_title
;" {pt ct} {
	dict lappend wVSkat0 [sql -> $pt] Kategorie:[sql -> $ct]
	lappend 1 [sql -> $pt]
}
mysqlclose $db
set 1 [lsort -unique $1]
foreach 2 $1 {
	while 1 {
		try {
			set 3 [get [
				post $wiki {*}$query / list backlinks / bltitle $2 / blnamespace 0 / blfilterredir nonredirects / bllimit 2500 / blredirect
			] query backlinks]
		} on 0 {} {break}
	}
	if {[string first redirlinks $3] > -1} {
		set ltitle {}
		foreach 4 $3 {
			catch {
				foreach 5 [dict get $4 redirlinks] {
					set 6 [dict get $5 title]
					if {$6 ne $2 && $6 ni $ipt} {
						lappend ltitle $6
					}
				}
			}
		}
		if ![empty ltitle] {
			lappend 7 $2
		}
	}
}
foreach 8 $1 {
	if {$8 ni $7} {
		lappend 9 "# \[\[$8\]\]"
		lappend wVSkat1 $8
	}
}
set 9 [lsort -unique $9]
set count [llength $9]
set in {Als Ergänzung zu [[Spezial:Verwaiste Seiten]], die nur Seiten ganz ohne Verlinkung listet, werden auf dieser Seite alle ''verwaisten Artikel'' dargestellt:}
set upd "[clock format [clock seconds] -format {%Y-%m-%d %T} -timezone :Europe/Berlin] by \[\[Benutzerin:TaxonBota|TaxonBota\]\]"
puts [edid 9708855 "Bot: WORKLIST: [tdot $count] Einträge" "$in\n\nStand: $upd\n\n[join $9 \n]" / minor]
foreach {pt ct} $wVSkat0 {
	if {$pt in $wVSkat1} {lappend wVSkat $pt $ct}
}
puts "[clock format [clock seconds] -format %T]:wVSkat komplett"
unset -nocomplain lcat lcat1 exclpt lpt ltitle 1 2 3 4 5 6 7 8 9

lappend wkatVS wVSkat $wVSkat

set f [open WORKLIST/@wkatVS.db w] ; puts $f $wkatVS ; close $f







