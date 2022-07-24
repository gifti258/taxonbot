#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
#source library.tcl

#set db [get_db dewiki]
#set db [get_db tools s51837__MerlBot]


puts [clock format [clock seconds] -format %Y-%m-%d-%T]

exit

set lei [template Infobox_Protein 0]
set lei [lsort $lei]
#puts $lei:[llength $lei]

foreach ei $lei {
	set lsei [split [conts t $ei 0] \n]
	foreach sei $lsei {
		if [regexp -- {\| ?PDB} $sei] {
			set sei [regsub -all -- {<!--.*?-->} $sei {}]
			set sei [split $sei =]
			set ei2 [string trim [lindex $sei 1]]
			if {$ei2 == {}} {
				lappend mei \[\[$ei\]\]
			}
		}
	}
}
set tei [join $mei "\n# "]
puts [edit user:Kopiersperre/Proteine_ohne_PDB {Liste von Proteinen ohne PDB} "# $tei"]

exit

set catlemma {Animated film stubs}
set catns 14
set lcat14 [format {{%s}} $catlemma]
lassign {0 1} olenlcat14 lenlcat14
while {$lenlcat14 != $olenlcat14} {
#	if {$lenlcat14 == $olenlcat14} {break}
	set olenlcat14 $lenlcat14
	set lcat14 [split $lcat14]
	foreach cat14 [join $lcat14] {lappend lcat14 [sqlcat $cat14 14]}
	set lcat14 [lsort -unique [join $lcat14]]
	set lenlcat14 [llength $lcat14]
}
#lremove lcat14 $catlemma
foreach cat14 $lcat14 {lappend lcat [sqlcat $cat14 $catns]}
puts [lsort -unique [join $lcat]]:[llength [lsort -unique [join $lcat]]]

exit

#set revc [mysqlsel $db "select count(*) from revision join page on rev_page = page_id where page_title = \"[join $src _]\" and page_namespace = 0" -list]

#puts [mysqlsel $db "select page_title from page, categorylinks where page_id = cl_from and cl_type = 'subcat' and cl_to = 'Mineralogie';" -list]

#puts [mysqlsel $db "select * from page where page_title = 'ABC';;" -list]

set data [mysqlsel $db "select page_title from page, categorylinks where page_id = cl_from and cl_to = 'Stage_actors' and page_namespace = 14 ;" -list]
puts $data\n[llength $data]


