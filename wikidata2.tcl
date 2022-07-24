#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

set editafter 1

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]

foreach {a b} [lsort -stride 2 -index 0 [read [set f [open tennis0.db r]]]] {
	puts $b
}

exit

if 0 {

append label  {en {Ekaterina Makarova}}
append label { de {Jekaterina Makarowa}}

append desc   {en {Russian tennis player1}}
append desc  { de {russische Tennisspielerin}}

append alias  {en {}}
append alias { de {}}

set q [string trimleft [dict get [wbedit new $label $desc {}] entity id] Q]
puts $q

}

set q Q56192280

#wb_add_claim $q P31	Q5
#wb_add_claim $q P21	Q6581072
#wb_add_claim $q P106	Q10833314 {P248 Q14580067}

#wbadd -- -id $q P106 Q10833314 dewiki

#d_edit_entity $q P106 Q10833314

#d_edit_entity $q {P248 Q14580067}

puts [d_get_guid $q P31 Q5]
set data {{"claims":[{"id":"Q56192280$F9812F1A-8CD1-40C0-BD1C-E5C33A0522F1","type":"claim","mainsnak":{"snaktype":"value","property":"P31","datavalue":{"value":{"entity-type":"item","id":"Q5"},"type":"wikibase-entityid"},"datatype":"wikibase-item"},"type":"statement","rank":"normal","references":[{"snaks":{"P248":[{"snaktype":"value","property":"P248","datavalue":{"value":{"entity-type":"item","id":"Q14580067"},"type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P248"]}]}]}}
puts [get [post $wiki {*}$token {*}$format / action wbeditentity / id Q56192280 / data $data / bot 1]]


exit

qualifiers:
set data {{"claims":[{"mainsnak":{"snaktype":"value","property":"P106","datavalue":{"value":{"entity-type":"item","id":"Q10833314"},"type":"wikibase-entityid"},"datatype":"wikibase-item"},"type":"statement","rank":"normal","qualifiers":{"P123":[{"snaktype":"value","property":"P123","datavalue":{"value":{"entity-type":"item","id":"Q761469"},"type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"qualifiers-order":["P123"]}]}}

references:
set data {{"claims":[{"mainsnak":{"snaktype":"value","property":"P106","datavalue":{"value":{"entity-type":"item","id":"Q10833314"},"type":"wikibase-entityid"},"datatype":"wikibase-item"},"type":"statement","rank":"normal","references":[{"snaks":{"P248":[{"snaktype":"value","property":"P248","datavalue":{"value":{"entity-type":"item","id":"Q14580067"},"type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P248"]}]}]}}

#set data {{"claims":[{"mainsnak":{"snaktype":"value","property":"P106","datavalue":{"value":{"entity-type":"item","numeric-id":10833314,"id":"Q10833314"},"type":"wikibase-entityid"},"datatype":"wikibase-item"},"type":"statement","rank":"normal","references":[{"snaktype":"value","property":"P248","datavalue":{"value":{"entity-type":"item","numeric-id":14580067,"id":"Q14580067"},"type":"wikibase-entityid"},"datatype":"wikibase-item"}]}]}}

#set ref [format {"references":[{"snaks":{"%s":[{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s,"id":"Q%s"},"type":"wikibase-entityid"},"datatype":"%s"}]},"snaks-order":["%s"]}]} $refprop $refprop $refq $refq [proptype $refprop] $refprop]



puts "/ $data /"

puts [get [post $wiki {*}$token {*}$format / action wbeditentity / id Q56192280 / data $data / bot 1]]

exit



set en_label {Ekaterina Makarova}
set de_label {Jekaterina Makarowa}

set en_desc {Russian tennis player}
set de_desc {russische Tennisspielerin}

set en_alias {}
set de_alias {}

set entity [wbedit new {en de} [list $en_label $de_label] [list $en_desc $de_desc] [list $en_alias $de_alias]]






exit

package require http ; package require tls ; package require tdom

set lq [d_query {
select distinct ?profession ?professionLabel where {
   values ?pro {wd:Q28640 wd:Q12737077}
   ?profession wdt:P31 ?pro.
   optional {?profession wdt:P2521 ?female_form_of_label. filter(lang(?female_form_of_label) = 'de')}
   filter(!bound(?female_form_of_label)).
   service wikibase:label {bd:serviceParam wikibase:language "de,[AUTO_LANGUAGE]".}
   }
   order by ?profession ?professionLabel
}]
foreach q $lq {
	puts $q
	puts [set label [wb_get_label  $q de]]
	puts [wb_get_desc   $q de]
	puts [set lalias [wb_get_lalias $q de]]
	foreach v [wb_get_lv $q P2521] {puts [dict get $v language]:[dict get $v text]}
	input in "-in? "
	switch $in {
		1 {wb_set_claim_monolang $q P2521 [wb_get_label $q de]in de
		  }
		2 {wb_add_alias $q [wb_get_label $q de]in de
		  }
		3 {wb_set_claim_monolang $q P2521 [wb_get_label $q de]in de
		   wb_add_alias $q [wb_get_label $q de]in de
		  }
		4 {input alias "alias? "
		   	if {$alias eq {x}} {
		   		wb_set_claim_monolang $q P2521 $label de
		   	} else {
			   	wb_set_claim_monolang $q P2521 [lindex $lalias $alias] de
				}
		  }
		default {}
	}
	puts ----
}

exit
set item 30499582
set prop P159
set q 14845
set ref dewiki

switch $ref {
	dewiki	{lassign {P143 48183} refprop refq}
}

set ref [format {"references":[{"snaks":{"%s":[{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s,"id":"Q%s"},"type":"wikibase-entityid"},"datatype":"%s"}]},"snaks-order":["%s"]}]} $refprop $refprop $refq $refq [proptype $refprop] $refprop]

set wbadd [format {"id":"Q%s","type":"statement","mainsnak":{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s,"id":"Q%s"},"type":"wikibase-entityid"},"datatype":"%s"}} [guid $item] $prop $q $q [proptype $prop]]

puts \{$wbadd,$ref\}

puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{%s,%s}} $wbadd $ref] / bot]]

exit


puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{"id":"Q%s","type":"statement","mainsnak":{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s,"id":"Q%s"},"type":"wikibase-entityid"},"datatype":"%s"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":{"entity-type":"item","numeric-id":48183,"id":"Q48183"},"type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}} [guid $item] $prop $q $q [proptype $prop]] / bot]]

exit

puts [wbeditentity $item {en {MHK Group}} {de {deutsches Dienstleistungsunternehmen für den mittelständischen Küchen-, Möbel- und Sanitärfachhandel} en {German service company for the medium-sized kitchen, furniture and sanitary trade}}]

exit

puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{"id":"Q%s","type":"statement","mainsnak":{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s,"id":"Q%s"},"type":"wikibase-entityid"},"datatype":"%s"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":{"entity-type":"item","numeric-id":48183,"id":"Q48183"},"type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}} [guid $item] $prop $q $q [proptype $prop]] / bot]]




