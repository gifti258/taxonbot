source library.tcl

proc utc {dir oclock oformat nformat add} {
	if {$dir eq {->}} {
		return [
			string trim [
				clock format [
					clock add [
						expr {$oclock eq {seconds} ? [clock seconds] : [clock scan $oclock -format $oformat]}
					] {*}[expr {![empty add] ? $add : {0 seconds}}]
				] -format $nformat -timezone :Europe/Berlin -locale de]
			]
		]
	} elseif {$dir eq {<-}} {
		return [
			string trim [
				clock format [
					clock add [
						expr {$oclock eq {seconds} ? [clock seconds] : [clock scan $oclock -format $oformat -timezone :Europe/Berlin -locale de]}
					] {*}[expr {![empty add] ? $add : {0 seconds}}]
				] -format $nformat]
			]
		]
	} elseif {$dir eq {^}} {
		return [
			string trim [
				clock format [
					clock add [
						expr {$oclock eq {seconds} ? [clock seconds] : [clock scan $oclock -format $oformat -locale de]}
					] {*}[expr {![empty add] ? $add : {0 seconds}}]
				] -format $nformat -locale de]
			]
		]
	}
}

proc sql {dir var} {
	if {$dir eq {<-}} {
		return [string map {{ } _ ' \\' , \\,} $var]
	} elseif {$dir eq {->}} {
		return [string map {_ { } \\' ' \\, ,} $var]
	}
}

proc sqlreceive {wiki args} {
	lassign [list [get_db $wiki] [join $args]] db args
	dict with args {
		mysqlreceive $db "
			select [join $select ,]
			from $from
			[expr {[exists where] ? "where $where" : {}}]
			[expr {[exists order] ? "order $order" : {}}]
		;" $select {
			eval $body
		}
		mysqlclose $db
	}
	return $result
}

proc tdot var {
	if {[string length $var] > 9} {regsub -- {\d{9}$} $var .& var}
	if {[string length $var] > 6} {regsub -- {\d{6}$} $var .& var}
	if {[string length $var] > 3} {regsub -- {\d{3}$} $var .& var}
	return $var
}

proc states body {
   proc goto {id} {
      uplevel set goto $id
      return -code continue
   }
   uplevel set goto [lindex $body 0]
   set tmp [lindex $body 0]
   foreach {cmd label} [lrange $body 1 end] {
      if {$label == ""} {
         set label default
      }
      lappend tmp "$cmd; goto [list $label]" $label
   }
   lappend tmp break
   uplevel while 1 "{switch -- \$goto [list $tmp]}"
   rename goto ""
}

proc input {args} {
   foreach {var prompt} $args {
      upvar $var myvar
      puts -nonewline $prompt
      flush stdout
      gets stdin myvar
   }
}

proc varassign {body varlist} {
	foreach var $varlist {
		global $var
		set $var $body
	}
}

proc empty {arg} {
   upvar 1 $arg var
   expr {$var == {}}
}

proc parse_templ templ {
	set l_except [regexp -all -inline -- {\[\[.*?\]\]} $templ]
	set d_except {}
	foreach except $l_except {
		lappend d_except $except except°[incr except_nr]
	}
	set templ [string map $d_except $templ]
	set s_templ [split [string trim [string map {|| | {| |} |} $templ] {{}}] |]
	set l_key_var [list TEMPLATE [list [lindex $s_templ 0]]]
	foreach item [lrange $s_templ 1 end] {
		if {[string first = $item] == -1} {
			lappend l_key_var [list [incr item_nr] $item]
		} else {
			lappend l_key_var [list [
				lindex [set s_item [split $item =]] 0] [join [lrange $s_item 1 end] =
			]]
			if {[string is integer [lindex $s_item 0]] == 1} {incr item_nr}
		}
	}
	foreach key_var [join $l_key_var] {
		lappend parse_templ [string trim [string map [lreverse $d_except] $key_var]]
	}
	return $parse_templ
}

proc rex {vars value indices param content regex} {
   foreach var [split $vars ,] index [split $indices ,] {
      global $var
      if {      $param == 0}    {
         set $var [regexp                    -- $regex $content]
         return $var
      } elseif {$param == "l"}  {
         set $var [regexp              -line -- $regex $content]
         return $var
      } elseif {$param == "i"}  {
         set $var [regexp      -inline       -- $regex $content]
      } elseif {$param == "il"} {
         set $var [regexp      -inline -line -- $regex $content]
      } elseif {$param == "a"}  {
         set $var [regexp -all               -- $regex $content]
         return $var
      } elseif {$param == "al"} {
         set $var [regexp -all         -line -- $regex $content]
         return $var
      } elseif {$param == "ai"} {
         set $var [regexp -all -inline       -- $regex $content]
      } elseif {$param == 1}    {
         set $var [regexp -all -inline -line -- $regex $content]
      }
      upvar $var myvar
      if {$value == "v"} {
         set myvar [dict values $myvar]
      }
      if [string is entier -strict $index] {
         set $var [lindex $myvar $index]
      } else {
         regexp -- {(.*)-(.*)} $indices -- i e
         set items [lindex $myvar $i]
         set z $i
         set f [expr {$i + $e}]
         foreach item $myvar {
            incr z
            if {$z == $f} {
               lappend items [lindex $myvar $f]
               set f [expr {$f + $e}]
            }
         }
         set t [lindex $items end]
         if [empty t] {
            set items [lreplace $items end end]
         }
         set $var $items
      }
   }
}

proc items {var str start step} {
   upvar $var myvar
   set i 0
   set e {}
   lappend e [lindex $str $start]
   foreach d $str {
      if {$i == [expr $start + $step]} {
         lappend e $d
         lassign 0 i start
      }
      incr i
      set myvar $e
   }
}

