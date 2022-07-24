#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

set editafter 1
source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

#set src $page
#set tgt $npage

input src "Source: "
input tgt "Target: "
input ers "ersetzen statt maskieren: "

#for {set staffel 1} {$staffel <= 15} {incr staffel} {
#set src "Let’s Dance (Staffel $staffel)"
#set tgt "Let’s Dance/Staffel $staffel"
#}


catch [set lbl [backlinks $src 0]]

foreach bl $lbl {
	puts \n$bl:
	set conts [conts t $bl x]
	set src_ [string map {{ } _} $src]
	set nconts [string map [list \[\[$src_ \[\[$src] $conts]
	set nconts [string map [list \[\[$tgt|$src\]\] \[\[$tgt\]\]] $nconts]
	if {$ers in {e j}} {
		set nconts [string map [list \[\[$src\]\] \[\[$tgt\]\]] $nconts]
	} else {
		set nconts [string map [list \[\[$src\]\] \[\[$tgt|$src\]\]] $nconts]
	}
	set nconts [string map [list "\[\[$src |" \[\[$src|] $nconts]
	set nconts [string map [list \[\[$src\# \[\[$tgt\#] $nconts]
	set nconts [string map [list \[\[$src| \[\[$tgt|] $nconts]
	set nconts [string map [list \[\[$tgt|$tgt\]\] \[\[$tgt\]\]] $nconts]

#set nconts [string map {{{CSK|Kateřina Skronská|K. Skronská-Böhmová}} {{CSK|Kateřina Böhmová (Tennisspielerin, 1958)|K. Skronská-Böhmová}} {{CSK|Kateřina Skronská|Kateřina Skronská}} {{CSK|Kateřina Böhmová (Tennisspielerin, 1958)|K. Skronská-Böhmová}} {{CSK|Kateřina Skronská|K. Skronská}} {{CSK|Kateřina Böhmová (Tennisspielerin, 1958)|K. Skronská-Böhmová}}} $nconts]

	puts [edit $bl "Bot: \[\[$src\]\] → \[\[$tgt\]\]" $nconts / minor]
}


exit

#set lcat [scat {Bella Block (Fernsehreihe)} 0]

#foreach cat $lcat {
#	set src [string map {: { –} ... …} $cat]
#	set tgt $cat
#if {[incr i] in {1 2}} {continue}
#puts $src
#unset -nocomplain lbl
#set db [get_db dewiki]
#mysqlreceive $db "
#	select page_title
#	from page, pagelinks
#	where pl_from = page_id and page_namespace = 0 and pl_from_namespace = 0 and pl_namespace = 0 and pl_title = '[sql <- $src]'
#	order by page_title
#;" pt {
#	lappend lbl [sql -> $pt]
#}
#mysqlclose $db

#set lbl {}
catch [set lbl [backlinks $src 0]]

foreach bl $lbl {
	puts \n$bl:
	set conts [conts t $bl x]
	set src_ [string map {{ } _} $src]
	set nconts [string map [list \[\[$src_ \[\[$src] $conts]
	set nconts [string map [list \[\[$src\]\] \[\[$tgt|$src\]\]] $nconts]
	set nconts [string map [list "\[\[$src |" \[\[$src|] $nconts]
	set nconts [string map [list \[\[$src\# \[\[$tgt\#] $nconts]
	set nconts [string map [list \[\[$src| \[\[$tgt|] $nconts]
	set nconts [string map [list \[\[$tgt|$tgt\]\] \[\[$tgt\]\]] $nconts]
	set nconts [string map [list \[\[$tgt|$src\]\] \[\[$tgt\]\]] $nconts]

#set nconts [string map {{[[Bella Block]] –} {[[Bella Block]]:}} $nconts]




#set nconts [string map [list "\}\}\n\[\[Kategorie:" "\}\}\n\[\[Kategorie:Fernsehfilm\]\]\n\[\[Kategorie:Kriminalfilm\]\]\n\[\[Kategorie:"] $conts]
#puts $nconts
#	puts [edit $cat "Bot: +2 Kategorien (siehe \[\[Spezial:Diff/177416588/177447057|RFF-Diskussion\]\])" $nconts / minor]
#gets stdin

	puts [edit $bl "Bot: \[\[$src\]\] → \[\[$tgt\]\]" $nconts / minor]
#	if {[incr x] < 7} {gets stdin}
}
}