#puts [get [post $wiki {*}$format {*}$token / action wbgetentities / ids $qitem] entities $qitem datatype]

exit

lassign {Q18209541 18209541} qitem item

set val 657167


exit

		puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim {{"id":"q18209541$13572468-2468-1357-eca9-bdf024681357","type":"statement","mainsnak":{"snaktype":"value","property":"P69","datavalue":{"value":{"entity-type":"item","numeric-id":569460,"id":"Q569460"},"datatype":"wikibase-entityid"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":"Q48183","type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}}}]]

exit

		puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{"id":"q18209541$13572468-2468-1357-eca9-bdf024681357","type":"statement","mainsnak":{"snaktype":"value","property":"P69","datavalue":{"value":"%s","type":"string"},"datatype":"commonsMedia"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":"Q48183","type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}} $ppv $clink] / bot]]


exit


#		puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim {{"id":"q18209541$13572468-2468-1357-eca9-bdf024681357","type":"statement","mainsnak":{"snaktype":"value","property":"P69","datavalue":{"value":"string","type":"string"},"datatype":"item"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":"Q48183","type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}}]]


{
	mainsnak {
		snaktype value property P69 datavalue {
			value {
				entity-type item numeric-id 1413500 id Q1413500
			} type wikibase-entityid
		} datatype wikibase-item
	} type statement qualifiers {
		P580 {
			{
				snaktype value property P580 hash 807228be43ecce85eae04af992ca74ee377fd749 datavalue {
					value {
						time +1991-00-00T00:00:00Z timezone 0 before 0 after 0 precision 9 calendarmodel http://www.wikidata.org/entity/Q1985727
					} type time
				} datatype time
			}
		}
	} qualifiers-order P580 id {
		Q18209541$b9c3b991-4279-2bb3-59f5-de5172bf7086
	} rank normal references {
		{
			hash 9a24f7c0208b05d6be97077d855671d1dfdbc0dd snaks {
				P143 {
					{
						snaktype value property P143 datavalue {
							value {
								entity-type item numeric-id 48183 id Q48183
							} type wikibase-entityid
						} datatype wikibase-item
					}
				}
			} snaks-order P143
		}
	}
} {
	mainsnak {
		snaktype value property P69 datavalue {
			value {
				entity-type item numeric-id 503246 id Q503246
			} type wikibase-entityid
		} datatype wikibase-item
	} type statement qualifiers {
		P580 {
			{
				snaktype value property P580 hash 6e9dc009e5d21d486b74950c06e04ee0f6c05b81 datavalue {
					value {
						time +1984-00-00T00:00:00Z timezone 0 before 0 after 0 precision 9 calendarmodel http://www.wikidata.org/entity/Q1985727
					} type time
				} datatype time
			}
		}
	} qualifiers-order P580 id {
		Q18209541$2889b670-4b3d-7f4f-6345-b4f0b465f736
	} rank normal references {
		{
			hash 9a24f7c0208b05d6be97077d855671d1dfdbc0dd snaks {
				P143 {
					{
						snaktype value property P143 datavalue {
							value {
								entity-type item numeric-id 48183 id Q48183
							} type wikibase-entityid
						} datatype wikibase-item
					}
				}
			} snaks-order P143
		}
	}
} {
	mainsnak {
		snaktype value property P69 datavalue {
			value {
				entity-type item numeric-id 569460 id Q569460
			} type wikibase-entityid
		} datatype wikibase-item
	} type statement id {
		Q18209541$E2B9FBBF-F6DF-4844-A256-939795A541B5
	} rank normal
}

