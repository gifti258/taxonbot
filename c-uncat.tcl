#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

catch {if {[exec pgrep -cxu taxonbot c-uncat.tcl] > 1} {exit}}

source api.tcl ; set lang commons ; source langwiki.tcl ; #set token [login $wiki]
while 1 {if [catch {set db [get_db commonswiki]}] {after 60000 ; continue} else {break}}

set fl [open c-uncat.out r]
set data [read $fl]
close $fl

set offset [lindex [dict values [regexp -all -inline -line -- {^.*?pageid (\d.*?)\D.*?$} $data]] end]
if [string match {*end of task*} $data] {
   set fl [open c-uncat.out w+]
   close $fl
   set offset 0
}
puts \nOffset:[expr {[empty offset]?[set offset 0]:$offset}]

cont {ret1 {
#   global wiki query get parse
   foreach item [embeddedin $ret1] {
   	if [catch {
	      dict with item {
   	      lassign {} vcats svcats
      	   set prop [page [post $wiki {*}$query / titles $title / prop categories / clshow !hidden]]
         	if [dict exists $prop categories] {
	            set cats [lmap cats [dict get $prop categories] {dict get $cats title}]
   	         if ![string match -nocase {*Check cat*} [get [post $wiki {*}$parse / page $title / prop templates] parse templates]] {
      	         foreach cat $cats {
         	         if {!(   [string match         {*needing cat*}					$cat]
            	            || [string match -nocase {*Invalid SVG*}					$cat]
               	         || [string match -nocase {*should use*}					$cat]
                  	      || [string match -nocase {*requiring review*}			$cat]
                     	   || [string match -nocase {*without usage*}				$cat]
                        	|| [string match -nocase {*deletion*}						$cat]
	                        || [string match -nocase {*from bad authors*}			$cat]
   	                     || [string match -nocase {*non-free logos*}				$cat]
      	                  || [string match -nocase {*fair use deletes*}			$cat]
         	               || [string match -nocase {*otrs*}							$cat]
            	            || [string match -nocase {*duplicat*}						$cat]
               	         || [string match -nocase {*test uploads*}					$cat]
                  	      || [string match -nocase {*unfree flickr*}				$cat]
                     	   || [string match -nocase {*commonsdelinker*}				$cat]
                        	|| [string match -nocase {*media missing*}				$cat]
	                        || [string match -nocase {*media without*}				$cat]
   	                     || [string match -nocase {*no timestamp*}					$cat]
      	                  || [string match -nocase {*mediauploaded*}				$cat]
         	               || [string match -nocase {*Incorrect date*}				$cat]
            	            || [string match -nocase {*Photographs taken*}			$cat]
               	         || [string match -nocase {*check needed*}					$cat]
                  	      || [string match -nocase {*taken with*}					$cat]
                     	   || [string match -nocase {*need of*}						$cat]
                        	|| [string match -nocase {*Wikipedia related*}			$cat]
	                        || [string match -nocase {*License-related*}				$cat]
   	                     || [string match -nocase {*Images which should not*}	$cat]
   	                     || [string match -nocase {*Citing errors*}				$cat]
									|| [string match -nocase {*Wiki Loves*}					$cat]
      	                  || ![dict exists [page [post $wiki {*}$query / titles $cat / prop categories / clshow !hidden]] categories]
         	               || [dict exists [page [post $wiki {*}$query / titles $cat / prop categoryinfo]] missing])} {
            	         lappend vcats $cat
            	      }
               	}
	               if {[llength $vcats] > 0} {
   	               set uncattype [regexp -nocase -inline -- {\{\{(Uncat.*?)\|} [
      	               set content [content [post $wiki {*}$get / titles $title]]
         	         ]]
            	      regexp -nocase -- {\{\{(Uncat.*?)\|} [set content [content [post $wiki {*}$get / titles $title]]] -- uncattype
               	   regsub -nocase -- {(\n\{\{Uncat.*?\}\})} $content {} ccontent
                  	regsub -all -- {(\n{3})} $ccontent \n\n ccontent
	                  regsub -all -- {(\}\}|\]\])(\[\[|\{\{)} $ccontent \\1\n\\2 ccontent
   	               foreach vcat $vcats {
      	               lappend svcats \[\[:$vcat\]\]
         	         }
            	      if [string match -nocase *uncat* $uncattype] {
               	      set summary "Bot: \[\[:Template:$uncattype\]\] no longer applicable due to [join $svcats {, }]"
                  	   puts "[clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}] pageid $pageid title $title"
                     	puts [edit $title $summary {} / text $ccontent / bot]\n
                     }
						}
					}
				}
			}
		}] {continue}
	}
}} {*}$embeddedin / eititle Template:Uncategorized / einamespace 6 / eicontinue 6|$offset

puts {end of task}