proc backlink {var top title} {
   global wiki query
   upvar $var myvar
   set ls {}
   foreach item [
      dict values [
         string map {,ns { ns} ,title { title}} [
            string map {\"pageid\" pageid \"ns\" ns \"title\" title} [
               regexp -all -inline -- {\{(\"pageid\".+?)\}} [
                  post $wiki {*}$query / list backlinks / bltitle $title
               ]
            ]
         ]
      ]
   ] {
      lappend ls [dict get [join [split $item :]] $top]
   }
   set myvar $ls
}

proc backlinks {bltitle ns} {
	global wiki query
	set bl {}
	cont {ret1 {
		foreach item [get $ret1 query backlinks] {
			dict with item {
				lappend bl $title
			}
		}
	}} {*}$query / list backlinks / bltitle $bltitle / blnamespace $ns / bllimit 5000
	return $bl
}

proc utf8 {hex} {
	set hex [string map {% {}} $hex]
	encoding convertfrom utf-8 [binary decode hex $hex]
}

proc urldecode str {
	set str [string map [list + { } "\\" "\\\\"] $str]
	regsub -all {(%[0-9A-Fa-f0-9]{2})+} $str {[utf8 \0]} str
	return [subst -novar -noback $str]
}

proc utfconvert i {
	set o {}
	foreach 1 [split $i {}] {
		set 2 [string toupper [format %04x [scan $1 %c]]]
		if {[string length $2] > 4} {append o "&#x$2;"} else {append o $1}
	}
	return $o
}

proc contents {param item section} {
	global contents wiki get
	if {$section eq {x}} {
		set contents [content [post $wiki {*}$get / [expr {$param eq {id}?{pageids}:$param eq {t}?{titles}:{}}] $item / utf8]]
	} else {
		set contents [content [post $wiki {*}$get / [expr {$param eq {id}?{pageids}:$param eq {t}?{titles}:{}}] $item / rvsection $section / utf8]]
	}
}

proc conts {param item section} {
	global wiki get
	if {$section eq {x}} {
		return [content [post $wiki {*}$get / [expr {$param eq {id}?{pageids}:$param eq {t}?{titles}:{}}] $item / utf8]]
	} else {
		return [content [post $wiki {*}$get / [expr {$param eq {id}?{pageids}:$param eq {t}?{titles}:{}}] $item / rvsection $section / utf8]]
	}
}

proc conts2 {param item section} {
	global wiki get
	if {$section eq {x}} {
		return [content [post $wiki {*}$get / [expr {$param eq {id}?{pageids}:$param eq {t}?{titles}:{}}] $item / utf8]]
	} else {
		return [content [post $wiki {*}$get / [expr {$param eq {id}?{pageids}:$param eq {t}?{titles}:{}}] $item / rvsection $section / utf8]]
	}
}

proc read_file {fi var} {
	global $var
	set $var [string trim [read [set f [open $fi r]]]] ; close $f
	return File\ $fi\ read...\n
}

proc save_file {fi content} {
	set f [open $fi w] ; puts $f $content ; close $f
	return File\ $fi\ saved...\n
}

proc append_file {fi content} {
	set f [open $fi a] ; puts $f $content ; close $f
	return File\ $fi\ appended...\n
}

proc prepend_file {fi content} {
	set oldcontent [read [set f [open $fi r]]] ; close $f
	set f [open $fi w] ; puts $f [string trim $content\n$oldcontent] ; close $f
	return File\ $fi\ prepended...\n
}

proc decr {val} {
	global $val
	incr $val -1
}

proc clocks {var} {
	global tsstart
	clock format $tsstart -format $var -timezone :Europe/Berlin -locale de
}

proc lrepl {listVariable key value} {
	upvar 1 $listVariable var
	set idx [lsearch -exact $var $key]
	set var [lreplace $var $idx $idx $value]
}

proc lremove {listVariable value} {
	upvar 1 $listVariable var
	set idx [lsearch -exact $var $value]
	set var [lreplace $var $idx $idx]
}

proc lremoveglob {listVariable value} {
	upvar 1 $listVariable var
	set idx [lsearch -glob $var $value]
	set var [lreplace $var $idx $idx]
}

proc pagecat {lemma} {
	global wiki query
	set pagecat {}
	catch {foreach cat [page [post $wiki {*}$query / prop categories / titles $lemma / cllimit max] categories] {
		dict with cat {lappend pagecat $title}
	}}
	return $pagecat
}

proc pagecatid {pageid} {
	global wiki query
	set pagecatid {}
	catch {foreach cat [page [post $wiki {*}$query / prop categories / pageids $pageid / cllimit max] categories] {
		dict with cat {lappend pagecatid $title}
	}}
	return $pagecatid
}

proc cat {catlemma catns} {
	global wiki query
	set catmems {}
	if {$catns eq {x}} {set catns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$catns eq {-kat}} {set catns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|15|100|101|828|829}
	cont {ret1 {
		foreach item [get $ret1 query categorymembers] {
			dict with item {
				lappend catmems $title
			}
		}
	}} {*}$query / list categorymembers / cmtitle $catlemma / cmnamespace $catns / cmlimit max
	return $catmems
}

#proc cat {catlemma catnss} {
#	global catmems wiki get
#	if {$catnss eq {*}} {set catnss [dict keys [get [post $wiki {*}$get / meta siteinfo / siprop namespaces] query namespaces]]}
#	foreach cats [catmem [post $wiki {*}$get / list categorymembers / cmtitle $catlemma / cmlimit 5000]] {
#		foreach catns $catnss {
#		   dict with cats {if {$ns == $catns} {lappend catmemlist $title}}
#	   }
#  }
#   set catmems $catmemlist
#}

proc deepcat {ldeepcatlemma deepcatns} {
	global wiki query
	foreach deepcatlemma $ldeepcatlemma {
		lassign [list [list $deepcatlemma] [list $deepcatlemma] {}] lcat nlcat dlcat
		for {set x 1} {$x < 100} {incr x} {
			foreach 2 $nlcat {
				set 02 [cat $2 14]
				if ![empty 02] {
					foreach 0 $02 {
						if {$0 ni $lcat} {lappend dlcat $0}
						lappend lcat $0
					}
				}
			}
			lassign [list [lsort -unique $dlcat] {}] nlcat dlcat
		}
		lappend llcat $lcat
	}
	foreach cat [lsort -unique [join $llcat]] {lappend catmems [cat $cat $deepcatns]}
	return [lsort -unique [join $catmems]]
}

proc SCAT SCAT {
	set conts [split [regsub -all {<!--.*?-->} [conts t $SCAT x] {}] \n]
	foreach line $conts {
		if ![string first * [string trim $line]] {
			regexp -- {\[\[:(.*?)\]\]} $line -- cat
			set key [string index $line end-1]
			if {$key eq {0}} {set key -}
			dict lappend dcat $key [string range $cat 10 end]
		}
	}
	foreach {key lval} $dcat {
		switch $key {
			-			{
							lappend pcatdb $lval
						}
			+			{
							lappend pcatdb $lval
							foreach val $lval {
								lappend pcatdb [dcat list $val 14]
							}
						}
			default	{
							set i 0
							while {$key != $i} {
								lappend dpcatdb $lval
								incr i
								foreach val $lval {
									lappend dpcatdb [scat $val 14]
								}
								set lval [join $dpcatdb]
								set dpcatdb {}
							}
							lappend pcatdb $lval
						}
		}
	}
	foreach cat [lsort -unique [join $pcatdb]] {
		lappend catdb Kategorie:$cat
	}
	return $catdb
}

proc sqlmask lcat {
   set returnlcat {}
   foreach cat $lcat {lappend returnlcat [string map {{ } _ {\'} {\'} {'} {\'}} $cat]}
   return $returnlcat
}

proc sqldemask lcat {
   set returnlcat {}
   foreach cat $lcat {lappend returnlcat [string map {_ { } {\'} {'}} $cat]}
   return $returnlcat
}

proc page_title pgid {
	set db [get_db dewiki]
	mysqlreceive $db "
		select page_namespace, page_title
		from page
		where page_id = $pgid
	;" {pgns pgt} {
		set pgt [string trimleft [dnstons $pgns]:[sql -> $pgt] :]
	}
	mysqlclose $db
	return $pgt
}

proc pagenamelister {sqllist ns} {
	if {$ns eq {0}} {
		foreach item $sqllist {
			if ![lindex $item 0] {lrepl sqllist $item [lrange $item 1 end]}
		}
	} elseif {$ns eq {p}} {
		foreach item $sqllist {
			switch [lindex $item 0] {
				    0	{lrepl sqllist $item [lrange $item 1 end]}
				    4	{lrepl sqllist $item Wikipedia:[lrange $item 1 end]}
				    6	{lrepl sqllist $item Datei:[lrange $item 1 end]}
				    8	{lrepl sqllist $item MediaWiki:[lrange $item 1 end]}
				   10	{lrepl sqllist $item Vorlage:[lrange $item 1 end]}
				   12	{lrepl sqllist $item Hilfe:[lrange $item 1 end]}
				   14	{lrepl sqllist $item Kategorie:[lrange $item 1 end]}
				  100	{lrepl sqllist $item Portal:[lrange $item 1 end]}
			}
		}
	} elseif {$ns eq {x}} {
		foreach item $sqllist {
			switch [lindex $item 0] {
				    0	{lrepl sqllist $item [lrange $item 1 end]}
				    1	{lrepl sqllist $item Diskussion:[lrange $item 1 end]}
				    2	{lrepl sqllist $item Benutzer:[lrange $item 1 end]}
				    3	{lrepl sqllist $item "Benutzer Diskussion:[lrange $item 1 end]"}
				    4	{lrepl sqllist $item Wikipedia:[lrange $item 1 end]}
				    5	{lrepl sqllist $item "Wikipedia Diskussion:[lrange $item 1 end]"}
				    6	{lrepl sqllist $item Datei:[lrange $item 1 end]}
				    7	{lrepl sqllist $item "Datei Diskussion:[lrange $item 1 end]"}
				    8	{lrepl sqllist $item MediaWiki:[lrange $item 1 end]}
				    9	{lrepl sqllist $item "MediaWiki Diskussion:[lrange $item 1 end]"}
				   10	{lrepl sqllist $item Vorlage:[lrange $item 1 end]}
				   11	{lrepl sqllist $item "Vorlage Diskussion:[lrange $item 1 end]"}
				   12	{lrepl sqllist $item Hilfe:[lrange $item 1 end]}
				   13	{lrepl sqllist $item "Hilfe Diskussion:[lrange $item 1 end]"}
				   14	{lrepl sqllist $item Kategorie:[lrange $item 1 end]}
				   15	{lrepl sqllist $item "Kategorie Diskussion:[lrange $item 1 end]"}
				  100	{lrepl sqllist $item Portal:[lrange $item 1 end]}
				  101	{lrepl sqllist $item "Portal Diskussion:[lrange $item 1 end]"}
				  828	{lrepl sqllist $item Modul:[lrange $item 1 end]}
				  829	{lrepl sqllist $item "Modul Diskussion:[lrange $item 1 end]"}
				 2300	{lrepl sqllist $item Gadget:[lrange $item 1 end]}
				 2301	{lrepl sqllist $item "Gadget Diskussion:[lrange $item 1 end]"}
				 2302	{lrepl sqllist $item Gadget-Definition:[lrange $item 1 end]}
				 2303	{lrepl sqllist $item "Gadget-Definition Diskussion:[lrange $item 1 end]"}
				 2600	{lrepl sqllist $item Thema:[lrange $item 1 end]}
			}
		}
	}
	return $sqllist
}

proc nstodns ns {
	switch $ns {
		 Diskussion								{return    1}
		 Benutzer								{return    2}
		{Benutzer Diskussion}				{return    3}
		 Wikipedia								{return    4}
		{Wikipedia Diskussion}				{return    5}
		 Datei									{return    6}
		{Datei Diskussion}					{return    7}
		 MediaWiki								{return    8}
		{MediaWiki Diskussion}				{return    9}
		 Vorlage									{return   10}
		{Vorlage Diskussion}					{return   11}
		 Hilfe									{return   12}
		{Hilfe Diskussion}					{return   13}
		 Kategorie								{return   14}
		{Kategorie Diskussion}				{return   15}
		 Portal									{return  100}
		{Portal Diskussion}					{return  101}
		 Modul									{return  828}
		{Modul Diskussion}					{return  829}
		 Gadget									{return 2300}
		{Gadget Diskussion}					{return 2301}
		 Gadget-Definition					{return 2302}
		{Gadget-Definition Diskussion}	{return 2303}
		 Thema									{return 2600}
		 default									{return    0}
	}
}

proc dnstons ns {
	switch $ns {
		   1		{return 	Diskussion}
		   2		{return 	Benutzer}
		   3		{return {Benutzer Diskussion}}
		   4		{return  Wikipedia}
		   5		{return {Wikipedia Diskussion}}
		   6		{return  Datei}
		   7		{return {Datei Diskussion}}
		   8		{return  MediaWiki}
		   9		{return {MediaWiki Diskussion}}
		  10		{return  Vorlage}
		  11		{return {Vorlage Diskussion}}
		  12		{return  Hilfe}
		  13		{return {Hilfe Diskussion}}
		  14		{return  Kategorie}
		  15		{return {Kategorie Diskussion}}
		 100		{return  Portal}
		 101		{return {Portal Diskussion}}
		 828		{return  Modul}
		 829		{return {Modul Diskussion}}
		2300		{return  Gadget}
		2301		{return {Gadget Diskussion}}
		2302		{return  Gadget-Definition}
		2303		{return {Gadget Definition Diskussion}}
		2600		{return  Thema}
		default	{return {}}
	}
}

proc sqlcat0 {cat ns} {
	global db
   return [pagenamelister [lsort -unique [sqldemask [
      mysqlsel $db "
         select   page_namespace, page_title from page, categorylinks
         where    cl_from = page_id and cl_to = '[sqlmask [list $cat]]'
      ;" -list
      mysqlclose $db
   ]]] $ns]
}

proc sqlcat {cat catns} {
   global db
   return [lsort -unique [sqldemask [
      mysqlsel $db "
         select   page_title from page, categorylinks
         where    page_id = cl_from and cl_to = '[sqlmask [list $cat]]' and page_namespace = $catns
      ;" -list
   ]]]
}

proc sqlcat_id {cat catns} {
   global db
   return [lsort -unique [
      mysqlsel $db "
         select   page_id from page, categorylinks
         where    page_id = cl_from and cl_to = '[sqlmask [list $cat]]' and page_namespace = $catns
      ;" -list
   ]]
}

proc scat {cat ns} {
	global db
	set lpt {}
	set db [get_db dewiki]
	if {$ns == -14} {
		regsub -- {Kategorie:} $cat {} cat
		mysqlreceive $db "
			select page_id
			from page, categorylinks
			where cl_from = page_id and page_namespace != 14 and cl_to = '[sql <- $cat]'
			order by page_title
		;" pid {
			lappend lpt $pid
		}
	} else {
		mysqlreceive $db "
			select page_title
			from page, categorylinks
			where cl_from = page_id and page_namespace in ($ns) and cl_to = '[sql <- $cat]'
			order by page_title
		;" pt {
			lappend lpt [sql -> $pt]
		}
	}
	mysqlclose $db
	return $lpt
}

proc sscat {cat ns} {
	global db
	set lpt {}
	set db [get_db dewiki]
	mysqlreceive $db "
		select page_title
		from page, categorylinks
		where cl_from = page_id and page_namespace in ($ns) and cl_to = '[sql <- $cat]'
		order by page_title
	;" pt {
		lappend lpt '[sql <- $pt]'
	}
	mysqlclose $db
	return [join $lpt ,]
}

proc dcat {out cat ns} {
#	set db [get_db enwiki] ; set db0 dewiki_p
	set lpt {}
	set dcat [set lcat '[sql <- $cat]']
	while {$lcat ne {}} {
		set lcat1 {}
		set db [get_db dewiki]
		mysqlreceive $db "
			select page_title
			from page, categorylinks
			where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
		;" pt {
			set lcat {}
			lappend dcat '[sql <- $pt]'
			lappend lcat1 '[sql <- $pt]'
		}
		mysqlclose $db
		set lcat $lcat1
	}
	set db [get_db dewiki]
	mysqlreceive $db "
		select [expr {$out in {listid sqlid} ? {page_id} : {page_title}}]
		from page, categorylinks
		where cl_from = page_id and page_namespace in ($ns) and cl_to in ([join $dcat ,])
		order by [expr {$out in {listid sqlid} ? {page_id} : {page_title}}]
	;" pt {
		switch $out {
			list		{lappend lpt [sql -> $pt]}
			listid	{lappend lpt $pt}
			sql		{lappend lpt '[sql <- $pt]'}
			sqlid		{lappend lpt $pt}
			sqllist	{lappend lpt [sql <- $pt]}
		}
	}
	mysqlclose $db
	set lpt [lsort -unique $lpt]
	if {$out in {sql sqlid}} {return [join $lpt ,]} else {return $lpt}
}