----

		puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim {{"id":"q18209541$13572468-2468-1357-eca9-bdf024681357","type":"statement","mainsnak":{"snaktype":"value","property":"P69","datavalue":{"value":{"entity-type":"item","numeric-id":569460,"id":"Q569460"},"datatype":"wikibase-entityid"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":"Q48183","type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}}]]


{
	mainsnak {
		snaktype value property P69 datavalue {
			value {
				entity-type item numeric-id 569460 id Q569460
			} type wikibase-entityid
		} datatype wikibase-item
	} type statement id {
		Q18209541$E2B9FBBF-F6DF-4844-A256-939795A541B5
	} rank normal references {
		{
			hash 9a24f7c0208b05d6be97077d855671d1dfdbc0dd snaks {
				P143 {
					{
						snaktype value property P143 datavalue {
							value {
								entity-type item numeric-id 48183 id Q48183
							} type wikibase-entityid
						} datatype wikibase-item
					}
				}
			} snaks-order P143
		}
	}
}



exit
puts [get [post $wiki {*}$format {*}$token / action wbcreateclaim / entity $qitem / property P69 / snaktype value / value {{"entity-type":"item","numeric-id":"Q657167","snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"type":"wikibase-entityid","value":{"entity-type":"item","numeric-id":48183}}}]}}}]]


exit



set ent {Clara-Jumi Kang}
#set hedisc {רופא פנימי, תזונאי ודיאבטולוג גרמני}

puts [wbeditentity $qitem {
	de {Clara-Jumi Kang} he {קלרה יומי קנג}
} {
	he {כנרת גרמנית} de {deutsche Violinistin} fr {violoniste allemande} en {German violinist} ru {немецкая скрипачка} ko {독일의 바이올리니스트}
}]

#puts [get [post $wiki {*}$format {*}$token / action wbeditentity / id $qitem / data [format {{"labels":[{"language":"en","value":"Matthias Riedl"}],"descriptions":[{"language":"en","value":"German internist, nutritionist and diabetologist"}]}}]]]

exit

mysqlreceive $db "
	select page_title
	from page, pagelinks
	where pl_from = page_id and !page_namespace and !pl_from_namespace and !pl_namespace and pl_title = 'Q16830344'
;" pt {
	catch {set loclaim [get [post $wiki {*}$format / action wbgetclaims / entity $pt / property p106] claims P106]
	foreach oclaim $loclaim {
		if {[dict get $oclaim mainsnak datavalue value id] eq {Q16830344}} {
			dict with oclaim {
				puts [get [post $wiki {*}$token {*}$format / action wbsetclaimvalue / claim $id / snaktype value / value [format {{"entity-type":"item","numeric-id":"%s","id":"%s"}} q34074720 q34074720] / bot]]
			}
		}
	}}
}
exit

mysqlreceive $db "
	select page_title, pl_title
	from pagelinks, page
	where pl_from = page_id and !pl_namespace and !page_namespace and page_title in ([sscat Orgelbauer 0])
;" {pt1 pt2} {
	dict lappend lpt $pt2 \[\[:[sql -> $pt1]\]\]
}

#puts $lpt

foreach {pt2 pt1} $lpt {
	puts [list [llength $pt1] $pt2 $pt1]
	if [missing $pt2] {lappend llpt [llength $pt1] \[\[:[sql -> $pt2]\]\] $pt1}
}

set olpt [lsort -stride 3 -index 0 -integer -decreasing $llpt]
puts $olpt

set th "\{| class=\"wikitable sortable\"\n! lfd. !! Rotlinks !! Link !! Artikel"
set i 0
foreach {ll pt2 pt1} $olpt {
	append tb "\n|-\n| style=\"text-align: right;\" | [incr i]\n| style=\"text-align: right;\" | $ll"
	append tb "\n| [join $pt2]"
	append tb "\n| [join $pt1 {, }]"
}
set tf "|\}"

puts $th$tb\n$tf

puts [edit {Benutzerin:Maimaid/Orgelbauer-Seiten mit Rotlinks} {Bot: neue Seite erstellt} $th$tb\n$tf]

                  

exit

while 1 {try {
	set db [get_db dewiki]
	set out [read [set f [open wikidata1.out]]] ; close $f
	set offset [lindex [split $out \n] end-1]
	puts offset:$offset
	mysqlreceive $db "
		select pl_title
		from pagelinks, page
		where pl_from = page_id and !pl_namespace and !page_namespace
	;" pt {
#	puts [sql -> $pt]
		if {$pt eq $offset} {set offset 1}
		if {$offset eq {1}} {
			if [missing [sql -> $pt]] {puts $pt ; set f [open wikidata1.out a] ; puts $f $pt ; close $f}
		}
	}
} on 1 {} {continue}}


exit

set c [read [set f [open wikidata.out r]]] ; close $f
set lc [split $c \n]
foreach c $lc {if {[string first Template: $c] == -1 && [string first Module: $c] == -1 && [string first Wikipedia: $c] == -1} {lappend nlc [lindex $c 0] [lrange $c 1 end]}}
#puts $nlc
set lc [lsort -stride 2 -index 0 -integer -decreasing [lrange $nlc 0 end-2]]
#puts $lc
set f [open wikidata1.out w] ; puts $f  ; close $f

exit

mysqlreceive $db "
	select page_title
	from page
	where !page_namespace
;" pt {
	lappend lpt $pt
}
foreach pt $lpt {
	try {
		set lsl [get [post $wiki {*}$format / action wbgetentities / ids $pt / props sitelinks] entities $pt sitelinks]
		set lkey [dict keys $lsl]
		if {{dewiki} in $lkey} {continue}
		lremoveglob lkey commonswiki
		unset -nocomplain nlkey
		foreach key $lkey {
			if {[string range $key end-3 end] eq {wiki}} {lappend nlkey $key}
		}
		if {[string first Catego $lsl] == -1 && [llength $nlkey] > 10} {
			set f [open wikidata.out a] ; puts $f "[llength $nlkey] $pt $lsl" ; close $f
		}
	} on 1 {} {continue}
}


