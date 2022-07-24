#!/usr/bin/tclsh8.7
#exit

set editafter 1
#if {[exec pgrep -cxu taxonbot test3.tcl] > 1} {exit}

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]


if 0 {
set db [get_db wikidatawiki]
set lde [mysqlsel $db {SELECT
  wbit_item_id as id,
    wby_name as type,
      wbxl_language as language,
        wbx_text as text
        FROM wbt_item_terms
        LEFT JOIN wbt_term_in_lang ON wbit_term_in_lang_id = wbtl_id
        LEFT JOIN wbt_type ON wbtl_type_id = wby_id
        LEFT JOIN wbt_text_in_lang ON wbtl_text_in_lang_id = wbxl_id
        LEFT JOIN wbt_text ON wbxl_text_id = wbx_id
        WHERE wbxl_language = 'de' limit 100;} -list]
mysqlclose $db

puts $lde

#        WHERE wbit_item_id = 822280 and wbxl_language = 'de'; -list]

exit

}


set db [get_db wikidatawiki]
set lde [mysqlsel $db "
	select wbit_item_id, wby_name, wbxl_language, wbx_text, rc_title, rc_timestamp, rc_cur_id, ips_site_id, ips_site_page, comment_text
	from recentchanges
	left join wb_items_per_site on ips_item_id = trim('Q' from rc_title)
	left join wbt_item_terms on wbit_item_id = ips_item_id
	LEFT JOIN wbt_term_in_lang ON wbit_term_in_lang_id = wbtl_id
	LEFT JOIN wbt_type ON wbtl_type_id = wby_id
	LEFT JOIN wbt_text_in_lang ON wbtl_text_in_lang_id = wbxl_id
	LEFT JOIN wbt_text ON wbxl_text_id = wbx_id
	left join comment on comment_id = rc_comment_id
	where wbxl_language = 'de' and !rc_namespace and rc_timestamp >= 20210625220000
		and ips_site_id = 'dewiki'
	order by ips_site_page
;" -list]
mysqlclose $db

puts $lde
puts [llength $lde]


exit

	where ips_item_id = trim('Q' from rc_title) and comment_id = rc_comment_id



set tyear   [utc -> seconds {} %Y {}]
set chron   "Wikipedia:Hauptseite/Artikel des Tages/Chronologie $tyear"
set lchron   "Wikipedia:Hauptseite/Artikel des Tages/Chronologie [expr $tyear - 1]"

set ltc [dict values [regexp -all -line -inline -- {\[\[(.*)\]\]} [conts t $chron x]]]
set llc [dict values [regexp -all -line -inline -- {\[\[(.*)\]\]} [conts t $lchron x]]]

set lcc [join [list [lrange $ltc 0 end-1] [lrange $llc 0 end-1]]]
puts $lcc

puts [llength $lcc]

foreach cc [lrange $lcc 0 4] {
	lappend lpcc Diskussion:$cc
}

puts [get [post $wiki {*}$format / action purge / titles [join $lpcc |] / forcerecursivelinkupdate 1]]

exit

while 1 {
input 1 "n: "
input 2 "l: "

puts "set old$1 \{$2\}"
puts "set new$1 \{[string map [list {<font color="} {<span style="color:} {">} {;">} {</font>} {</span>}] $2]\}"

}

exit

set lins [insource {font color='/} 2]
puts $lins

foreach ins $lins {
	if {[string first Abbottbot $ins] > -1} {
		puts [edit $ins {Bot: Überarbeitung veralteter Syntax / [[H:LINT|HTML-Validierung]]} [string map [list {'''<font color='orange'>} {<span style='color:orange;'>'''} {'''<font color='red'>} {<span style='color:red;'>'''} {</font>'''} {'''</span>}] [conts t $ins x]] / minor]
		if {[incr c] <= 5} {gets stdin}
	}
}

exit

set pg "Wikipedia:Liste von Tippfehlern/$argv"

set c [conts t $pg x]

#puts $c

regsub -all -line -- {--.*?T\)} $c {} nc
regsub -all -line -- {-\[.*?T\)} $nc {} nc
regsub -all -line -- {\[\[Benutzer.*?T\)} $nc {} nc
regsub -all -line -- {\d\d:\d\d.*?T\)} $nc {} nc
#regsub -all -line -- {i\. V\..*?$} $nc {} nc
#regsub -all -line -- {-.*?\[\[Benutzer.*?T\)} $nc {} nc
regsub -all -line -- {--.*?11} $nc {} nc

puts $nc

gets stdin

puts [edit $pg {Bot: aktualisiert} $nc]


exit

#set lins [lsort [insource {\{\{BLfD/} x]]
set lins [insource {Lucida Calligraphy\;\"\>S/} x]
puts [set i [llength $lins]]

set summ {Korrektur ungültiger HTML-Syntax}
set old1 {<small>[[Benutzer:Steindy|<span style="color:#400040; font-family:Lucida Calligraphy;">S]]tein</span></small><small>[[Benutzer Diskussion:Steindy|<span style="color:#400040; font-family:Lucida Calligraphy;">d]]y</span></small>}
set new1 {<small style="font-family:Lucida Calligraphy;">[[Benutzer:Steindy|<span style="color:#400040">Stein</span>]][[Benutzer Diskussion:Steindy|<span style="color:#400040;">dy</span>]]</small>}
set old2 {[[Benutzer:Steindy|<span style="color:#400040; font-family:Lucida Calligraphy;">S]]tein[[Benutzer Diskussion:Steindy|d]]y</span>}
set new2 {[[Benutzer:Steindy|<span style="color:#400040; font-family:Lucida Calligraphy;">Stein</span>]][[Benutzer Diskussion:Steindy|d]]y}

set o 1
foreach ins $lins {
  puts \n[decr i]:$ins:
	if $o {
  if {$ins ne {Benutzer Diskussion:Wahrerwattwurm/Archiv 11}} {continue} else {set o 0}
}
  set out [edit $ins "Bot: $summ" [string map [list $old1 $new1 $old2 $new2] [conts t $ins x]] / minor]
  puts $out
  if {{protectedpage} in [split $out]} {
#continue
     source api2.tcl ; set lang de1 ; source langwiki.tcl ; #set token [login $wiki]
     puts [edit $ins $summ [string map [list $old1 $new1 $old2 $new2] [conts t $ins x]] / minor]
     after 5000
     source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
  }
  if {[incr c] <= 5} {gets stdin}
}

