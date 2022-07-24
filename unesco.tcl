#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#set editafter 500

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]
while 1 {if [catch {set db [get_db dewiki]}] {after 60000 ; continue} else {break}}

set l3 [conts id 9847666 3]
set tl3 {Afrika}
set l4 [conts id 9847666 4]
set tl4 {Arabische Staaten}
set l5 [conts id 9847666 5]
set tl5 {Asien und Pazifik}
set l6 [conts id 9847666 6]
set tl6 {Europa und Nordamerika}
set l7 [conts id 9847666 7]
set tl7 {Lateinamerika und Karibik}

set l3 [dict values [regexp -all -line -inline -- {\*.*?\|(.*?)\]\]} $l3]]
set l4 [dict values [regexp -all -line -inline -- {\*.*?\|(.*?)\]\]} $l4]]
set l5 [dict values [regexp -all -line -inline -- {\*.*?\|(.*?)\]\]} $l5]]
set l6 [dict values [regexp -all -line -inline -- {\*.*?\|(.*?)\]\]} $l6]]
set l7 [dict values [regexp -all -line -inline -- {\*.*?\|(.*?)\]\]} $l7]]

mysqlreceive $db "
	select page_title
	from page, templatelinks
	where tl_from = page_id and !page_namespace and !tl_from_namespace and tl_namespace = 10 and tl_title = 'Infobox_Welterbe'
;" pt {
	unset -nocomplain region staat lstaat nlregion
	puts \n$pt
	if {$pt in {Senegambische_Steinkreise Kloster_Gračanica Jerusalemer_Altstadt Freiheitsstatue Semmeringbahn Glarner_Hauptüberschiebung Schloss_Njaswisch Kunta_Kinteh_Island_und_zugehörige_Stätten}} {continue}
#	if {$pt in {Sian_Ka'an Jerusalemer_Altstadt Naturschutzgebiet_Nimba-Berge Great_North_Road_(Australien) Kingston_and_Arthurs_Vale_Historic_Area Cascades_Female_Factory Das_architektonische_Werk_von_Le_Corbusier_(Welterbe) Freiheitsstatue Canadian_Rocky_Mountain_Parks Tarraco Semmeringbahn Senegambische_Steinkreise Kunta_Kinteh_Island_und_zugehörige_Stätten Glarner_Hauptüberschiebung Blue_Mountains_(Australien)}} {continue}
	regexp -line {\| ?Staats-Gebiet.*} [set conts [conts t $pt x]] staat
	regexp -line {\| ?Region[ =].*} [regexp -inline -- {\{\{Infobox Welterbe.*} $conts] region
	puts $staat
	if {[string first \\ $region] > -1} {gets stdin}
	if {[string first \{ $staat] == -1} {
		set staat [split $staat =]
		set staat \{\{[string trim [lindex $staat 1]]\}\}
	}
	puts $region
	set lstaat [dict values [regexp -all -inline -- {\{\{(.*?)\}\}} $staat]]
	puts $lstaat
	foreach staat $lstaat {
		if {[string index [set sconts [conts t Vorlage:$staat x]] 0] ne {#}} {
			set staat [join [dict values [regexp -inline -- {2\|(.*?)\}} [string map {{&nbsp;} { }} $sconts]]]]
		}
		if {$staat eq {BAN}} {set staat Bangladesch}
		if {$staat eq {Demokratische Republik Kongo}} {set staat {Kongo (Demokr. Republik)}}
		if {$staat eq {Großbritannien}} {set staat {Vereinigtes Königreich}}
		if {$staat eq {Palästinensische Autonomiegebiete}} {set staat Palästina}
		if {$staat eq {Singapore}} {set staat Singapur}
		if {$staat eq {SRI}} {set staat {Sri Lanka}}
		if {$staat eq {United Kingdom}} {set staat {Vereinigtes Königreich}}
		if {$staat eq {Volksrepublik China}} {set staat China}
		if {$staat in $l3} {lappend nlregion $tl3}
		if {$staat in $l4} {lappend nlregion $tl4}
		if {$staat in $l5} {lappend nlregion $tl5}
		if {$staat in $l6} {lappend nlregion $tl6}
		if {$staat in $l7} {lappend nlregion $tl7}
		if {$staat eq {Kosovo}} {lappend nlregion $tl6}
		puts $staat
		set nlregion [lsort -unique $nlregion]
		puts $nlregion
	}
	lappend lptregion $pt $region $nlregion
}

#
if 0 {
set lregion 'Liste_des_UNESCO-Welterbes_in_Afrika','Liste_des_UNESCO-Welterbes_in_Amerika','Liste_des_UNESCO-Welterbes_in_Asien','Liste_des_UNESCO-Welterbes_in_Australien_und_Ozeanien','Liste_des_UNESCO-Welterbes_in_Europa','Liste_des_UNESCO-Welterbes_ohne_Kontinentalbezug'
foreach {plt region} $lptregion {
	mysqlreceive $db "
		select page_title
		from page, pagelinks
		where page_id = pl_from and page_title in ($lregion) and !page_namespace and !pl_from_namespace and pl_title = '[sql <- $plt]'
	;" pt {
		puts \n$plt\n$pt
		set pt [lindex [split $pt _] end]
		switch $pt {
			Kontinentalbezug	{set pt "ohne $pt"}
			Ozeanien				{set pt "Australien und $pt"}
			default				{}
		}
		lappend dregion $plt $region $pt
	}
}
puts $dregion
}
#

set k 0
foreach {pt region nlregion} [lsort -stride 3 -index 0 $lptregion] {
#	if {$pt eq {San_Antonio_Missions} || $k} {set k 1} else {continue}
	regexp -- {.*?\=[ ]{0,5}(.*?)$} $region -- bregion
	puts $pt:$region:$bregion:$nlregion
#	puts [string map [list $bregion $region] [conts t $pt x]]
#	if {[incr i] >= 10} {} else {puts [string map [list $bregion $region] [conts t $pt x]] ; gets stdin}
	if {[llength $nlregion] > 1} {gets stdin}
	set bregion [string map [list $bregion [join $nlregion {<br />}]] $region]
	set nconts [string map [list $region $bregion] [set oconts [conts t $pt x]]]
#	set nconts [regsub -- [format %s $bregion] [set oconts [conts t $pt x]] "$region"]
	if {$nconts eq $oconts} {continue}
	puts [edit $pt {Bot: Anpassung #3 [[Vorlage:Infobox Welterbe]] nach [[WP:Bots/A#UNESCO-Welterbe]]} $nconts / minor]
	if {[incr j] < 10} {gets stdin}
}
