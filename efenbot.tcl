#!/usr/bin/tclsh8.7
##!/usr/bin/tclsh8.6

#if {[string trim [clock format [clock seconds] -format %e -timezone :Europe/Berlin]] != 1} {exit}

source api.tcl ; set lang dea ; source langwiki.tcl ; #set token [login $wiki]
if {[utc -> seconds {} %e {}] != 1} {exit}

set db [get_db dewiki]
mysqlreceive $db "
	select page_title, page_is_redirect
	from page
	where page_namespace = 4
;" {pt pir} {
	if !$pir {
		set pt [string map {_ { }} Wikipedia:$pt]
		if ![string match */* $pt] {
			lappend l4 "#\[\[$pt  \]\]"
		} else {
			lappend l4 "#\[\[[join [dict values [regexp -inline {(.*?)/} $pt]]]  \]\]"
		}
	}
}
mysqlclose $db
set l4 [string map {{  ]]} ]]} [join [lsort -unique $l4] \n]]
set oc1 [join [dict values [regexp -inline -- {\n\n(.*)} [set oc [contents t Benutzer:EfenBot/Sitemap_1_-w/WP: x]]]]]
if {$oc1 ne $l4} {
	set ts [string trim [clock format [clock seconds] -format {%e. %B %Y} -locale de -timezone :Europe/Berlin]]
	regsub -- {(.*</noinclude>).*} $oc [string map {& \\&} "\\1$ts by TaxonBota\n\n$l4"] l4
	puts [edit Benutzer:EfenBot/Sitemap_1_-w/WP: {Bot: Sitemap aktualisiert} $l4 / minor]
}
puts ------------
set timer [clock microseconds]
set ts [clock format [string range $timer 0 9] -format %Y-%m-%dT%T.[string range $timer 10 15]]
set db [get_db dewiki]
mysqlreceive $db "
	select page_title
	from page
	where page_namespace = 4 and page_title like 'Lua%'
;" pt {
	lappend llua "\"[join Wikipedia:[string map {_ { }} $pt]]  \""
}
mysqlclose $db
set llua [string map {{  "} {"}} [join $llua ,\n]]
regsub -- {(stamp = ").*?(".*?\{\n).*?(\n\})} [contents t Modul:PageTree/WP:Lua/bot x] [string map {& \\&} \\1$ts\\2$llua\\3] llua
puts [edit Modul:PageTree/WP:Lua/bot {Bot: Liste aktualisiert} $llua / minor]
puts ------------
set timer [clock microseconds]
set ts [clock format [string range $timer 0 9] -format %Y-%m-%dT%T.[string range $timer 10 15]]
set db [get_db dewiki]
mysqlreceive $db "
	select page_title
	from page
	where page_namespace = 4 and page_title like 'Technik/%'
;" pt {
	lappend ltech "\"[regsub -- {.*?(/.*)} [join Wikipedia:[string map {_ { }} $pt]] \\1]  \""
}
mysqlclose $db
set ltech [string map {{  "} {"}} [join $ltech ,\n]]
regsub -- {(stamp = ").*?(".*?\{\n).*?(\n\})} [contents t Modul:PageTree/WP:Technik/bot x] [string map {& \\&} \\1$ts\\2$ltech\\3] ltech
puts [edit Modul:PageTree/WP:Technik/bot {Bot: Liste aktualisiert} $ltech / minor]
puts ------------
set timer [clock microseconds]
set ts [clock format [string range $timer 0 9] -format %Y-%m-%dT%T.[string range $timer 10 15]]
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, page_is_redirect
	from page
	where page_namespace = 12
;" {pt pir} {
	if !$pir {
		set pt [string map {_ { }} Hilfe:$pt]
		if ![string match */* $pt] {
			lappend l12 "\"$pt  \""
		} else {
			lappend l12 "\"[join [dict values [regexp -inline {(.*?)/} $pt]]]  \""
		}
	}
}
mysqlclose $db
set l12 [string map {{  "} {"}} [join [lsort -unique $l12] ,\n]]
regsub -- {(stamp = ").*?(".*?\{\n).*?(\n\})} [contents t Modul:PageTree/Hilfe:!/bot x] [string map {& \\&} \\1$ts\\2$l12\\3] l12
puts [edit Modul:PageTree/Hilfe:!/bot {Bot: Liste aktualisiert} $l12 / minor]
puts ------------
set timer [clock microseconds]
set ts [clock format [string range $timer 0 9] -format %Y-%m-%dT%T.[string range $timer 10 15]]
set db [get_db dewiki]
mysqlreceive $db "select page_title, pr_type, pr_level
	from page
	left join page_restrictions on pr_page = page_id
	where page_namespace = 828
;" {pt prt prl} {
	set pt [string map {_ { }} Modul:$pt]
	if ![empty prt] {
		dict lappend l828 $pt $prt=$prl
	} else {
		dict lappend l828 $pt
	}
}
mysqlclose $db
foreach {pt pr} $l828 {
	if {$pr ne {}} {
		lappend nl828 "\{ seed=\"$pt  \", protection=\"[join $pr :]\" \}"
	} else {
		lappend nl828 "\"$pt  \""
	}
}
set l828 [string map {{  "} {"}} [join $nl828 ,\n]]
regsub -- {(stamp = ").*?(".*?\{\n).*?(\n\})} [contents t Modul:PageTree/Modul:/bot x] [string map {& \\&} \\1$ts\\2$l828\\3] l828
puts [edit Modul:PageTree/Modul:/bot {Bot: Liste aktualisiert} $l828 / minor]
puts ------------
set timer [clock microseconds]
set ts [clock format [string range $timer 0 9] -format %Y-%m-%dT%T.[string range $timer 10 15]]
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, page_is_redirect
	from page
	where page_namespace = 12
;" {pt pir} {
	set pt [string map {_ { }} Hilfe:$pt]
	if $pir {
		set target [string trim [string map {_ { } { #} #} [join [dict values [regexp -inline -- {\[\[(.*?)\]\]} [contents t $pt x]]]]]]
		lappend lhelp "\{ seed=\"$pt  \", shift=\"$target\" \}"
	} else {
		lappend lhelp "\"$pt  \""
	}
}
mysqlclose $db
set lhelp [string map {{  "} {"}} [join $lhelp ,\n]]
regsub -- {(stamp = ").*?(".*?\{\n).*?(\n\})} [contents t Modul:PageTree/Hilfe:/bot x] \\1$ts\\2[string map {& \\&} $lhelp]\\3 lhelp
puts [edit Modul:PageTree/Hilfe:/bot {Bot: Liste aktualisiert} $lhelp / minor]
puts ------------