exit

mysqlreceive $db "
	select pp_value, page_title
	from page_props, page
	where page_id = pp_page and pp_propname = 'wikibase_item' and page_title in ([sscat Stoffgruppe 0],[sscat Nach_Substitutionsmuster_unterscheidbare_Stoffgruppe 0]) and page_namespace = 0
;" {ppv pt} {
	lappend lq_pt [string trimleft $ppv Q] $pt
	lappend lq [string trimleft $ppv Q]
}

set lq [lsort -integer $lq]

set lang d ; source langwiki.tcl ; #set token [login $wiki]
set db [get_db wikidatawiki]

mysqlreceive $db "
	select term_entity_id, term_text
	from wb_terms
	where term_entity_id in ([join $lq ,]) and term_entity_type = 'item' and term_language = 'de' and term_type = 'description'
;" {teid tt} {
	if [regexp -nocase {chemische Verbindung} $tt] {
		lappend lteid_tt $teid $tt
	}
}

foreach q $lq {
	try {
		set lclaim [get [post $wiki {*}$get {*}$format / action wbgetclaims / entity Q$q / property P31] claims P31]
		foreach claim $lclaim {
			if {[dict get $claim mainsnak datavalue value id] eq {Q11173}} {lappend lp31 $q Q11173}
		}
	} on 1 {} {continue}
}

