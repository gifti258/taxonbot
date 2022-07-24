#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

if {[exec pgrep -cxu taxonbot cat-db.tcl] > 1} {exit}

source api.tcl ; set lang kat ; source langwiki.tcl ; #set token [login $wiki]

proc subcat cat {
	set db [get_db dewiki]
	set int [mysqlsel $db "
		select cat_subcats
		from category
		where cat_title = '$cat'
	;" -flatlist]
	mysqlclose $db
	return $int
}

set alphabet {1 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
set db [get_db dewiki]
set lcat [mysqlsel $db {
	select page_title
	from page
	where page_namespace = 14
;} -flatlist]
mysqlclose $db
foreach first $alphabet {
	set ldbcat [string map {~~~~~ ~ ~ / ´´´´ !} [glob -directory cat-db/$first -tails *]]
	foreach cat $ldbcat {
		catch {
			if {$cat ni $lcat || ![subcat $cat]} {
				puts "rm: cat-db/$first/$cat"
				exec rm cat-db/$first/[string map {~ ~~~~~ / ~ ! ´´´´} $cat]
			}
		}
	}
}

set db [get_db dewiki]
mysqlreceive $db "
	select cl_to, page_title
	from categorylinks, page
	where page_id = cl_from and page_namespace = 14
#	order by cl_to
;" {ct pt} {
	if {[string index $ct 0] ni {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}} {
		set first 1
	} else {
		set first [string index $ct 0]
	}
	dict lappend dct cat-db/$first/[string map {{ } _ ~ ~~~~~ / ~ ! ´´´´} $ct] Kategorie:[sql -> $pt]
}
mysqlclose $db
#file delete -force -- cat-db
#puts [dict keys $dct] ; gets stdin
foreach {ct lct} $dct {
	if ![empty lct] {
		file mkdir [file dirname $ct]
		set f [open $ct w] ; puts $f [lsort -unique $lct] ; close $f
	}
}