proc wdcat {wiki out cat ns} {
#	set db [get_db enwiki] ; set db0 dewiki_p
	set lpt {}
	set dcat [set lcat '[sql <- $cat]']
	while {$lcat ne {}} {
		set lcat1 {}
		set db [get_db $wiki]
		mysqlreceive $db "
			select page_title
			from page, categorylinks
			where cl_from = page_id and page_namespace = 14 and cl_to in ([join $lcat ,])
		;" pt {
			set lcat {}
			lappend dcat '[sql <- $pt]'
			lappend lcat1 '[sql <- $pt]'
		}
		mysqlclose $db
		set lcat $lcat1
	}
	set db [get_db $wiki]
	mysqlreceive $db "
		select [expr {$out in {listid sqlid} ? {page_id} : {page_title}}]
		from page, categorylinks
		where cl_from = page_id and page_namespace in ($ns) and cl_to in ([join $dcat ,])
		order by [expr {$out in {listid sqlid} ? {page_id} : {page_title}}]
	;" pt {
		switch $out {
			list		{lappend lpt [sql -> $pt]}
			listid	{lappend lpt $pt}
			sql		{lappend lpt '[sql <- $pt]'}
			sqlid		{lappend lpt $pt}
			sqllist	{lappend lpt [sql <- $pt]}
		}
	}
	mysqlclose $db
	set lpt [lsort -unique $lpt]
	if {$out in {sql sqlid}} {return [join $lpt ,]} else {return $lpt}
}

proc dcat2 cat {
	set lclto '$cat'
	while 1 {
		set olclto [lsort -unique $lclto]
		set db [get_db dewiki]
		mysqlreceive $db "
			select page_title
			from page join categorylinks on cl_from = page_id
			where page_namespace = 14 and cl_to in ([join $lclto ,])
		;" pt {
			lappend lclto '[sql <- $pt]'
		}
		mysqlclose $db
		set lclto [lsort -unique $lclto]
		puts [llength $lclto]
		if {$lclto eq $olclto} {break}
	}
	foreach clto $lclto {
		lappend nlclto [sql -> [string range $clto 1 end-1]]
	}
	return $nlclto:[llength $nlclto]
}

proc sqldeepcat {cat catns} {
   global db
   set lcat14 [format {{%s}} $cat]
   lassign {0 1} olenlcat14 lenlcat14
   while {$lenlcat14 != $olenlcat14} {
      set olenlcat14 $lenlcat14
      set lcat14 [split $lcat14]
      foreach cat14 [join $lcat14] {lappend lcat14 [sqlcat $cat14 14]}
      set lcat14 [lsort -unique [join $lcat14]]
      set lenlcat14 [llength $lcat14]
   }
   foreach cat14 $lcat14 {lappend lcat [sqlcat $cat14 $catns]}
   return [lsort -unique [join $lcat]]
}

proc sqldeepcat_id {cat catns} {
   global db
   set lcat14 [format {{%s}} $cat]
   lassign {0 1} olenlcat14 lenlcat14
   while {$lenlcat14 != $olenlcat14} {
      set olenlcat14 $lenlcat14
      set lcat14 [split $lcat14]
      foreach cat14 [join $lcat14] {lappend lcat14 [sqlcat $cat14 14]}
      set lcat14 [lsort -unique [join $lcat14]]
      set lenlcat14 [llength $lcat14]
   }
   foreach cat14 $lcat14 {lappend lcat [sqlcat_id $cat14 $catns]}
   return [lsort -unique [join $lcat]]
}

