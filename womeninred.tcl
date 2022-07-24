#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang meta ; source langwiki.tcl ; #set token [login $wiki]

set langconts [conts t {List of Wikipedias/Table} x]
set llang [dict values [regexp -all -inline -- {\| \[\[\:(.*?)\:\|} $langconts]]
foreach lan $llang {
	lappend lw [string map {- _} $lan]wiki
}
set lang d ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db wikidatawiki]
mysqlreceive $db "
	select ips_item_id, ips_site_id, ips_site_page
	from (
		select ips_item_id iii
		from (
			select ips_item_id
			from wb_items_per_site a, page b, pagelinks c
			where a.ips_item_id = (
				select trim(leading 'Q' from b.page_title)
			) and c.pl_from = b.page_id and b.page_namespace = 0 and c.pl_from_namespace = 0 and c.pl_namespace = 0 and c.pl_title = 'Q5'
			group by ips_item_id
		) d, page e, pagelinks f
		where d.ips_item_id = (
			select trim(leading 'Q' from e.page_title)
		) and f.pl_from = e.page_id and e.page_namespace = 0 and f.pl_from_namespace = 0 and f.pl_namespace = 0 and f.pl_title = 'Q6581072'
	) g, wb_items_per_site h
	where g.iii = h.ips_item_id and h.ips_item_id not in (
		select ips_item_id
		from wb_items_per_site i
		where ips_site_id = 'dewiki'
	)
	order by h.ips_item_id
;" {iii isi isp} {
	if {[string first : $isp] == -1 && $iii ni {830183 15978631}} {
		dict lappend ls $iii [list $isi $isp]
	}
}
mysqlclose $db
set lisp {}
foreach {iii is} $ls {
	set dis [join $is]
	foreach lan $lw {
		catch {lappend lisp [dict get $dis $lan]}
	}
	if {$lisp ne {}} {
		lappend nls $iii $lisp
	}
	set lisp {}
}
foreach {iii lisp} $nls {lappend nnls $iii [llength $lisp] [lindex $lisp 0]}
set nnls [lsort -stride 3 -index 1 -integer -decreasing $nnls]
foreach {iii ll isp} $nnls {
	if {$ll >= 15} {
		lassign {} lp106 lttp106
		catch {
			foreach p106 [get [post $wiki {*}$format / action wbgetclaims / entity Q$iii] claims P106] {
				lappend lp106 [string trimleft [dict get $p106 mainsnak datavalue value id] Q]
			}
		}
		if ![empty lp106] {
			set db [get_db wikidatawiki]
			mysqlreceive $db "
				select term_text
				from wb_terms
				where term_entity_id in ([join $lp106 ,]) and term_language = 'de' and term_type = 'label'
			;" tt {
				if {$tt ne {FIPS 10-4 (Länder und Unterteilungen weltweit)}} {
					switch $tt {
						 Adult-Video-Idol			{lappend lttp106 [sql -> $tt]}
						 Anthropologe				{lappend lttp106 Anthropologin}
						 Arzt							{lappend lttp106 Ärztin}
						 Bogenschütze				{lappend lttp106 Bogenschützin}
						 Club-DJ						{lappend lttp106 [sql -> $tt]}
						{freier Mitarbeiter}		{lappend lttp106 {freie Mitarbeiterin}}
						 Fotomodell					{lappend lttp106 [sql -> $tt]}
						 Geschäftsperson			{lappend lttp106 Geschäftsfrau}
						 Glamourmodell				{lappend lttp106 [sql -> $tt]}
						 Gynäkologe					{lappend lttp106 Gynäkologin}
						{Herr der Gesellschaft}	{lappend lttp106 {Dame der Gesellschaft}}
						 Impresario					{lappend lttp106 Impresaria}
						 Internetpersönlichkeit	{lappend lttp106 [sql -> $tt]}
						{japanisches Idol}		{lappend lttp106 [sql -> $tt]}
						 Judoka						{lappend lttp106 [sql -> $tt]}
						 Magd							{lappend lttp106 [sql -> $tt]}
						 Menschenfreund			{lappend lttp106 Philanthropin}
						 Model						{lappend lttp106 [sql -> $tt]}
						 Musikpädagoge				{lappend lttp106 Musikpädagogin}
						 Nonne						{lappend lttp106 [sql -> $tt]}
						 Pädagoge					{lappend lttp106 Pädagogin}
						 Pharmakologe				{lappend lttp106 Pharmakologin}
						 Philologe					{lappend lttp106 Philologin}
						 Playmate					{lappend lttp106 [sql -> $tt]}
						 Prinz						{lappend lttp106 Prinzessin}
						 Psychologe					{lappend lttp106 Psychologin}
						{Queen Consort}			{lappend lttp106 [sql -> $tt]}
						 Rechtsanwalt				{lappend lttp106 Rechtsanwältin}
						 Romancier					{lappend lttp106 Romanschriftstellerin}
						 Scharfschütze				{lappend lttp106 Scharfschützin}
						 Seiyū						{lappend lttp106 [sql -> $tt]}
						 Soziologe					{lappend lttp106 Soziologin}
						 Sportschütze				{lappend lttp106 Sportschützin}
						 Tarento						{lappend lttp106 [sql -> $tt]}
						 Wrestling-Profi			{lappend lttp106 [sql -> $tt]}
						default						{lappend lttp106 [sql -> $tt]in}
					}
				}
			}
			mysqlclose $db
		}
		set ltt {}
		set db [get_db wikidatawiki]
		mysqlreceive $db "
			select term_text
			from wb_terms
			where term_entity_id = $iii and term_language in ('de','en','fr') and term_type = 'label'
			order by term_language
		;" tt {
			lappend ltt $tt
		}
		mysqlclose $db
		if ![empty ltt] {set isp [lindex $ltt 0]}
		set isp [string trim [regsub -all -- {\(.*?\)} $isp {}]]
		set tr "! $ll\n| \[\[:d:Q$iii|<span style = \"color: #CC0000;\">$isp</span>\]\]"
		if ![empty lttp106] {append tr "<small> ([join [lsort -unique $lttp106] {, }])</small>"}
		lappend ltb $tr
	}
}
set lang dea ; source langwiki.tcl ; #set token [login $wiki]
set ntab "Botstart -->\n[join $ltb \n|-\n]\n<!-- Botstop"
set page {Wikipedia:WikiProjekt Frauen/Frauen in Rot}
set conts [conts t $page x]
regexp -- {Botstart -->.*?<!-- Botstop} $conts otab
set nconts [string map [list $otab $ntab] $conts]
set ndate [clock format [clock seconds] -format {%d. %B %Y} -timezone :Europe/Berlin -locale de]
regexp -line -- {Botdatum.*?$} $conts odate
set nconts [string map [list $odate "Botdatum -->$ndate"] $nconts]
puts $nconts ; gets stdin
puts [edit $page {Bot: FehlendeArtikel} $nconts / minor]
