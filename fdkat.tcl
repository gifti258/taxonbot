#!/usr/bin/tclsh8.7
#exit

catch {if {[exec pgrep -cxu taxonbot fdkat.tcl] > 1} {exit}}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]

set wplk Wikipedia:Löschkandidaten
set db [get_db dewiki]
set llktitle [mysqlsel $db {
	select page_id
	from page join templatelinks on tl_from = page_id
	where tl_from_namespace = page_namespace and page_namespace != 14 and tl_namespace = 10 and tl_title = 'Löschantragstext'
;} -flatlist]
mysqlclose $db
set mlkpg {}
foreach pgid $llktitle {
	if {$pgid == 10148169} {continue}
	set llkpgid {}
	regexp -line -- {\{\{Löschantragstext\|tag=(\d{1,2})\|monat=(.*?)\|jahr=(\d{4})\|titel=(.*?)\|text=} [conts id $pgid x] -- lkday lkmonth lkyear lklink
	set lkpage "$wplk/$lkday. $lkmonth $lkyear"
	set sqllkpage '[sql <- "Löschkandidaten/$lkday. $lkmonth $lkyear"]'
	set db [get_db dewiki]
	set llkpg [mysqlsel $db "
		select pl_namespace, pl_title
		from pagelinks join page on page_id = pl_from
		where page_namespace = pl_from_namespace and page_namespace = 4 and page_title = $sqllkpage
	;" -flatlist]
	foreach {plns plt} $llkpg {
		lappend llkpgid [mysqlsel $db "
			select page_id
			from page
			where page_namespace = $plns and page_title = '[sql <- $plt]'
		;" -flatlist]
	}
	mysqlclose $db
	set llkpgid [lsort -unique $llkpgid]
	lremove llkpgid {}
	if {$pgid ni $llkpgid} {
		lappend mlkpg [page_title $pgid] $lkpage $lklink
	}
}
set lres {}
foreach {lkpgt lkpage lklink} $mlkpg {
	lappend lres "* \[\[:$lkpgt\]\]<small> (\[\[$lkpage#$lklink|&#91;&#91;$lkpage&#93;&#93;\]\])</small>"
}
set fdcount [llength $lres]
set fdbranch ";\[\[Datei:Puzzled.svg|30x15px|text-unten|Eintragung fehlt|link=Benutzer:MerlBot/Nicht eingetragener Baustein\]\]&nbsp;Nicht eingetragener Baustein<small> ([tdot $fdcount])</small>"
if $fdcount {set fdblock \n$fdbranch\n[join $lres \n]} else {set fdblock {}}
set nneconts [set oneconts [conts t "$wplk/Nicht eingetragen" x]]
set mbqsw <!--MB-QSWORKLIST-->
regexp -- {<!--MB-QSWORKLIST-->.*<!--MB-QSWORKLIST-->} $oneconts one
set nneconts [string map [list $one $mbqsw$fdblock\n$mbqsw] $nneconts]
if {$nneconts ne $oneconts} {
	puts [edit "$wplk/Nicht eingetragen" "Bot: QSWORKLIST: [tdot $fdcount]" $nneconts / minor]
}