dict with lq_pt {
	foreach {teid tt} $lteid_tt {
		dict lappend d [list $teid [expr $$teid]] descr $tt
	}
	foreach {teid p31} $lp31 {
		dict lappend d [list $teid [expr $$teid]] p31 $p31
	}
}

set ll {{| class="wikitable sortable"\n|-\n! d:Objekt !! Lemma !! d:Beschreibung !! P31 = Q11173}}
foreach {key val} $d {
	lappend ll "| \[\[:d:Q[lindex $key 0]\]\]\n| \[\[[lindex $key 1]\]\][
		expr {{descr} in [dict keys $val] ? "\n| [dict get $val descr]" : "\n| "}
	][
		expr {{p31} in [dict keys $val] ? "\n| \[\[:d:Q11173\]\]: chemische Verbindung" : "\n| "}
	]"
}
#puts [join $ll \n|-\n]

set lang de ; source langwiki.tcl ; #set token [login $wiki]

puts [edit user:Mabschaaf/Q11173 {} \{[join $ll \n|-\n]\n|\}]

exit

set langconts [conts t {List of Wikipedias/Table} x]
set llang [dict values [regexp -all -inline -- {\| \[\[\:(.*?)\:\|} $langconts]]
foreach lan $llang {
	lappend lw [string map {- _} $lan\wiki]
}

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
	if {[string first : $isp] == -1 && $iii ni {830183}} {
		dict lappend ls $iii [list $isi $isp]
	}
}
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
set nnls [lsort -stride 3 -index 1 -integer -increasing $nnls]
puts $nnls ; gets stdin
foreach {iii ll isp} $nnls {
	puts $iii:$ll:$isp
}

exit

if 0 {

	puts "$iii : $isi : $isp"
}

if 0 {

exit

mysqlreceive $db "
	select ips_item_id, ips_site_id, ips_site_page
	from wb_items_per_site d, page e, pagelinks f
	where d.ips_item_id = (
		select trim(leading 'Q' from e.page_title)
	) and f.pl_from = e.page_id and d.ips_item_id not in (
		select ips_item_id
		from wb_items_per_site a, page b, pagelinks c
		where a.ips_item_id = (
			select trim(leading 'Q' from b.page_title)
		) and c.pl_from = b.page_id and a.ips_site_id = 'dewiki' and b.page_namespace = 0 and c.pl_from_namespace = 0 and c.pl_namespace = 0 and c.pl_title = 'Q5'
	) and e.page_namespace = 0 and f.pl_from_namespace = 0 and f.pl_namespace = 0 and f.pl_title = 'Q6581072'
	order by d.ips_item_id
;" {iii isi isp} {

}



exit

#alle Q mit P854:
mysqlreceive $db "
	select page_title
	from page, pagelinks
	where pl_from = page_id and page_namespace = 0 and pl_title = 'P854' and pl_from_namespace = 0 and pl_namespace = 120
	order by page_title
;" pt {
	lappend lq $pt
}
foreach q $lq {
	set claims [get [post $wiki {*}$format / action wbgetclaims / entity $q] claims]
	foreach {p lval} $claims {
		foreach val $lval {
			if {$p eq {P854} || [string first { P854 } $val] > -1} {
				puts \n$p
				puts ...$val
			}
		}
	}
	exit
}

