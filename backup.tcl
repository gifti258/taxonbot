#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

set editafter 1

source api.tcl ; set lang test ; source langwiki.tcl ; #set token [login $wiki]

set lfile1 [glob *.tcl]
set lfile2 [glob *.db]
set lfile "[join $lfile1] [join $lfile2]"
lappend lfile crontab
lappend lfile py-test.py
lappend lfile @Befehle
#lappend lfile d/human.tcl
#lappend lfile NeueArtikel.match/@NeueArtikel.db NeueArtikel.match/@iNeueArtikel.db
#lappend lfile QSWORKLIST/@qsdict.db QSWORKLIST/@qswkat.db
#lappend lfile WORKLIST/@wdwlkat.db WORKLIST/@wkat.db WORKLIST/@wkat1.db WORKLIST/@wkat2.db
lappend lfile xmlframe.xml

foreach file [lsort $lfile] {
	puts \n$file
	if {$file in {test4.db test6a.db}} {continue}
	set code [read [set f [open $file]]] ; close $f
	try {puts [edit user:TaxonBot/$file {Backup} "<!--\n<source lang=\"tcl\">\n$code\n</source>\n-->"]} on 1 {} {
		puts Backup-Fehler
	}
}
