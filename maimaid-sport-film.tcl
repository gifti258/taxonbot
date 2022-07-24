#!/usr/bin/tclsh8.7
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
source procs.tcl
source library.tcl
set db [get_db dewiki]

set dcatSport [dcat list Sport 14]
set dcatFilm  [dcat list Film 14]
set f [open maimaid-sport-film.db w] ; puts $f [join [list $dcatSport $dcatFilm]] ; close $f

