#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6
#exit

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

puts \npingtest:$t

set offset [set newoffset [lindex [set 0content [content [post $wiki {*}$get / pageids 8572511 / rvsection 0]]] 5]]
puts $offset

cont {
   ret1 {
      foreach item [embeddedin $ret1] {
         dict with item {
            set pageid [format %8d [dict get $item pageid]]
            set c0 [content [post $wiki {*}$get / titles $title / rvsection 0]]
            set ca [string map {"{" {} "}" {}} [regsub -all -- {<ref.*>} $c0 {}]]
            set cv [regexp -inline -- {\{\{Personendaten.*?[\n]?\}\}} [content [post $wiki {*}$get / titles $title]]]
            regexp -line -- {\|[ ]?STERBEDATUM.*?=(.*?)$} $cv -- dead
            if ![exists dead] {
               set dead {}
            }
            regexp -line -- {\|[ ]?GEBURTSDATUM.*?=.*?(\d{3,4}).*?(\]\])?.*?$} $cv -- born
            if ![exists born] {
               set born $year
            }
            set dead [string trim $dead]
            if {(    ([string match {*) war*} $ca] && ![string match {*) war vo*} $ca] && ![string match {*) ist*} $ca])
                 ||  ([regexp -- {.*\) war.*\) ist.*} $ca] && ![regexp -- {.*\) war vo.*\) ist.*} $ca]))
                 && [empty dead] && $born > [expr {$year - 99}]
                 && !([string match {*†*} $ca] || [string match {*gest.*} $ca] || [string match {*gestorben*} $ca])} {
               lappend new "\n $pageid: \[\[$title\]\]"
            }
            set newoffset [string trim $pageid]
            unset -nocomplain -- dead born
   }  }  }
} {*}$embeddedin / eititle Vorlage:Personendaten / einamespace 0 / eicontinue 0|[expr {$offset + 1}]

if ![exists new] {
	set new {}
}
puts \n[edid 8572511 +new {} / appendtext [join $new]]

set listcontent [content [post $wiki {*}$get / pageids 8572511]]
foreach ls [split $listcontent \n] {
   set lsd [split $ls :]
   if {[llength $lsd] == 2} {
      if [dict exists [set item [page [post $wiki {*}$query / pageids [set pageid [string trim [join [dict keys $lsd]]]]]]] missing] {
         puts $ls
         set listcontent [string map [list $ls\n {}] $listcontent]
      } else {
	      set 0content [content [post $wiki {*}$get / pageids $pageid / rvsection 0]]
	      set content [content [post $wiki {*}$get / pageids $pageid]]
			set sd [lsearch -exact [set lcontent [split $content \n=]] |STERBEDATUM]
         regexp -line -- {.*?(\d{3,4}).*?(\]\])?.*?$} [string trim [lindex $lcontent $sd-3]] -- gd
         if ![exists gd] {
            set gd $year
         }
			if {[string trim [lindex $lcontent $sd+1]] ne {} || [string trim [lindex $lcontent $sd+3]] ne {} || $gd < [expr {$year - 99}]
			   	|| [string match {*†*} $0content] || [string match {*gest.*} $0content] || [string match {*gestorben*} $0content]} {
			   puts $ls
            set listcontent [string map [list $ls\n {}] $listcontent]
		}  }
      unset -nocomplain -- gd
}  }

set listcontent [regsub -- (?q)$offset $listcontent $newoffset]
puts \n[edid 8572511 Fehlerkorrektur $listcontent]
