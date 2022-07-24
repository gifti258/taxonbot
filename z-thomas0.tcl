#!/usr/bin/tclsh8.7
#exit

source procs2.tcl

set cardomap https://denkmalliste.denkmalpflege.sachsen.de/CardoMap/Denkmalliste_Report.aspx?HIDA_Nr

catch {exec wget -O z-thomas.pdf -- $cardomap=$argv}
exec pdftotext z-thomas.pdf
read_file z-thomas.txt txt

puts $txt
