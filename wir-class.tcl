#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#set editafter 500

source api.tcl ; set lang d ; source langwiki.tcl ; #set token [login $wiki]

set lpt {}
set q [lindex $argv 0 0]


if {$q eq {out}} {
	read_file wir-class.out out
	set lq [lrange [regexp -all -inline -- {Q\d{1,}} $out] 0 201]
	puts [set sq [d_uqsort $lq]]
	foreach q $sq {
		puts "$q - [wb_get_label $q en] - [wb_get_label $q de]"
	}
	save_file w1.db $sq
	set f [open wir-class.out w] ; close $f
	exit
}

set f [open wir-class.out a] ; puts $f $q ; close $f

set db [get_db wikidatawiki]
mysqlreceive $db "
   select page_title
   from page c, pagelinks d
   where d.pl_from = c.page_id and c.page_id in (
      select page_id
      from page a, pagelinks b
      where b.pl_from = a.page_id and !a.page_namespace and !b.pl_from_namespace and !b.pl_namespace and b.pl_title = '$q'
   ) and !c.page_namespace and !d.pl_from_namespace and d.pl_namespace = 120 and d.pl_title = 'P279'
;" pt {
	catch {if {[string first $q\} [dict get [get [post $wiki {*}$get {*}$format / action wbgetclaims / entity $pt] claims] P279]] > -1} {
		lappend lpt $pt
#		puts [regexp -inline -- {"labels.*?\{.*?\{.*?\}.*?\}} [conts t $pt x]]
	}}
}
mysqlclose $db

foreach pt $lpt {
	set f [open wir-class.out a] ; puts $f $pt ; close $f
	set db [get_db wikidatawiki]
	mysqlreceive $db "
   	select term_entity_id, term_text
   	from wb_terms
   	where term_entity_id = (
   		select trim(leading 'Q' from '$pt')
   	) and term_entity_type = 'item' and term_language = 'en' and term_type = 'label'
	;" {te tt} {
#set f [open wir-class.out a]
#		puts $f "$te - $tt\n--"
		set f [open wir-class.out a] ; puts $f "$te - $tt\n--" ; close $f
		exec ./wir-class.tcl $pt &
#		puts ----
#		puts $f ----
#close $f
	}
	mysqlclose $db
}