proc portalcat {ldeepcatlemma} {
	set alphabet {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
	foreach deepcatlemma $ldeepcatlemma {
		lassign [list [list $deepcatlemma] [list $deepcatlemma] {}] lcat nlcat dlcat
		for {set x 1} {$x < 100} {incr x} {
			foreach 2 $nlcat {
				set 2 [string map {{ } _ ~ ~~~~~ / ~ ! ´´´´} [string replace $2 0 9]]
				if {[set first [string index $2 0]] ni $alphabet} {set first 1}
				if {[catch {set 02 [read [set f [open cat-db/$first/$2 r]]] ; close $f}] == 1} {set 02 {}}
				if ![empty 02] {
					foreach 0 $02 {
						if {$0 ni $lcat} {lappend dlcat $0}
						lappend lcat $0
					}
				}
			}
			lassign [list [lsort -unique $dlcat] {}] nlcat dlcat
		}
		lappend llcat $lcat
	}
	return [join $llcat]
}

#proc deepcat {deepcat namespace {exclude {}}} {
#	global wiki catmem
#	set return {}
#	set cont {}
#	control::do {
#		set ret1 [post $wiki {*}$catmem / cmtitle $deepcat / cmnamespace $namespace|14 / {*}$cont]
#		foreach item [catmem $ret1] {
#			dict with item {
#				switch $ns 14 {
#					if {$title ni $exclude} {
						#dict set return $title {};##
#						lappend return {*}[deepcat $title $namespace $exclude]
#					}
#				} $namespace {
#					if {[string index $sortkey 0] ne {!}} {
						#dict set return $title {}
#						lappend return $title
#					}
#				}
#			}
#		}
#	} while {![catch {set cont [get $ret1 query-continue categorymembers]}]}
#	return $return
#}

proc getHTML url {
	while 1 {
		if ![catch {
			after 1000
#			puts "\nTrial [incr i]: $url"
#			puts "\nTrial [incr i]: [string range $url 0 49]"
			puts "\nTrial [incr i]: [string range $url 0 74][expr {[string length $url] > 75 ? {...} : {}}]"
			set ch [curl::init]
			$ch configure -useragent TaxonBot/1.0 -url $url -followlocation 1 -bodyvar body
			$ch perform
			$ch cleanup
		}] {break}
	}
	return [encoding convertfrom $body]
}

proc getHTML2 { url } {
	::http::register https 443 ::tls::socket
#	WARN: THE # AFTER -SSL3 TO ALLOW TO RUN OF SCRIPT
#	IF 'UNCOMMENTED' I GET THE NEXT POSTED ERRORS
	tls::init -tls1 1 -ssl2 0 -ssl3 0 #-tls1.1 0 -tls1.2 0
	set token [::http::geturl $url -headers [list Accept-Encoding ""]]
#  puts $token
	set status [http::status $token]
#  puts $status
   set meta [http::meta $token]
#  puts $meta
   if ![catch {set redir [dict get $meta Location]}] {
#		puts "Redir to $redir"
   	return [getHTML $redir]
   }
	set data [::http::data $token]
# puts $data
	::http::cleanup $token
	http::unregister https
	return $data
}

proc links {lemma ns} {
	global wiki query
	lassign {} litem ltitle
	catch {set litem [page [post $wiki {*}$query / prop links / titles $lemma / plnamespace $ns / pllimit 5000] links]}
	foreach item $litem {
		dict with item {
			lappend ltitle $title
		}
	}
	return $ltitle
}

proc linkshere lemma {
   set db [get_db dewiki]
	set lpt [mysqlsel $db "
		select page_title
		from page join pagelinks on pl_from = page_id
		where !page_namespace and !pl_from_namespace and !pl_namespace and pl_title = '[sql <- $lemma]'
	;" -flatlist]
	mysqlclose $db
return $lpt
}

proc langlinks {lemma lang} {
	global wiki query
	return [dict get [join [page [post $wiki {*}$query / prop langlinks / titles $lemma / lllang $lang] langlinks]] *]
}

#				    4	{lappend lpt Wikipedia:[string map {_ { }} $pt]}
#				    6	{lappend lpt Datei:[string map {_ { }} $pt]}
#				    8	{lappend lpt MediaWiki:[string map {_ { }} $pt]}
#				   10	{lappend lpt Vorlage:[string map {_ { }} $pt]}
#				   12	{lappend lpt Hilfe:[string map {_ { }} $pt]}
#				   14	{lappend lpt Kategorie:[string map {_ { }} $pt]}
#				  100	{lappend lpt Portal:[string map {_ { }} $pt]}

proc nsidsort {ns pns pgid} {
	if {$pns ==    0 && ($ns eq    {0} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})}	{return $pgid}
	if {$pns ==    1 && ($ns eq    {1} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==    2 && ($ns eq    {2} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==    3 && ($ns eq    {3} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==    4 && ($ns eq    {4} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} 	{return $pgid}
	if {$pns ==    5 && ($ns eq    {5} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==    6 && ($ns eq    {6} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} 	{return $pgid}
	if {$pns ==    7 && ($ns eq    {7} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==    8 && ($ns eq    {8} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} 	{return $pgid}
	if {$pns ==    9 && ($ns eq    {9} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==   10 && ($ns eq   {10} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} 	{return $pgid}
	if {$pns ==   11 && ($ns eq   {11} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==   12 && ($ns eq   {12} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} 	{return $pgid}
	if {$pns ==   13 && ($ns eq   {13} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==   14 && ($ns eq   {14} || $ns eq {x} || 						$ns eq {p})} 	{return $pgid}
	if {$pns ==   15 && ($ns eq   {15} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==  100 && ($ns eq  {100} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} 	{return $pgid}
	if {$pns ==  101 && ($ns eq  {101} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==  828 && ($ns eq  {828} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns ==  829 && ($ns eq  {829} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns == 2300 && ($ns eq {2300} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns == 2301 && ($ns eq {2301} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns == 2302 && ($ns eq {2302} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns == 2303 && ($ns eq {2303} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
	if {$pns == 2600 && ($ns eq {2600} || $ns eq {x} || $ns eq {-kat})} 						{return $pgid}
}

proc nssort {ns pns pt} {
	if {$pns ==    0 && ($ns eq    {0} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} {return [string map {_ { }} $pt]}
	if {$pns ==    1 && ($ns eq    {1} || $ns eq {x} || $ns eq {-kat})} {return Diskussion:[string map {_ { }} $pt]}
	if {$pns ==    2 && ($ns eq    {2} || $ns eq {x} || $ns eq {-kat})} {return Benutzer:[string map {_ { }} $pt]}
	if {$pns ==    3 && ($ns eq    {3} || $ns eq {x} || $ns eq {-kat})} {return "Benutzer Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==    4 && ($ns eq    {4} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} {return Wikipedia:[string map {_ { }} $pt]}
	if {$pns ==    5 && ($ns eq    {5} || $ns eq {x} || $ns eq {-kat})} {return "Wikipedia Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==    6 && ($ns eq    {6} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} {return Datei:[string map {_ { }} $pt]}
	if {$pns ==    7 && ($ns eq    {7} || $ns eq {x} || $ns eq {-kat})} {return "Datei Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==    8 && ($ns eq    {8} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} {return MediaWiki:[string map {_ { }} $pt]}
	if {$pns ==    9 && ($ns eq    {9} || $ns eq {x} || $ns eq {-kat})} {return "MediaWiki Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==   10 && ($ns eq   {10} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} {return Vorlage:[string map {_ { }} $pt]}
	if {$pns ==   11 && ($ns eq   {11} || $ns eq {x} || $ns eq {-kat})} {return "Vorlage Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==   12 && ($ns eq   {12} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} {return Hilfe:[string map {_ { }} $pt]}
	if {$pns ==   13 && ($ns eq   {13} || $ns eq {x} || $ns eq {-kat})} {return "Hilfe Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==   14 && ($ns eq   {14} || $ns eq {x} || 						$ns eq {p})} {return Kategorie:[string map {_ { }} $pt]}
	if {$pns ==   15 && ($ns eq   {15} || $ns eq {x} || $ns eq {-kat})} {return "Kategorie Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==  100 && ($ns eq  {100} || $ns eq {x} || $ns eq {-kat} || $ns eq {p})} {return Portal:[string map {_ { }} $pt]}
	if {$pns ==  101 && ($ns eq  {101} || $ns eq {x} || $ns eq {-kat})} {return "Portal Diskussion:[string map {_ { }} $pt]"}
	if {$pns ==  828 && ($ns eq  {828} || $ns eq {x} || $ns eq {-kat})} {return Modul:[string map {_ { }} $pt]}
	if {$pns ==  829 && ($ns eq  {829} || $ns eq {x} || $ns eq {-kat})} {return "Modul Diskussion:[string map {_ { }} $pt]"}
	if {$pns == 2300 && ($ns eq {2300} || $ns eq {x} || $ns eq {-kat})} {return Gadget:[string map {_ { }} $pt]}
	if {$pns == 2301 && ($ns eq {2301} || $ns eq {x} || $ns eq {-kat})} {return "Gadget Diskussion:[string map {_ { }} $pt]"}
	if {$pns == 2302 && ($ns eq {2302} || $ns eq {x} || $ns eq {-kat})} {return Gadget-Definition:[string map {_ { }} $pt]}
	if {$pns == 2303 && ($ns eq {2303} || $ns eq {x} || $ns eq {-kat})} {return "Gadget-Definition Diskussion:[string map {_ { }} $pt]"}
	if {$pns == 2600 && ($ns eq {2600} || $ns eq {x} || $ns eq {-kat})} {return Thema:[string map {_ { }} $pt]}
}

proc catids {cat ns} {
	set db [get_db dewiki]
	set cat [string map {{ } _ {\'} {\'} {'} {\'}} $cat]
	set lpgid {}
	mysqlreceive $db "select page_namespace, page_id from page, categorylinks where cl_from = page_id and cl_to = '$cat' order by page_title;" {pns pgid} {
		if {[set pgid [nsidsort $ns $pns $pgid]] ne {}} {lappend lpgid $pgid}
	}
	mysqlclose $db
	return $lpgid
}

proc catitems {cat ns} {
	set db [get_db dewiki]
	set cat [string map {{ } _ {\'} {\'} {'} {\'}} $cat]
	set lpt {}
	mysqlreceive $db "select page_namespace, page_title from page, categorylinks where cl_from = page_id and cl_to = '$cat' order by page_title;" {pns pt} {
		if {[set pt [nssort $ns $pns $pt]] ne {}} {lappend lpt $pt}
	}
	mysqlclose $db
	return $lpt
}

proc templids {templ ns} {
	set db [get_db dewiki]
	set templ [string map {{ } _ {\'} {\'} {'} {\'}} $templ]
	set lpgid {}
	mysqlreceive $db "select page_namespace, page_id from page, templatelinks where tl_from = page_id and tl_title = '$templ' order by page_title;" {pns pgid} {
		if {[set pgid [nsidsort $ns $pns $pgid]] ne {}} {lappend lpgid $pgid}
	}
	mysqlclose $db
	return $lpgid
}

proc template {template ns} {
	set db [get_db dewiki]
	set template [string map {{ } _ {\'} {\'} {'} {\'}} $template]
	set lpt {}
	mysqlreceive $db "select page_namespace, page_title from page, templatelinks where tl_from = page_id and tl_title = '$template' order by page_title;" {pns pt} {
		if {[set pt [nssort $ns $pns $pt]] ne {}} {lappend lpt $pt}
	}
	mysqlclose $db
	return $lpt
}

proc template0 {template ns} {
	set db [get_db dewiki]
	set template [string map {{ } _ {\'} {\'} {'} {\'}} $template]
#	set lpt {}
	set lpt [mysqlsel $db "
		select page_title from page join templatelinks on tl_from = page_id
		where page_namespace = $ns and tl_from_namespace = $ns and tl_namespace = 10
			and tl_title = '$template'
	;" -flatlist]
	mysqlclose $db
	return $lpt
}

proc template1 {template ns} {
	global wiki query
	if {$ns eq {x}} {set ns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-kat}} {set ns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|15|100|101|828|829}
	cont {ret1 {
		foreach item [get $ret1 query embeddedin] {
			dict with item {
				lappend ltitle $title
			}
		}
	}} {*}$query / list embeddedin / eititle $template / einamespace $ns / eilimit 5000
	return $ltitle
}

proc template2 {template ns} {
	global wiki query
	if {$ns eq {x}} {set ns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-kat}} {set ns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|15|100|101|828|829}
	set litem [get [post $wiki {*}$query / list embeddedin / eititle $template / einamespace $ns / eilimit max] query embeddedin]
	set ltitle {}
	foreach item $litem {
		dict with item {
			lappend ltitle $title
		}
	}
	return $ltitle
}

proc missing {lemma} {
	global wiki query
	if {{missing} in [dict keys [page [post $wiki {*}$query / prop info / titles $lemma]]]} {
		return 1
	} else {
		return 0
	}
}

proc redirect {lemma} {
	global wiki query
	if {{redirect} in [dict keys [page [post $wiki {*}$query / prop info / titles $lemma]]]} {
		return 1
	} else {
		return 0
	}
}

proc redir {ns page} {
	global lang
	set db [get_db $lang\wiki]
	set target [mysqlsel $db "
		select rd_namespace, rd_title from redirect join page on rd_from = page_id
		where page_namespace = $ns and page_title = '[sql <- $page]'
	;" -flatlist]
	mysqlclose $db
	if ![empty target] {
		return $target
	} else {
		return [list $ns $page]
	}
}

proc ns {lemma} {
	global wiki query
	return [dict get [page [post $wiki {*}$query / prop info / titles $lemma]] ns]
}

proc sections lemma {
	global wiki parse
	return [get [post $wiki {*}$parse / page $lemma / prop sections] parse sections]
}

proc regexvar str {
	return [string map [list \{ \\\{ \} \\\} \[ \\\[ \] \\\] {"} {\"} ( \\( ) \\) | \\| "\\" "\\\\"] $str]
}

proc matchtemplate {lemma match} {
	global wiki query
	set eq 0
	catch {
		set templ [dict get [join [page [post $wiki {*}$query / prop templates / titles $lemma / tltemplates $match] templates]] title]
		if {$match eq $templ} {
			incr eq
		}
	}
	return $eq
}

proc inuse lemma {
	set eq 0
	if {[matchtemplate $lemma {Vorlage:In Bearbeitung}] || [matchtemplate $lemma Vorlage:InUse] || [matchtemplate $lemma Vorlage:Inuse] || [matchtemplate $lemma {Vorlage:In use}] || [matchtemplate $lemma Vorlage:INUSE] || [matchtemplate $lemma Vorlage:InBearbeitung]} {
		incr eq
	}
	return $eq
}

proc insource {weblink ns} {
	global wiki query
	set ltitle {}
	if {$ns eq {x}} {set ns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-0}} {set ns 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-06}} {set ns 1|2|3|4|5|7|8|9|10|11|12|13|14|15|100|101|828|829}
	set litem [get [
		post $wiki {*}$query / list search / srsearch insource:/$weblink / srprop title / srnamespace $ns / srlimit 5000
	] query search]
	foreach item $litem {
		dict with item {lappend ltitle $title}
	}
	return $ltitle
}

proc intitle {weblink ns} {
	global wiki query
	set ltitle {}
	if {$ns eq {x}} {set ns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-0}} {set ns 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-06}} {set ns 1|2|3|4|5|7|8|9|10|11|12|13|14|15|100|101|828|829}
	set litem [get [
		post $wiki {*}$query / list search / srsearch intitle:/$weblink / srprop title / srnamespace $ns / srlimit 5000
	] query search]
	foreach item $litem {
		dict with item {lappend ltitle $title}
	}
	return $ltitle
}

proc subpageof {weblink ns} {
	global wiki query
	set ltitle {}
	if {$ns eq {x}} {set ns 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-0}} {set ns 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|100|101|828|829}
	if {$ns eq {-06}} {set ns 1|2|3|4|5|7|8|9|10|11|12|13|14|15|100|101|828|829}
	set litem [get [
		post $wiki {*}$query / list search / srsearch subpageof:$weblink / srprop size / srnamespace $ns / srlimit 5000
	] query search]
	foreach item $litem {
		dict with item {lappend ltitle [list $size $title]}
	}
	return [lsort -integer -index 0 -decreasing $ltitle]
}

proc blcheck line {
	return [regexp -- {\( ?-LA|-LA ?\)|\( ?BKL|BKL ?\)|\( ?bleiben|bleiben ?\)|\( ?bleibt|bleibt ?\)|\( ?Bleibt|Bleibt ?\)|BNR|\( ?entfernt|entfernt ?\)|\( ?Entfernt|Entfernt ?\)|\( ?erl.|erl. ?\)|\( ?Erl.|Erl. ?\)|\( ?erledigt|erledigt ?\)|\( ?Erledigt|Erledigt ?\)|\( ?gelöscht|gelöscht ?\)|\( ?Gelöscht|Gelöscht ?\)|\( ?geloescht|geloescht ?\)|\( ?Geloescht|Geloescht ?\)|\( ?gel.|gel. ?\)|geSLAt|\( ?LA entfernt|LA entfernt ?\)|\( ?LAE|LAE ?\)|\( ?LAZ|LAZ ?\)|\( ?SLA|SLA ?\)|\( ?URV|URV ?\)|\( ?Wiedergänger|Wiedergänger ?\)|\( ?WL|WL ?\)|\( ?zurückgez|\( ?Zurückgez} $line]
}

proc bltitle line {
	set rexval {}
	regexp -- {\[\[(.*?)[#|\]]} $line -- rexval
	return [string trim [string trimleft $rexval :]]
}

### Wikidata ###

proc guid item {
	foreach digit {8 4 4 4 12} {
		lappend lguid [format %0${digit}X [expr int(rand()*16**$digit)]]
	}
	return $item$[join $lguid -]
}

#neu: d_get_datatype
proc proptype prop {
	global wiki format
	return [get [post $wiki {*}$format / action wbgetentities / ids $prop] entities $prop datatype]
}

proc nickname user {
	global language
	set db [get_db $language\wiki]
	set nickname [mysqlsel $db "
		select up_value
		from user_properties join user on up_user = user_id
		where user_name = '$user' and up_property = 'nickname'
	;" -flatlist]
	mysqlclose $db
	return $nickname
}

proc gender user {
	global language
	set db [get_db $language\wiki]
	set gender [mysqlsel $db "
		select up_value
		from user_properties join user on up_user = user_id
		where user_name = '$user' and up_property = 'gender'
	;" -flatlist]
	mysqlclose $db
	return $gender
}

proc wbsite {item sitelinks summary} {
	global wiki format token
	lassign {} lrsitelinks
	foreach {mainkey result} {sitelinks rsitelinks} {
		if [empty $mainkey] {set $result {} ; continue}
		foreach {key val} [subst $$mainkey] {
			lappend l$result [format {{"site":"%swiki","title":"%s"}} $key $val]
		}
		lappend ldata [format {"%s":[%s]} $mainkey [join [subst $[subst l$result]] ,]]
	}
	set data [format {{%s}} [join $ldata ,]]
	puts [get [post $wiki {*}$format {*}$token / action wbeditentity / id Q$item / data $data / summary "Bot: $summary" / bot true]]
}

proc wbedit {item labels descriptions aliases} {
	global wiki format token
	lassign {} lrlabels lrdescriptions lraliases
	foreach {mainkey result} {labels rlabels descriptions rdescriptions aliases raliases} {
		if [empty $mainkey] {set $result {} ; continue}
		foreach {key val} [subst $$mainkey] {
			lappend l$result [format {{"language":"%s","value":"%s"}} $key $val]
		}
		lappend ldata [format {"%s":[%s]} $mainkey [join [subst $[subst l$result]] ,]]
	}
	set data [format {{%s}} [join $ldata ,]]
	switch $item {
		new 		{
						puts [get [post $wiki {*}$format {*}$token / action wbeditentity / new item / data $data]]
					}
		default	{
						puts [get [post $wiki {*}$format {*}$token / action wbeditentity / id Q$item / data $data]]
					}
	}
}

proc wbadd2 {item prop q ref} {
	global wiki format token
	switch $ref {
		dewiki   {lassign {P143 48183} refprop refq}
	}
	set ref [format {"references":[{"snaks":{"%s":[{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s,"id":"Q%s"},"type":"wikibase-entityid"},"datatype":"%s"}]},"snaks-order":["%s"]}]} $refprop $refprop $refq $refq [proptype $refprop] $refprop]
	set wbadd [format {"id":"Q%s","type":"statement","mainsnak":{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s,"id":"Q%s"},"type":"wikibase-entityid"},"datatype":"%s"}} [guid $item] $prop $q $q [proptype $prop]]
puts "/ claim [format {{%s,%s}} $wbadd $ref] /"
puts :$wbadd:$ref:
#	return [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{%s,%s}} $wbadd $ref] / bot]]
}

proc wbref ref {
	switch $ref {
		dewiki   {lassign [list P143 48183 wikibase-entityid] refprop refq reftype}
	}
	return [format {"references":[{"snaks":{"%s":[{"snaktype":"value","property":"%s","datavalue":{"value":{"entity-type":"item","numeric-id":%s},"type":"%s"},"datatype":"%s"}]}}]} $refprop $refprop $refq $reftype [proptype $refprop]]
}

proc get_q {pt ns} {
	global lang
		set db0 [get_db $lang\wiki]
		set ppv [
			mysqlsel $db0 "
				select pp_value from page_props join page on pp_page = page_id
				where page_title = '[sql <- [join $pt]]' and page_namespace = $ns
			;" -flatlist
		]
		mysqlclose $db0
	return [lindex $ppv end]
}

proc d_get_datatype p {
	global wiki format
	return [get [post $wiki {*}$format / action wbgetentities / ids $p] entities $p datatype]
}

proc d_get_lp ent {
	global wiki format
	return [dict keys [get [post $wiki {*}$format / action wbgetentities / ids $ent] entities $ent claims]]
}

proc d_get_lmainsnak {ent p} {
	global wiki format
	return [get [post $wiki {*}$format / action wbgetclaims / entity $ent / property $p] claims $p]
}

proc d_get_lq {ent p} {
	try {
		switch [d_get_datatype $p] {
			commonsMedia	{
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										lappend lq [dict get $mainsnak mainsnak datavalue value]
									}
								}
			external-id		{
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										lappend lq [dict get $mainsnak mainsnak datavalue value]
									}
								}
			globe-coordinate {
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										set val [dict get $mainsnak mainsnak datavalue value]
										return [lrange [dict values $val] 0 1]
									}
								}
			monolingualtext {
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										lappend lq [dict get $mainsnak mainsnak datavalue value text]
									}
								}
			quantity			{
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										lappend lq [dict get $mainsnak mainsnak datavalue value amount]
									}
								}
			string			{
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										lappend lq [dict get $mainsnak mainsnak datavalue value]
									}
								}
			time				{
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										set val [dict get $mainsnak mainsnak datavalue value]
										dict with val {
											return [list "[lindex [split $time T] 0] $precision"]
										}
									}
								}
			wikibase-item	{
									foreach mainsnak [d_get_lmainsnak $ent $p] {
										lappend lq [dict get $mainsnak mainsnak datavalue value id]
									}
								}
		}
	} on error {} {set lq n/ex}
	return $lq
}

proc d_get_mainsnak {ent p q} {
	foreach mainsnak [d_get_lmainsnak $ent $p] {
		foreach val [d_get_lq $ent $p] {
puts :$val:$q:
			if {$val eq $q} {
puts $mainsnak
				return $mainsnak
			}
		}
	}
}

proc d_get_reftime {ent p q} {
	try {
		return [dict get [join [dict get [join [
			dict get [d_get_mainsnak $ent $p $q] references
		]] snaks P813]] datavalue value time]
	} on error {} {
		return error
	}
}

proc d_get_refdate {ent p q} {
	try {
		return [lindex [split [d_get_reftime $ent $p $q] T] 0]
	} on error {} {
		return error
	}
}

if 0 {
proc d_get_lref {ent p q} {
	try {
		foreach mainsnak [d_get_lmainsnak $ent $p] {
			lappend lsnaks [dict get [join [dict get $mainsnak references]] snaks]
		}
puts $lsnaks
		foreach snaks {*}$lsnaks {
puts $snaks
puts [dict values $snaks]
			set key [dict keys $snaks]
			set lq [dict get [join [dict get $snaks $key]] datavalue value id]
			lappend lref $key $lq
		}
	} on error {} {set lref n/ex}
	return $lref
}
}

proc d_get_guid {ent p q} {
	switch [d_get_datatype $p] {
		commonsMedia	{
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									if {[dict get $mainsnak mainsnak datavalue value] eq $q} {
										return [dict get $mainsnak id]
									}
								}
							}
		external-id		{
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									if {[dict get $mainsnak mainsnak datavalue value] eq $q} {
										return [dict get $mainsnak id]
									}
								}
							}
		globe-coordinate {
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									set val [dict get $mainsnak mainsnak datavalue value]
									if {[lrange [dict values $val] 0 1] eq $q} {
										return [dict get $mainsnak id]
									}
								}
							}
		monolingualtext {
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									if {[dict get $mainsnak mainsnak datavalue value text] eq $q} {
										return [dict get $mainsnak id]
									}
								}
							}
		quantity			{
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									if {[dict get $mainsnak mainsnak datavalue value amount] eq $q} {
										return [dict get $mainsnak id]
									}
								}
							}
		string			{
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									if {[dict get $mainsnak mainsnak datavalue value] eq $q} {
										return [dict get $mainsnak id]
									}
								}
							}
		time				{
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									set val [dict get $mainsnak mainsnak datavalue value]
									dict with val {
										if {[list [lindex [split $time T] 0] $precision] eq $q} {
											return [dict get $mainsnak id]
										}
									}
								}
							}
		wikibase-item	{
								foreach mainsnak [d_get_lmainsnak $ent $p] {
									if {[dict get $mainsnak mainsnak datavalue value id] eq $q} {
										return [dict get $mainsnak id]
									}
								}
							}
	}
}

proc d_set_datavalue {p q} {
	set datatype [d_get_datatype $p]
	if {$q eq {--}} {
		return [format {"datatype":"%s"} $datatype]
	}
	switch $datatype {
		commonsMedia	{
								return [format {
									"datavalue":{
										"value":"%s","type":"string"
									},"datatype":"%s"
								} $q $datatype]
							}
		external-id		{
								return [format {
									"datavalue":{
										"value":"%s","type":"string"
									},"datatype":"%s"
								} $q $datatype]
							}
		globe-coordinate	{
									return [format {
										"datavalue":{
											"value":{
												"latitude":%s,
												"longitude":%s,
												"altitude":null,
												"precision":0.000001,
												"globe":"http://www.wikidata.org/entity/Q2"
											},"type":"globecoordinate"
										},"datatype":"%s"
									} {*}$q $datatype]
								}
		monolingualtext	{
									return [format {
										"datavalue":{
											"value":{
												"text":"%s",
												"language":"%s"
											},"type":"%s"
										},"datatype":"%s"
									} {*}$q $datatype $datatype]
								}
		quantity			{
								set unit [lindex $q 1]
								if {[empty unit] || $unit in {1 --}} {
									set unit {"unit":"1"}
								} else {
									set unit [format {
										"unit":"http://www.wikidata.org/entity/%s"
									} $unit]
								}
								return [format {
									"datavalue":{
										"value":{
									 		"amount":"%s",%s
										},"type":"quantity"
									},"datatype":"%s"
								} [lindex $q 0] $unit $datatype]
							}
		string			{
								return [format {
									"datavalue":{
										"value":"%s","type":"string"
									},"datatype":"%s"
								} $q $datatype]
							}
		time				{
								set cal {"calendarmodel":"http://www.wikidata.org/entity/Q1985727"}
								set par {"timezone":0,"before":0,"after":0}
								return [format {
									"datavalue":{
										"value":{
											"time":"%sT00:00:00Z","precision":%s,%s,%s
										},"type":"time"
									},"datatype":"%s"
								} {*}$q $par $cal $datatype]
							}
		url				{
								return [format {
									"datavalue":{
										"value":"%s","type":"string"
									},"datatype":"%s"
								} $q $datatype]
							}
		wikibase-item	{
								return [format {
									"datavalue":{
										"value":{
											"entity-type":"item","id":"%s"
										},"type":"wikibase-entityid"
									},"datatype":"%s"
								} $q $datatype]
							}
	}
}

proc d_qual qual {
	foreach {p qs} $qual {
		foreach q $qs {
			lappend lq [format {{
				"snaktype":"value","property":"%s",%s
			}} $p [d_set_datavalue $p $q]]
		}
		lappend lqual [format {"%s":[%s]} $p [join $lq ,]]
		lappend lp [format {"%s"} $p]
		unset -nocomplain lq
	}
	return [format {
		,"qualifiers":{%s},"qualifiers-order":[%s]
	} [join $lqual ,] [join $lp ,]]
}

proc d_ref ref {
	foreach {p qs} $ref {
		foreach q $qs {
			lappend lref [format {
				"%s":[{
					"snaktype":"value","property":"%s",%s
				}]
			} $p $p [d_set_datavalue $p $q]]
		}
#		lappend lref [format {"%s":[%s]} $p [join $lq ,]]
		lappend lp [format {"%s"} $p]
#		unset -nocomplain lq
	}
	return [format {
		,"references":[{"snaks":{%s},"snaks-order":[%s]}]
	} [join $lref ,] [join $lp ,]]
}

proc d_ref1 lsnak {
	foreach {p q} $lsnak {
		append snaks [format {
			"%s":[{
				"snaktype":"value","property":"%s",%s
			}]
		} $p $p [d_set_datavalue $p $q]]
	}
puts $snaks
	return [format {
		,"references":[{
			"snaks":{%s},"snaks-order":["%s"]
		}]
	} $snaks [dict keys $lsnak]]
}

proc d_edit_entity {ent items} {
	global wiki format token
	set ldata {}
	foreach item $items {
		dict with item {
puts $item
			lassign [list [lindex $item 0] [lindex $item 1]] p q
			if {$p eq {labels}} {
				foreach {l label} $q {
					lappend llabel [format {{"language":"%s","value":"%s"}} $l $label]
				}
			} elseif {$p eq {descs}} {
				foreach {l desc} $q {
					lappend ldesc [format {{"language":"%s","value":"%s"}} $l $desc]
				}
			} elseif {$p eq {links}} {
				foreach {l sitelink} $q {
					lappend llink [format {{"site":"%swiki","title":"%s"}} $l $sitelink]
				}
			} elseif {$q eq {-remove}} {
				lappend ldata [
					format {"%s":[{"id":"%s","remove":""}]} $p [d_get_guid $ent $p ${-datas}]
				]
				continue
			} else {
				if {$q ne {-new}} {
					set guid [format {"id":"%s","type":"claim",} [d_get_guid $ent $p $q]]
				} elseif {$q eq {-new}} {
					set guid {}
				}
				foreach -data ${-datas} {
					if {{-q} ni [dict keys ${-data}]} {
						set -q $q
					}
					dict with -data {
						if [exists -qual] {
							set qual [d_qual ${-qual}]
						} else {
							set qual {}
						}
						if [exists -ref] {
							set ref [d_ref ${-ref}]
						} else {
							set ref {}
						}
						lappend data [format {{
							%s"mainsnak":{
								"snaktype":"%svalue","property":"%s",%s
							},"type":"statement","rank":"normal"%s%s
						}} $guid [expr {
							${-q} eq {--} ? {no} : {}
						}] $p [d_set_datavalue $p ${-q}] $qual $ref]
					}
				}
				lappend ldata [format {"%s":[%s]} $p [join $data ,]]
				unset -nocomplain -qual -ref data qual ref
			}
		}
	}
	if [exists llabel] {
		set labels [format {{"labels":[%s],}} [join $llabel ,]]
	} else {
		set labels {}
	}
	if [exists ldesc] {
		set descs [format {{"descriptions":[%s],}} [join $ldesc ,]]
	} else {
		set descs {}
	}
	if [exists llink] {
		set links [format {{"sitelinks":[%s],}} [join $llink ,]]
	} else {
		set links {}
	}
	set data [format {{%s%s"claims":{%s}}} [join $labels] [join $descs] [join $ldata ,]]
puts \n$data
#	return [get [post $wiki {*}$token {*}$format / action wbeditentity / new item / data $data / bot 1]]
#puts $data
	if {$ent eq {new}} {
		puts [return [get [post $wiki {*}$token {*}$format / action wbeditentity / new item / data $data / bot 1]]]
	} else {
		puts [return [get [post $wiki {*}$token {*}$format / action wbeditentity / id $ent / data $data / bot 1]]]
	}
}

proc d_edit_entity1 {ent items} {
	global wiki format token
	set ldata {}
	foreach item $items {
puts $item
		dict with item {
#lassign {} p q
#			set p [lindex $item 0]
#			set q [lindex $item 1]
#			lassign [list [lindex $item 0] [lindex $item 1]] p q
puts ${-p}
			if {${-p} eq {labels}} {
				foreach {l label} ${-q} {
					lappend llabel [format {"%s":{"language":"%s","value":"%s"}} $l $l $label]
				}
			} elseif {${-p} eq {descs}} {
				foreach {l desc} ${-q} {
					lappend ldesc [format {"%s":{"language":"%s","value":"%s"}} $l $l $desc]
				}
			} elseif {${-p} eq {aliases}} {
				foreach {l aliases} ${-q} {
					set lalias {}
					foreach alias $aliases {
						lappend lalias [format {{"language":"%s","value":"%s"}} $l $alias]
					}
					lappend dalias [format {"%s":[%s]} $l [join $lalias ,]]
				}
			} elseif {${-p} eq {links}} {
				foreach {l sitelink} ${-q} {
					lappend llink [format {{"site":"%swiki","title":"%s"}} $l $sitelink]
				}
			} elseif {${-q} eq {-remove}} {
				lappend ldata [
					format {
						"%s":[{"id":"%s","remove":""}]
					} ${-p} [d_get_guid $ent ${-p} ${-datas}]
				]
				continue
			} else {
#puts -datas:${-datas}
				foreach -data ${-datas} {
					dict with -data {
#puts -data:${-data}
						if {${-q} ne {-new}} {
							set guid [format {"id":"%s",} [d_get_guid $ent ${-p} ${-q}]]
						} elseif {${-q} eq {-new}} {
							set guid {}
						}
#						if {{-q} ni [dict keys ${-data}]} {
#							set -q $q
#						}
						if [exists -qual] {
							set qual [d_qual ${-qual}]
						} else {
							set qual {}
						}
						if [exists -ref] {
							set ref [d_ref ${-ref}]
						} else {
							set ref {}
						}
						lappend data [format {{
							%s"mainsnak":{
								"snaktype":"%svalue","property":"%s",%s
							},"type":"statement","rank":"normal"%s%s
						}} $guid [expr {
							${-val} eq {--} ? {no} : {}
						}] ${-p} [d_set_datavalue ${-p} ${-val}] $qual $ref]
					}
				}
				lappend ldata [format {"%s":[%s]} ${-p} [join $data ,]]
				unset -nocomplain -qual -ref data qual ref
			}
		}
	}
	if [exists llabel] {
		set labels [format {{"labels":{%s},}} [join $llabel ,]]
	} else {
		set labels {}
	}
	if [exists ldesc] {
		set descs [format {{"descriptions":{%s},}} [join $ldesc ,]]
	} else {
		set descs {}
	}
	if [exists dalias] {
		set aliases [format {{"aliases":{%s},}} [join $dalias ,]]
	} else {
		set aliases {}
	}
	if [exists llink] {
		set links [format {{"sitelinks":[%s],}} [join $llink ,]]
	} else {
		set links {}
	}
	set data [format {{%s%s%s"claims":{%s}}} [join $labels] [join $descs] [join $aliases] [join $ldata ,]]
puts \ndata:$data

	if {$ent eq {new}} {
		puts [return [get [post $wiki {*}$token {*}$format / action wbeditentity / new item / data $data / bot 1]]]
	} else {
		puts [return [get [post $wiki {*}$token {*}$format / action wbeditentity / id $ent / data $data / bot 1]]]
	}
}

#neu: d_edit_entity
proc d_edit_entity2 {ent osnak nsnak ref} {
	global wiki format token
	lassign [list [lindex $osnak 0] [lindex $osnak 1]] op oq
	if {$nsnak eq {<-}} {
		lassign [list $op $oq] np nq
		set guid [format {"id":"%s","type":"claim",} [d_get_guid $ent $op $oq]]
	} else {
		lassign [list [lindex $nsnak 0] [lindex $nsnak 1]] np nq
		set guid {}
	}
	set data [format {
		%s"mainsnak":{
			"snaktype":"%svalue","property":"%s",%s
		},"type":"statement","rank":"normal"
	} $guid [expr {$nq eq {--} ? {no} : {}}] $np [d_set_datavalue $np $nq]]
	set data2 [format {
		%s"mainsnak":{
			"snaktype":"%svalue","property":"%s",%s
		},"type":"statement","rank":"normal"
	} $guid [expr {$nq eq {--} ? {no} : {}}] P106 [d_set_datavalue P106 Q10833314]]
	if {[empty ref] || $ref eq {--}} {
		set data [format {{"claims":[{%s}]}} $data]
	} else {
		set data [format {{"claims":{"%s":[{%s,%s}],"%s":[{%s,%s}]}}} $np $data [d_ref $ref] P106 $data2 [d_ref $ref]]
	}
puts $data
	return [get [post $wiki {*}$token {*}$format / action wbeditentity / id $ent / data $data / bot 1]]
}

proc d_merge {qfrom qto} {
	global wiki format token
	puts [get [post $wiki {*}$format {*}$token / action wbmergeitems / fromid $qfrom / toid $qto / ignoreconflicts description / bot true]]
	puts [get [post $wiki {*}$format {*}$token / action wbeditentity / id $qfrom / clear true / data {{}} / summary {Clearing item to prepare for redirect} / bot true]]
	puts [get [post $wiki {*}$format {*}$token / action wbcreateredirect / from $qfrom / to $qto / bot true]]
}

proc wbadd {type datatype item prop val ref} {
	global wiki format token
	set prop [string toupper $prop]
	switch $datatype {
		-amount	{
						if {$val >= 0} {set val +$val}
						set datavalue [format {{"value":{"amount":"%s","unit":"1"},"type":"quantity"}} $val]
					}
		-id		{
						set datavalue [format {{"value":{"entity-type":"item","numeric-id":%s},"type":"wikibase-entityid"}} $val]
					}
		-time		{
						switch [llength [split $val -]] {
							1	{set precision  9}
							2	{set precision 10}
							3	{set precision 11}
						}
						if {[string index $val 0] ne {-}} {set val +$val}
						set datavalue [format {{"value":{"time":"%sT00:00:00Z","timezone":0,"before":0,"after":0,"precision":%s,"calendarmodel":"http://www.wikidata.org/entity/Q1985727"},"type":"time"}} $val $precision]
					}
	}
	switch $type {
		-q	{
				set wbaddqual	[format {{"snaktype":"value","property":"%s","datavalue":%s,"datatype":"%s"}} $prop $datavalue [proptype $prop]]
			}
		-- {
				set wbadd 		[format {"id":"Q%s","type":"statement","mainsnak":{"snaktype":"value","property":"%s","datavalue":%s,"datatype":"%s"}} [guid $item] $prop $datavalue [proptype $prop]]
			}
	}
puts [wbref $ref]
	if ![empty ref] {
		return [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{%s,%s}} $wbadd [wbref $ref]] / bot]]
	} else {
		return [get [post $wiki {*}$token {*}$format / action wbsetclaim / claim [format {{%s}} $wbadd] / bot]]
	}
}

proc wb_add_claim {item prop val ref} {
	global wiki format token
	if ![empty ref] {
		lassign [list [lindex $ref 0] [string trimleft [lindex $ref 1] Q]] refprop refval
		set wbref {"references":[{"snaks":{"P248":[{"snaktype":"value","property":"P248","datavalue":{"type":"wikibase-entityid","value":{"entity-type":"item","numeric-id":14580067}}}]}}]}
	
	}
puts [proptype $refprop]
	return [get [post $wiki {*}$token {*}$format / action wbcreateclaim / entity Q$item / property $prop / snaktype value / value [format {{"entity-type":"item","numeric-id":%s,%s}} [string trimleft $val Q] $wbref] / bot 1]]
}

proc d_qsort lq {
	foreach q $lq {
		lappend l0q [string trimleft $q Q]
	}
	foreach q [lsort -integer $l0q] {
		lappend nlq Q$q
	}
	return $nlq
}

proc d_uqsort lq {
	foreach q $lq {
		lappend l0q [string trimleft $q Q]
	}
	foreach q [lsort -unique -integer $l0q] {
		lappend nlq Q$q
	}
	return $nlq
}

proc d_backlinks {p q filter} {
	global wiki get
	if ![empty filter] {set filter "page_title in ('[join $filter ',']') and"}
	set dbq ('[join $q ',']')
	set db [get_db wikidatawiki]
	mysqlreceive $db "
		select page_title
		from page join pagelinks on pl_from = page_id
		where $filter page_title in (
			select page_title
			from page join pagelinks on pl_from = page_id
			where !page_namespace and !pl_from_namespace and !pl_namespace and pl_title in $dbq
		) and !page_namespace and !pl_from_namespace and pl_namespace = 120 and pl_title = '$p'
	;" pt {
		set offset 0
		foreach {-- lclaim} [get [post $wiki {*}$get / action wbgetclaims / entity $pt] claims] {
			if $offset {break}
			foreach claim $lclaim {
				set mainsnak [dict get $claim mainsnak]
				dict with mainsnak {
					if {$property eq $p} {
						if {[dict get $datavalue value id] in $q} {
							lappend lpt $pt
							incr offset
							break
						}
					}
				}
				catch {
					set lqual [dict get $claim qualifiers]
					set superhash [dict get $claim mainsnak hash]
					foreach {-- qual} $lqual {
						set mainsnak [join [lappend qual superhash $superhash]]
						dict with mainsnak {
							if {$property eq $p} {
								if {[dict get $datavalue value id] in $q} {
									lappend lpt $pt
									incr offset
									break
								}
							}
						}
					}
				}
			}
		}
	}
	mysqlclose $db
	return [d_qsort $lpt]
}

proc d_llinkshere item {
	set db [get_db wikidatawiki]
	set lq [mysqlsel $db "
		select page_title
		from page join pagelinks on pl_from = page_id
		where !page_namespace and !pl_from_namespace and !pl_namespace and pl_title = '$item'
	;" -flatlist]
	mysqlclose $db
	return [d_qsort $lq]
}

proc d_query_raw query {
	while 1 {if ![catch {
		set lres [getHTML https://query.wikidata.org/sparql?query=[curl::escape $query]]
	}] {break}}
#	set lres [dict values [regexp -all -inline -- {entity/(Q\d{1,})} $lres]]
	return $lres
}

proc d_query query {
	while 1 {if ![catch {
		set lres [getHTML https://query.wikidata.org/sparql?query=[curl::escape $query]]
	}] {break}}
	set lres [dict values [regexp -all -inline -- {entity/(Q\d{1,})} $lres]]
	return [d_qsort $lres]
}

proc d_query_ent Q {
	while 1 {if ![catch {
		set lres [
			getHTML https://query.wikidata.org/sparql?query=[curl::escape [
				format {
					select ?itemLabel
					where {
						values ?item {wd:%s} service wikibase:label {
							bd:serviceParam wikibase:language "de,[AUTO_LANGUAGE]".
						}
					}
				} $Q
			]]
		]
	}] {break}}
	regexp -- {<literal.*?>(.*?)</literal>} $lres -- lres
	return $lres
}

proc d_query_wir {p lq} {
	global llang page
	foreach q $lq {
		lappend lwd wd:$q
	}
	while 1 {if ![catch {
		set html [getHTML [set htmltest https://query.wikidata.org/sparql?query=[curl::escape [format {
         select ?sitelinks ?itemLabel ?itemDescription ?item
         with {
            select distinct $item
            where {
               values ?item_class {%s}
               ?item wdt:%s ?item_class; wdt:P21 wd:Q6581072; wdt:P31 wd:Q5.
               minus {
                  ?article schema:about ?item; schema:isPartOf <https://de.wikipedia.org/>.
               }
					minus {?item wdt:P106 wd:Q488111.}
					minus {?item wdt:P106 wd:Q852857.}
            }
         } as %s
         where {
            include %s
            bind(xsd:integer(substr(str(?item), 33)) as ?num).
            ?item wikibase:sitelinks ?sitelinks
            service wikibase:label {bd:serviceParam wikibase:language 'de,%s'.}
         }
         order by desc(?sitelinks) asc(?num)
		} $lwd $p %subquery %subquery [join $llang ,]]]]]
		puts "$page: Items verarbeitet"
		set res [lindex [[[dom parse -html $html] documentElement] asList] 2 0 2 1 2]
#		set res [lindex [join [lindex [[[dom parse -html $html] documentElement] asList] 2]] 5]
	}] {break} else {puts "$page: Items: SPARQL Fehler" ; puts [edit user:TaxonBot/Test {} "$page: $htmltest"]}}
	return $res
}

proc d_query_wir_data llkey {
	global llang page
	foreach lkey $llkey {
		while 1 {if ![catch {
			set html [getHTML https://query.wikidata.org/sparql?query=[curl::escape [format {
				select ?item ?P106 ?P18 ?P373 ?P27Label ?P19Label ?P20Label
				where {
					values ?item {%s}.
					optional {?item p:P106/ps:P106 ?P106m. optional {?P106m wdt:P2521 ?P106. filter(lang(?P106) = 'de')}}
					optional {?item wdt:P18 ?P18.}
					optional {?item wdt:P373 ?P373.}
					optional {?item wdt:P27 ?P27.}
					optional {?item p:P19/ps:P19 ?P19.}
					optional {?item p:P20/ps:P20 ?P20.}
					service wikibase:label {bd:serviceParam wikibase:language 'de,%s'.}
				}
			} $lkey [join $llang ,]]]]
		}] {break} else {puts "Data: SPARQL Timeout"}}
		set lres [lindex [[[dom parse -html $html] documentElement] asList] 2 0 2 1 2]
#		set lres [join [lindex [join [lindex [[[dom parse -html $html] document] asList] 2]] 5]]
		lappend ldata $lres
	}
	puts "$page: Daten verarbeitet"
	return $ldata
}

proc d_query_wir_date {llkey bd} {
	global page
	set bddict {}
	foreach lkey $llkey {
		while 1 {if ![catch {
			set html [getHTML https://query.wikidata.org/sparql?query=[curl::escape [format {
				select ?item ?date ?prec ?cal
				where {
					values ?item {%s}.
					?item %s [
						wikibase:timeValue ?date;
						wikibase:timePrecision ?prec;
						wikibase:timeCalendarModel ?cal
					]
				}
			} $lkey p:$bd/psv:$bd]]]
		}] {break} else {puts "$bd: SPARQL Timeout"}}
		set lres [lindex [[[dom parse -html $html] documentElement] asList] 2 0 2 1 2]
#		set lres [join [lindex [join [lindex [[[dom parse -html $html] document] asList] 2]] 5]]
		foreach {--1 --2 res} [join $lres] {
			set item [lindex [split [lindex [join [lindex [join [lindex [join $res] 2]] 2]] 1] /] end]
			set prec [lindex [join [lindex [join [lindex [join $res] 8]] 2]] 1]
			set calmod [lindex [split [lindex [join [lindex [join [lindex [join $res] 11]] 2]] 1] /] end]
			set date [lindex [split [lindex [join [lindex [join [lindex [join $res] 5]] 2]] 1] T] 0]
			if {[string index $date 0] eq {-}} {
				set vuZ 1
				set date [string trimleft $date -]
			} else {
				set vuZ 0
			}
			switch $prec {
				 6	{	if {[string range $date end-8 end-6] ne {000}} {
							set date "[string trimleft [expr [string range $date 0 end-9] + 1] 0]. Jtsd."
						} else {
							set date "[string trimleft [string range $date 0 end-9] 0]. Jtsd."
						}
					}
				 7	{	if {[string range $date end-7 end-6] ne {00}} {
#				 				set date "[string trimleft [expr [string range $date 0 end-8] + 1] 0]. Jhdt."
				 				set date "[expr [string trimleft [string range $date 0 end-8] 0] + 1]. Jhdt."
						} else {
							set date "[string trimleft [string range $date 0 end-8] 0]. Jhdt."
						}
					}
				 8	{set date [string trimleft [string range $date 0 end-7] 0]0er-Jahre}
				 9	{	set date [string trimleft [string range $date 0 end-6] 0]
				 		if $vuZ {incr date}
#						set date [string trimleft $date 0]
				 	}
				10	{set date [string range $date 0 end-3]}
			}
			if $vuZ {append date " v.u.Z."}
			if {$calmod eq {Q1985786}} {append date "<br /><small>(julian.)</small>"}
			dict lappend bddict $item $date
		}
	}
	puts "$page: [expr {$bd eq {P569} ? {Geburtsdaten} : {Sterbedaten}}] verarbeitet"
	return $bddict
}

proc wb_get_label {item lang} {
	global wiki format
	if ![catch {set label [get [post $wiki {*}$format / action wbgetentities / ids $item] entities $item labels $lang value]}] {return $label} else {return {}}
}

proc wb_get_desc {item lang} {
	global wiki format
	if ![catch {set desc [get [post $wiki {*}$format / action wbgetentities / ids $item] entities $item descriptions $lang value]}] {return $desc} else {return {}}
}

proc wb_get_lalias {item lang} {
	global wiki format
	if [catch {set lalias [get [post $wiki {*}$format / action wbgetentities / ids $item] entities $item aliases $lang]}] {set lalias {}}
	set lresalias {}
	foreach alias $lalias {
		lappend lresalias [dict get $alias value]
	}
	return $lresalias
}

proc wb_get_litem {p q} {
	return [d_query [format {
		select ?item
		where {
			?item wdt:%s wd:%s.
		}
	} $p $q]]
}

#neu: d_get_lp
proc wb_get_lp item {
	global wiki format
	return [dict keys [get [post $wiki {*}$format / action wbgetentities / ids $item] entities $item claims]]
}

proc wb_get_entity {item} {
	global wiki format
	return [get [post $wiki {*}$format / action wbgetentities / ids $item]]
}

#neu: d_get_lmainsnak
proc wb_get_lmainsnak {item p} {
	global wiki format
	return [get [post $wiki {*}$format / action wbgetclaims / entity $item / property $p] claims $p]
}

proc wb_get_lv {item p} {
	global wiki format
	if {$p in [wb_get_lp $item]} {
		foreach mainsnak [wb_get_lmainsnak $item $p] {
			lappend lq [dict get $mainsnak mainsnak datavalue value]
		}
		if [exists lq] {return $lq} else {return {}}
	} else {return {}}
}

#neu: d_get_lq
proc wb_get_lq {item p} {
	global wiki format
	foreach mainsnak [wb_get_lmainsnak $item $p] {
		lappend lq [dict get $mainsnak mainsnak datavalue value id]
	}
	return $lq
}

#neu: d_get_guid
proc wb_get_guid {item p q} {
	global wiki format
	foreach mainsnak [wb_get_lmainsnak $item $p] {
		if {[dict get $mainsnak mainsnak datavalue value id] eq $q} {
			return [dict get $mainsnak id]
		}
	}
}

proc wb_set_guid item {
	foreach digit {8 4 4 4 12} {
		lappend lguid [format %0${digit}X [expr int(rand()*16**$digit)]]
	}
	return $item$[join $lguid -]
}

proc wb_set_claim_monolang {item p text lang} {
	global wiki format token
	if {$p in [wb_get_lp $item]} {
		foreach v [wb_get_lv $item $p] {
			lappend llang [dict get $v language]
		}
	} else {
		set llang {}
	}
	if {$lang ni $llang} {
		return [get [post $wiki {*}$format {*}$token / action wbsetclaim / claim \{"id":"[wb_set_guid $item]","type":"claim","mainsnak":\{"snaktype":"value","property":"$p","datavalue":\{"value":\{"text":"$text","language":"$lang"\},"type":"monolingualtext"\},"datatype":"monolingualtext"\}\} / bot 1]]
	} else {
		puts "Redundanz-Fehler: $item $p $text $lang" ; exit
	}
}

proc wb_get_alias {item lang} {
	global wiki format token
	return [get [post $wiki {*}$format {*}$token / action wbgetentities / ids $item / props aliases / languages $lang] entities $item aliases]
}

proc wb_add_alias {item alias lang} {
	global wiki format token
	return [get [post $wiki {*}$format {*}$token / action wbsetaliases / id $item / add $alias / language $lang / bot 1]]
}

proc wb_change_alias {item oldalias newalias lang} {
	global wiki format token
	return [get [post $wiki {*}$format {*}$token / action wbsetaliases / id $item / remove $oldalias / add $newalias / language $lang / bot 1]]
}

proc wb_change_value {item p q nq} {
	global wiki format token
	if {$nq in [wb_get_lq $item $p]} {
		puts Redundanz-Fehler
	} else {
		return [get [post $wiki {*}$format {*}$token / action wbsetclaimvalue / claim [wb_get_guid $item $p $q] / snaktype value / value \{"entity-type":"item","id":"$nq"\} / summary {Reason: [[Special:Diff/642947230/643341062|Diff]]} / bot 1]]
	}
}

proc wb_vchange {item p q} {
	global wiki format token
}

proc meta_lang {} {
	global wiki llang lw
	set langconts [conts t {List of Wikipedias/Table} x]
	set llang [dict values [regexp -all -inline -- {\| \[\[\:(.*?)\:\|} $langconts]]
	foreach lan $llang {
		lappend lw [string map {- _} $lan]wiki
	}
}
