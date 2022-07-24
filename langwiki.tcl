# dewiki.tcl Configuration file

# German Wikipedia configuration example

# Copyright 2010 Giftpflanze

# This file is part of the MediaWiki Tcl Bot Framework.

# The MediaWiki Tcl Bot Framework is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

source dewiki.config
#puts $argv0
switch $lang {
	detest		{
		source dewikitest.config
		set wiki [get_handle de wikipedia https://de.wikipedia.org/w]
	}
	de1		{
		source dewiki1.config
		set wiki [get_handle de wikipedia https://de.wikipedia.org/w]
	}
	es1		{
		source dewiki1.config
		set wiki [get_handle de wikipedia https://es.wikipedia.org/w]
	}
	dea		{
		source dewikia.config
		set wiki [get_handle de wikipedia https://de.wikipedia.org/w]
	}
	kat		{
		source dewikikat.config
		set wiki [get_handle de wikipedia https://de.wikipedia.org/w]
	}
	cac		{
		source dewikicac.config
		set wiki [get_handle de wikipedia https://de-cac.wmflabs.org/w]
	}
	species	{
		source dewiki1.config
		set wiki [get_handle de wikipedia https://species.wikimedia.org/w]
	}
   meta     {set wiki [get_handle de wikipedia https://meta.wikimedia.org/w]}
	commons	{set wiki [get_handle de wikipedia https://commons.wikimedia.org/w]}
	commons1	{
		source commons1.config
		set wiki [get_handle de wikipedia https://commons.wikimedia.org/w]
	}
	d			{set wiki [get_handle de wikipedia https://www.wikidata.org/w]}
	wikt		{set wiki [get_handle de wikipedia https://de.wiktionary.org/w]}
	v			{set wiki [get_handle de wikipedia https://de.wikiversity.org/w]}
	voy		{set wiki [get_handle de wikipedia https://de.wikivoyage.org/w]}
	wp3		{set wiki [get_handle de wikipedia https://luke.wmflabs.org/w]}
	test		{set wiki [get_handle de wikipedia https://test2.wikipedia.org/w]}
	beta		{set wiki [get_handle de wikipedia http://de.wikipedia.beta.wmflabs.org/w]}
	nordh		{
		source dewiki1.config
		set wiki [get_handle de wikipedia http://nordhausen-wiki.de]
	}
	poke		{
		source dewiki1.config
		set wiki [get_handle de wikipedia http://www.pokewiki.de]
	}
	wue		{
		source dewiki1.config
		set wiki [get_handle de wikipedia https://wuerzburgwiki.de/w]
	}
	default		{
		source dewiki.config
		set wiki [get_handle de wikipedia https://$lang.wikipedia.org/w]
	}
}

return
