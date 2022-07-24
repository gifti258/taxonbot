#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

if {[exec pgrep -cxu taxonbot com.tcl] > 1} {exit}

source api.tcl ; set lang commons ; source langwiki.tcl ; #set token [login $wiki]

lassign {https://commons.wikimedia.org/wiki/ special:uploadwizard?} first1 first2
set f [open WORKLIST/@com1 w] ; close $f
set db [get_db dewiki]
mysqlreceive $db "
	select page_title, el_to
	from page, externallinks
	where el_from = page_id and page_namespace = 0
	order by page_title
;" {pt elt} {
	if {[string first $first1 $elt] > -1 && [string first $first2 [string tolower $elt]] == -1} {
		set cpage [string map {\\ {}} [dict values [
			regexp -inline -- {https://commons.wikimedia.org/wiki/(.*?)(?:\?uselang|$)} [urldecode $elt]
		]]]
		lappend lcpage $pt [lindex [split $cpage |] 0]
	}
}
mysqlclose $db
foreach {pt cpage} $lcpage {
	set f [open WORKLIST/@com1 a]
	while 1 {
		try {
			if [missing $cpage] {puts $f "missing $pt $cpage" ; puts "missing $pt $cpage"}
			if [redirect $cpage] {puts $f "redirect $pt $cpage" ; puts "redirect $pt $cpage"}
			if [matchtemplate $cpage {Template:Category redirect}] {puts $f "redirect $pt $cpage" ; puts "redirect $pt $cpage"}
			break
		} on 1 {} {}
	}
	close $f
}
set com1 [read [set f [open WORKLIST/@com1 r]]] ; close $f
set f [open WORKLIST/@com2 w] ; puts $f $com1 ; close $f

