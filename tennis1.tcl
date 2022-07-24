#!/usr/bin/tclsh8.7

#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

set qual {Wikipedia:WikiProjekt Tennis/Qualitätsoffensive}
set lplayer [dcat list Tennisspieler 0]
foreach navi [dcat list {Vorlage:Navigationsleiste Tennis} 10] {
	if {[string first bestplatzierten $navi] > -1} {
		lappend lnavi $navi
	}
}
foreach navi $lnavi {
	set db [get_db dewiki]
	mysqlreceive $db "
		select pl_title
		from pagelinks join page on page_id = pl_from
		where pl_from_namespace = 10 and !pl_namespace and page_title = '[sql <- $navi]' and page_namespace = 10 and pl_title not in (
			select page_title
			from page join templatelinks on tl_from = page_id
			where !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title = '[sql <- $navi]'
		)
	;" pt {
		set pt [sql -> $pt]
		if {$pt in $lplayer} {
			dict lappend f_dnavi ":::* \{\{Vorlage|$navi\}\}" \[\[$pt\]\]
		}
	}
	mysqlreceive $db "
		select page_title
		from page join templatelinks on tl_from = page_id
		where page_title not in (
			select pl_title
			from pagelinks join page on page_id = pl_from
			where pl_from_namespace = 10 and !pl_namespace and page_title = '[sql <- $navi]' and page_namespace = 10
		) and !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title = '[sql <- $navi]'
	;" pt {
		set pt [sql -> $pt]
		if {$pt in $lplayer} {
			dict lappend u_dnavi ":::* \{\{Vorlage|$navi\}\}" \[\[$pt\]\]
		}
	}
	mysqlclose $db
}
foreach {branch lres} [list $f_dnavi f_lres $u_dnavi u_lres] {
	foreach {navi lplayer} $branch {
		lappend $lres "$navi: [join $lplayer { · }]"
	}
}
lassign [list [join $f_lres \n] [join $u_lres \n]] f_res u_res
#puts $f_res\n\n$u_res
set qconts [conts t $qual x]
regexp -- {<!--TB-NAVILIST.*?TB-NAVILIST-->} $qconts onavilist
set nnavilist "<!--TB-NAVILIST-->\n::; fehlende Navigationsleisten\n$f_res\n::; überzählige Navigationsleisten\n$u_res\n<!--TB-NAVILIST-->"
set nqconts [string map [list $onavilist $nnavilist] $qconts]
puts [edit $qual {Bot: NAVILIST} $nqconts / minor]


exit