exit



exit

set s [read [set f [open wikidata5.out r]]] ; close $f
set s [lrange [split $s \n] 0 end-1]
foreach 1 $s {lappend j [split $1 :]}
foreach 1 $j {
	set j1 [lindex $1 1]
	set j3 [lindex $1 3]
	puts \n$j1:$j3
	puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{"id":"%s$13572468-2468-1357-eca9-bdf024681357","type":"statement","mainsnak":{"snaktype":"value","property":"P154","datavalue":{"value":"%s","type":"string"},"datatype":"commonsMedia"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":{"entity-type":"item","numeric-id":"48183","id":"Q48183"},"type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}} $j1 $j3] / bot]]
}


exit

set items [catids {Wikipedia:Infobox Unternehmen/Logo nicht aus Wikidata} 0]
foreach item $items {lappend lkv "page_id = $item"}

foreach 1 $items {
	if {$1 in {311509 240419 1809945 8860119 9050738 7886923}} {continue}
	set c [conts id $1 0]
	set sc [split $c \n]
	foreach 2 $sc {
		if {[string first Logo $2] > -1 && [string first | $2] > -1 && [string first = $2] > -1} {
			set s2 [split $2 =]
			lappend s $1 [string trim [lindex $s2 1]]
#			puts $1:[string trim [lindex $s2 1]]
			break
#			if {[string first | [string replace $2 0 2]] > -1 || [string first \{ $2] > -1 || [string first \[ $2] > -1 || [string first < $2] > -1} {
#				set f [open wikidata4.out a] ; puts $f $1:\n$2\n ; close $f
#			}
		}
	}
}
#foreach {1 2} $s {if {$2 eq {}} {puts $1}
#exit
set lang commons ; source langwiki.tcl ; #set token [login $wiki]
foreach {1 2} $s {
	if ![missing File:$2] {
		lappend bt $1 [string map {_ { }} $2]
		lappend lkv "page_id = $1"
	}
}


}

set lang d ; source langwiki.tcl ; #set token [login $wiki]
mysqlreceive $db "select page_id, page_title, pp_value from page, page_props where pp_page = page_id and ([join $lkv { or }]) and pp_propname = 'wikibase_item' order by page_title;" {pgid pt ppv} {
	lappend ps $pgid $pt $ppv
}
foreach {pgid pt ppv} $ps {
	catch {
		set claims [get [post $wiki {*}$format / action wbgetclaims / entity $ppv] claims]
   	if {{P154} ni [dict keys $claims]} {
   		set f [open wikidata5.out a] ; puts $f $pgid:$ppv:$pt:[dict get $bt $pgid] ; close $f
		}
	}
}

exit

#[dict get $bt $pgid]] eq [string map {_ { }} [dict get [join [get [post $wiki {*}$format / action wbgetclaims / entity Q631220] claims P154]] mainsnak datavalue value]]}
#   } else {
#   	puts $pgid:$ppv:$pt:1
#		input clink "clink: "
#		puts [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{"id":"%s$13572468-2468-1357-eca9-bdf024681357","type":"statement","mainsnak":{"snaktype":"value","property":"P154","datavalue":{"value":"%s","type":"string"},"datatype":"commonsMedia"},"references":[{"snaks":{"P143":[{"snaktype":"value","property":"P143","datavalue":{"value":"Q48183","type":"wikibase-entityid"},"datatype":"wikibase-item"}]},"snaks-order":["P143"]}]}} $ppv $clink] / bot]]

#{value {entity-type item numeric-id 328 id Q328} type wikibase-entityid}
#   puts $ppv:$pt
#   gets stdin




