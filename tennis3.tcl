#!/usr/bin/tclsh8.7
#!/usr/bin/tclsh8.6

#exit

package require http
package require tls
package require tdom

source api.tcl ; set lang de ; source langwiki.tcl ; #set token [login $wiki]

#####

set atp {
	{ser	250	date	06.01.	dur	11.01.
		loc	{{{QAT|Doha|Doha}}}									t	{[[ATP Doha|Qatar ExxonMobil Open]]}									f	Hartplatz}
	{ser	250	date	12.01.	dur	18.01.
		loc	{{{AUS|Adelaide|Adelaide}}}						t	{[[ATP Adelaide|Adelaide International]]}								f	Hartplatz}
	{ser	250	date	13.01.	dur	18.01.
		loc	{{{NZL|Auckland|Auckland}}}						t	{[[ATP Auckland|ASB Classic]]}											f	Hartplatz}
	{ser	gs		date	20.01.	dur	03.02.
		loc	{{{AUS|Melbourne|Melbourne}}}						t	{[[Australian Open]]}														f	Hartplatz}
	{ser	250	date	03.02.	dur	09.02.
		loc	{{{IND|Pune|Pune}}}									t	{[[ATP Pune|Tata Open Maharashtra]]}									f	Hartplatz}
	{ser	250	date	03.02.	dur	09.02.
		loc	{{{FRA|Montpellier|Montpellier}}}				t	{[[ATP Montpellier|Open Sud de France]]}								f	{Hartplatz (Halle)}}
	{ser	250	date	03.02.	dur	09.02.
		loc	{{{ARG|Córdoba|Córdoba}}}							t	{[[ATP Córdoba|Córdoba Open]]}											f	Sand}
	{ser	500	date	10.02.	dur	16.02.
		loc	{{{NLD|Rotterdam|Rotterdam}}}						t	{[[ATP Rotterdam|ABN AMRO World Tennis Tournament]]}				f	{Hartplatz (Halle)}}
	{ser	250	date	10.02.	dur	16.02.
		loc	{{{USA|New York City|New York}}}					t	{[[ATP New York City|New York Open]]}									f	{Hartplatz (Halle)}}
	{ser	250	date	10.02.	dur	16.02.
		loc	{{{ARG|Buenos Aires|Buenos Aires}}}				t	{[[ATP Buenos Aires|Argentina Open]]}									f	Sand}
	{ser	500	date	16.02.	dur	23.02.
		loc	{{{BRA|Rio de Janeiro|Rio de Janeiro}}}		t	{[[ATP Rio de Janeiro|Rio Open]]}										f	Sand}
	{ser	250	date	17.02.	dur	23.02.
		loc	{{{FRA|Marseille|Marseille}}}						t	{[[ATP Marseille|Open 13 Provence]]}									f	{Hartplatz (Halle)}}
	{ser	250	date	17.02.	dur	23.02.
		loc	{{{USA|Delray Beach|Delray Beach}}}				t	{[[ATP Delray Beach|Delray Beach Open]]}								f	Hartplatz}
	{ser	500	date	24.02.	dur	29.02.
		loc	{{{ARE|Dubai|Dubai}}}								t	{[[ATP Dubai|Dubai Duty Free Tennis Championships]]}				f	Hartplatz}
	{ser	250	date	24.02.	dur	01.03.
		loc	{{{CHI|Santiago de Chile|Santiago}}}			t	{[[ATP Santiago de Chile|Chile Open]]}									f	Sand}
	{ser	500	date	24.02.	dur	29.02.
		loc	{{{MEX|Acapulco|Acapulco}}}						t	{[[ATP Acapulco|Abierto Mexicano Telcel]]}							f	Hartplatz}
	{ser	1000	date	12.03.	dur	22.03.
		loc	{{{USA|Indian Wells|Indian Wells}}}				t	{[[Indian Wells Masters|BNP Paribas Open]]}							f	Hartplatz}
	{ser	1000	date	25.03.	dur	05.04.
		loc	{{{USA|Miami|Miami}}}								t	{[[Miami Masters|Miami Open]]}											f	Hartplatz}
	{ser	250	date	06.04.	dur	12.04.
		loc	{{{MAR|Marrakesch|Marrakesch}}}					t	{[[ATP Marrakesch|Grand Prix Hassan II]]}								f	Sand}
	{ser	250	date	06.04.	dur	12.04.
		loc	{{{USA|Houston|Houston}}}							t	{[[ATP Houston|US Men’s Clay Court Championship]]}					f	Sand}
	{ser	1000	date	12.04.	dur	19.04.
		loc	{{{MCO|Monte-Carlo|Monte-Carlo}}}				t	{[[Monte-Carlo Masters|Rolex Monte-Carlo Masters]]}				f	Sand}
	{ser	250	date	20.04.	dur	26.04.
		loc	{{{HUN|Budapest|Budapest}}}						t	{[[ATP Budapest|Hungarian Open]]}										f	Sand}
	{ser	500	date	20.04.	dur	26.04.
		loc	{{{ESP|Barcelona|Barcelona}}}						t	{[[ATP Barcelona|Barcelona Open Banc Sabadell]]}					f	Sand}
	{ser	250	date	27.04.	dur	03.05.
		loc	{{{DEU|München|München}}}							t	{[[ATP München|BMW Open]]}													f	Sand}
	{ser	250	date	27.04.	dur	03.05.
		loc	{{{POR|Estoril|Estoril}}}							t	{[[ATP Estoril|Millennium Estoril Open]]}								f	Sand}
	{ser	1000	date	03.05.	dur	10.05.
		loc	{{{ESP|Madrid|Madrid}}}								t	{[[Madrid Masters|Mutua Madrid Open]]}									f	Sand}
	{ser	1000	date	10.05.	dur	17.05.
		loc	{{{ITA|Rom|Rom}}}										t	{[[Rom Masters|Internazionali BNL d’Italia]]}						f	Sand}
	{ser	250	date	17.05.	dur	23.05.
		loc	{{{SUI|Genf|Genf}}}									t	{[[ATP Genf|Banque Eric Sturdza Geneva Open]]}						f	Sand}
	{ser	250	date	17.05.	dur	23.05.
		loc	{{{FRA|Lyon|Lyon}}}									t	{[[ATP Lyon|Open Parc Auvergne-Rhône-Alpes Lyon]]}					f	Sand}
	{ser	gs		date	24.05.	dur	07.06.
		loc	{{{FRA|Paris|Paris}}}								t	{[[French Open|Roland Garros]]}											f	Sand}
	{ser	250	date	08.06.	dur	14.06.
		loc	{{{DEU|Stuttgart|Stuttgart}}}						t	{[[ATP Stuttgart|MercedesCup]]}											f	Rasen}
	{ser	250	date	08.06.	dur	14.06.
		loc	{{{NLD|’s-Hertogenbosch|’s-Hertogenbosch}}}	t	{[[ATP ’s-Hertogenbosch|Libéma Open]]}									f	Rasen}
	{ser	500	date	15.06.	dur	21.06.
		loc	{{{DEU|Halle (Westf.)|Halle}}}					t	{[[ATP Halle|Grass Court Open Halle]]}									f	Rasen}
	{ser	500	date	15.06.	dur	21.06.
		loc	{{{GBR|London|London}}}								t	{[[ATP Queen’s Club|Fever-Tree Championships]]}						f	Rasen}
	{ser	250	date	22.06.	dur	27.06.
		loc	{{{ESP|Santa Ponça|Mallorca}}}					t	{[[ATP Mallorca|Mallorca Championships]]}								f	Rasen}
	{ser	250	date	22.06.	dur	27.06.
		loc	{{{GBR|Eastbourne|Eastbourne}}}					t	{[[ATP Eastbourne|Nature Valley International]]}					f	Rasen}
	{ser	gs		date	29.06.	dur	12.07.
		loc	{{{GBR|London|London}}}								t	{[[Wimbledon Championships|Wimbledon]]}								f	Rasen}
	{ser	250	date	13.07.	dur	19.07.
		loc	{{{SWE|Båstad|Båstad}}}								t	{[[ATP Båstad|Nordea Open]]}												f	Sand}
	{ser	500	date	13.07.	dur	19.07.
		loc	{{{DEU|Hamburg|Hamburg}}}							t	{[[ATP Hamburg|Hamburg European Open]]}								f	Sand}
	{ser	250	date	13.07.	dur	19.07.
		loc	{{{USA|Newport (Rhode Island)|Newport}}}		t	{[[ATP Newport|Hall of Fame Open]]}										f	Rasen}
	{ser	250	date	20.07.	dur	26.07.
		loc	{{{HRV|Umag|Umag}}}									t	{[[ATP Umag|Plava Laguna Croatia Open Umag]]}						f	Sand}
	{ser	250	date	20.07.	dur	26.07.
		loc	{{{CHE|Gstaad|Gstaad}}}								t	{[[ATP Gstaad|J. Safra Sarasin Swiss Open Gstaad]]}				f	Sand}
	{ser	250	date	20.07.	dur	25.07.
		loc	{{{MEX|Municipio Los Cabos|Los Cabos}}}		t	{[[ATP Los Cabos|Abierto de Tenis Mifel]]}							f	Hartplatz}
	{ser	250	date	27.07.	dur	01.08.
		loc	{{{AUT|Kitzbühel|Kitzbühel}}}						t	{[[ATP Kitzbühel|Generali Open]]}										f	Sand}
	{ser	250	date	27.07.	dur	02.08.
		loc	{{{USA|Atlanta|Atlanta}}}							t	{[[ATP Atlanta|BB&T Atlanta Open]]}										f	Hartplatz}
	{ser	500	date	02.08.	dur	09.08.
		loc	{{{USA|Washington, D.C.|Washington}}}			t	{[[ATP Washington|Citi Open]]}											f	Hartplatz}
	{ser	1000	date	10.08.	dur	16.08.
		loc	{{{CAN|Toronto|Toronto}}}							t	{[[Kanada Masters|Rogers Cup]]}											f	Hartplatz}
	{ser	1000	date	16.08.	dur	23.08.
		loc	{{{USA|Cincinnati|Cincinnati}}}					t	{[[Cincinnati Masters|Western & Southern Open]]}					f	Hartplatz}
	{ser	250	date	23.08.	dur	29.08.
		loc	{{{USA|Winston-Salem|Winston-Salem}}}			t	{[[ATP Winston-Salem|Winston-Salem Open]]}							f	Hartplatz}
	{ser	gs		date	31.08.	dur	13.09.
		loc	{{{USA|New York City|New York}}}					t	{[[US Open]]}																	f	Hartplatz}
	{ser	250	date	21.09.	dur	27.09.
		loc	{{{RUS|Sankt Petersburg|Sankt Petersburg}}}	t	{[[ATP St. Petersburg|St. Petersburg Open]]}							f	{Hartplatz (Halle)}}
	{ser	250	date	21.09.	dur	27.09.
		loc	{{{FRA|Metz|Metz}}}									t	{[[ATP Metz|Moselle Open]]}												f	{Hartplatz (Halle)}}
	{ser	250	date	28.09.	dur	04.10.
		loc	{{{CHN|Zhuhai|Zhuhai}}}								t	{[[ATP Zhuhai|Huajin Securities Zhuhai Championships]]}			f	Hartplatz}
	{ser	250	date	28.09.	dur	04.10.
		loc	{{{CHN|Chengdu|Chengdu}}}							t	{[[ATP Chengdu|Chengdu Open]]}											f	Hartplatz}
	{ser	250	date	28.09.	dur	04.10.
		loc	{{{BGR|Sofia|Sofia}}}								t	{[[ATP Sofia|Sofia Open]]}													f	{Hartplatz (Halle)}}
	{ser	500	date	05.10.	dur	11.10.
		loc	{{{JPN|Tokio|Tokio}}}								t	{[[ATP Tokio|Rakuten Japan Open Tennis Championships]]}			f	Hartplatz}
	{ser	500	date	05.10.	dur	11.10.
		loc	{{{CHN|Peking|Peking}}}								t	{[[ATP Peking|China Open]]}												f	Hartplatz}
	{ser	1000	date	11.10.	dur	18.10.
		loc	{{{CHN|Shanghai|Shanghai}}}						t	{[[Shanghai Masters (Tennis)|Rolex Shanghai Masters]]}			f	Hartplatz}
	{ser	250	date	19.10.	dur	25.10.
		loc	{{{RUS|Moskau|Moskau}}}								t	{[[ATP Moskau|VTB Kremlin Cup]]}											f	{Hartplatz (Halle)}}
	{ser	250	date	19.10.	dur	25.10.
		loc	{{{SWE|Stockholm|Stockholm}}}						t	{[[ATP Stockholm|Stockholm Open]]}										f	{Hartplatz (Halle)}}
	{ser	250	date	19.10.	dur	25.10.
		loc	{{{BEL|Antwerpen|Antwerpen}}}						t	{[[ATP Antwerpen|European Open]]}										f	{Hartplatz (Halle)}}
	{ser	500	date	26.10.	dur	01.11.
		loc	{{{AUT|Wien|Wien}}}									t	{[[ATP Wien|Erste Bank Open 500]]}										f	{Hartplatz (Halle)}}
	{ser	500	date	26.10.	dur	01.11.
		loc	{{{CHE|Basel|Basel}}}								t	{[[ATP Basel|Swiss Indoors Basel]]}										f	{Hartplatz (Halle)}}
	{ser	1000	date	02.11.	dur	08.11.
		loc	{{{FRA|Paris|Paris}}}								t	{[[Paris Masters|Rolex Paris Masters]]}								f	{Hartplatz (Halle)}}
	{ser	fin	date	10.11.	dur	14.11.
		loc	{{{ITA|Mailand|Mailand}}}							t	{[[Next Generation ATP Finals|Next Gen ATP Finals]]}				f	{Hartplatz (Halle)}}
	{ser	fin	date	15.11.	dur	22.11.
		loc	{{{GBR|London|London}}}								t	{[[ATP World Tour Finals|Nitto ATP Finals]]}							f	{Hartplatz (Halle)}}
}

set wta {
	{ser	int	date	04.01.	dur	11.01.
		loc	{{{CHN|Shenzhen|Shenzhen}}}								t	{[[Shenzhen Open 2020|Shenzhen Open]]}																				f	Hartplatz}
	{ser	pr		date	06.01.	dur	12.01.
		loc	{{{AUS|Brisbane|Brisbane}}}								t	{[[Brisbane International 2020|Brisbane International]]}														f	Hartplatz}
	{ser	int	date	06.01.	dur	12.01.
		loc	{{{NZL|Auckland|Auckland}}}								t	{[[ASB Classic 2020/Damen|ASB Classic]]}																			f	Hartplatz}
	{ser	int	date	13.01.	dur	18.01.
		loc	{{{AUS|Hobart|Hobart}}}										t	{[[Hobart International 2020|Hobart International]]}															f	Hartplatz}
	{ser	pr		date	13.01.	dur	18.01.
		loc	{{{AUS|Adelaide|Adelaide}}}								t	{[[Adelaide International 2020/Damen|Adelaide International]]}												f	Hartplatz}
	{ser	gs		date	20.01.	dur	02.02.
		loc	{{{AUS|Melbourne|Melbourne}}}								t	{[[Australian Open 2020|Australian Open]]}																		f	Hartplatz}
	{ser	int	date	10.02.	dur	16.02.
		loc	{{{THA|Amphoe Hua Hin|Hua Hin}}}							t	{[[Thailand Open 2020| Toyota Thailand Open]]}																	f	{Hartplatz (Halle)}}
	{ser	pr		date	10.02.	dur	16.02.
		loc	{{{RUS|Sankt Petersburg|St. Petersburg}}}				t	{[[St. Petersburg Ladies Trophy 2020|St. Petersburg Ladies Trophy]]}										f	{Hartplatz (Halle)}}
	{ser	pr		date	17.02.	dur	22.02.
		loc	{{{ARE|Dubai|Dubai}}}										t	{[[Dubai Duty Free Tennis Championships 2020/Damen|Dubai Duty Free Tennis Championships]]}		f	Hartplatz}
	{ser	int	date	17.02.	dur	23.02.
		loc	{{{HUN|Budapest|Budapest}}}								t	{[[Hungarian Ladies Open 2020|Hungarian Ladies Open]]}														f	{Hartplatz (Halle)}}
	{ser	pr5	date	23.02.	dur	29.02.
		loc	{{{QAT|Doha|Doha}}}											t	{[[Qatar Total Open 2020|Qatar Total Open]]}																		f	Hartplatz}
	{ser	int	date	24.02.	dur	29.02.
		loc	{{{MEX|Acapulco|Acapulco}}}								t	{[[Abierto Mexicano Telcel 2020/Damen|Abierto Mexicano TELCEL]]}											f	Hartplatz}
	{ser	int	date	02.03.	dur	08.03.
		loc	{{{FRA|Lyon|Lyon}}}											t	{[[Open 6ème Sens 2020|Open 6<sup>ème</sup> Sens]]}															f	{Hartplatz (Halle)}}
	{ser	int	date	02.03.	dur	08.03.
		loc	{{{MEX|Monterrey|Monterrey}}}								t	{[[Abierto GNP Seguros 2019|Abierto GNP Seguros]]}																f	Hartplatz}
	{ser	prm	date	11.03.	dur	22.03.
		loc	{{{USA|Indian Wells|Indian Wells}}}						t	{[[BNP Paribas Open 2020/Damen|BNP Paribas Open]]}																f	Hartplatz}
	{ser	prm	date	24.03.	dur	04.04.
		loc	{{{USA|Miami|Miami}}}										t	{[[Miami Open 2020/Damen|Miami Open]]}																				f	Hartplatz}
	{ser	pr		date	06.04.	dur	14.04.
		loc	{{{USA|Charleston (South Carolina)|Charleston}}}	t	{[[Volvo Car Open 2020|Volvo Car Open]]}																			f	Sand}
	{ser	int	date	06.04.	dur	14.04.
		loc	{{{COL|Bogotá|Bogotá}}}										t	{[[Claro Open Colsanitas 2020|Claro Open Colsanitas]]}														f	Sand}
	{ser	int	date	20.04.	dur	28.04.
		loc	{{{CHE|Lugano|Lugano}}}										t	{[[Samsung Open 2020|Samsung Open]]}																				f	Sand}
	{ser	pr		date	20.04.	dur	28.04.
		loc	{{{DEU|Stuttgart|Stuttgart}}}								t	{[[Porsche Tennis Grand Prix 2020|Porsche Tennis Grand Prix]]}												f	{Sand (Halle)}}
	{ser	int	date	27.04.	dur	04.05.
		loc	{{{CZE|Prag|Prag}}}											t	{[[J&T Banka Prague Open 2020|J&T Banka Prague Open]]}														f	Sand}
	{ser	int	date	27.04.	dur	04.05.
		loc	{{{MAR|Rabat|Rabat}}}										t	{[[Grand Prix SAR La Princesse Lalla Meryem 2019|Grand Prix De SAR La Princesse Lalla Meryem]]}	f	Sand}
	{ser	prm	date	04.05.	dur	11.05.
		loc	{{{ESP|Madrid|Madrid}}}										t	{[[Mutua Madrid Open 2020/Damen|Mutua Madrid Open]]}															f	Sand}
	{ser	pr5	date	11.05.	dur	19.05.
		loc	{{{ITA|Rom|Rom}}}												t	{[[Internazionali BNL d’Italia 2020/Damen|Internazionali BNL d’Italia]]}								f	Sand}
	{ser	int	date	18.05.	dur	25.05.
		loc	{{{DEU|Nürnberg|Nürnberg}}}								t	{[[Nürnberg Open 2020|Nürnberg Open]]}																				f	Sand}
	{ser	int	date	18.05.	dur	25.05.
		loc	{{{FRA|Straßburg|Straßburg}}}								t	{[[Internationaux de Strasbourg 2020|Internationaux de Strasbourg]]}										f	Sand}
	{ser	gs		date	25.05.	dur	08.06.
		loc	{{{FRA|Paris|Paris}}}										t	{[[French Open 2020|Roland Garros]]}																				f	Sand}
	{ser	int	date	08.06.	dur	16.06.
		loc	{{{NLD|’s-Hertogenbosch|’s-Hertogenbosch}}}			t	{[[Libéma Open 2020/Damen|Libéma Open]]}																			f	Rasen}
	{ser	int	date	08.06.	dur	16.06.
		loc	{{{GBR|Nottingham|Nottingham}}}							t	{[[Nature Valley Open 2020|Nature Valley Open]]}																f	Rasen}
	{ser	pr		date	15.06.	dur	23.06.
		loc	{{{DEU|Berlin|Berlin}}}										t	{[[Grass Court Championships 2020|Grass Court Championships]]}												f	Rasen}
	{ser	int		date	15.06.	dur	23.06.
		loc	{{{GBR|Birmingham|Birmingham}}}							t	{[[Nature Valley Classic 2020|Nature Valley Classic]]}														f	Rasen}
	{ser	int	date	22.06.	dur	29.07.
		loc	{{{DEU|Bad Homburg|Bad Homburg}}}						t	{[[Bad Homburg Open 2020|Bad Homburg Open]]}																		f	Rasen}
	{ser	pr		date	22.06.	dur	29.07.
		loc	{{{GBR|Eastbourne|Eastbourne}}}							t	{[[Nature Valley International 2020/Damen|Nature Valley International]]}								f	Rasen}
	{ser	gs		date	29.06.	dur	13.07.
		loc	{{{GBR|London|London}}}										t	{[[Wimbledon Championships 2020|Wimbledon Championships]]}													f	Rasen}
	{ser	int	date	13.07.	dur	21.07.
		loc	{{{ROU|Bukarest|Bukarest}}}								t	{[[Bucharest Open 2020|Bucharest Open]]}																			f	Sand}
	{ser	int	date	13.07.	dur	21.07.
		loc	{{{CHE|Lausanne|Lausanne}}}								t	{[[Ladies Open Lausanne 2020|Ladies Open Lausanne]]}															f	Sand}
	{ser	int	date	20.07.	dur	29.07.
		loc	{{{LVA|Jūrmala|Jūrmala}}}									t	{[[Baltic Open 2020|Baltic Open]]}																					f	Sand}
	{ser	int	date	20.07.	dur	29.07.
		loc	{{{ITA|Palermo|Palermo}}}									t	{[[Palermo Ladies Open 2020|31° Palermo Ladies Open]]}														f	Sand}
	{ser	int	date	03.08.	dur	04.08.
		loc	{{{USA|Washington, D.C.|Washington}}}					t	{[[Citi Open 2020/Damen|Citi Open]]}																				f	Hartplatz}
	{ser	pr		date	03.08.	dur	04.08.
		loc	{{{USA|San José (Kalifornien)|San José}}}				t	{[[Mubadala Silicon Valley Classic 2020|Mubadala Silicon Valley Classic]]}								f	Hartplatz}
	{ser	pr5	date	10.08.	dur	11.08.
		loc	{{{CAN|Montreal|Montreal}}}								t	{[[Rogers Cup 2020/Damen|Rogers Cup]]}																				f	Hartplatz}
	{ser	pr5	date	17.08.	dur	18.08.
		loc	{{{USA|Cincinnati|Cincinnati}}}							t	{[[Western & Southern Open 2020/Damen|Western & Southern Open]]}											f	Hartplatz}
	{ser	pr		date	24.08.	dur	24.08.
		loc	{{{USA|Albany (New York)|Albany}}}						t	{[[Albany Open 2020|Albany Open]]}																					f	Hartplatz}


	{ser	gs		date	31.08.	dur	07.09.
		loc	{{{USA|New York City|New York}}}							t	{[[US Open 2020|US Open]]}																								f	Hartplatz}
	{ser	int	date	14.09.	dur	15.09.
		loc	{{{JPN|Hiroshima|Hiroshima}}}								t	{[[Japan Women’s Open 2020|Hana-cupid Japan Women’s Open]]}													f	Hartplatz}
	{ser	int	date	14.09.	dur	15.09.
		loc	{{{CHN|Nanchang|Nanchang}}}								t	{[[Jiangxi Open 2020|Jiangxi Open]]}																				f	Hartplatz}
	{ser	pr		date	14.09.	dur	15.09.
		loc	{{{CHN|Zhengzhou|Zhengzhou}}}								t	{[[Zhengzhou Open 2020|Zhengzhou Open]]}																			f	Hartplatz}
	{ser	pr		date	21.09.	dur	22.09.
		loc	{{{JPN|Tokio|Tokio}}}										t	{[[Toray Pan Pacific Open 2020|Toray Pan Pacific Open]]}														f	{Hartplatz (Halle)}}
	{ser	int	date	21.09.	dur	22.09.
		loc	{{{KOR|Seoul|Seoul}}}										t	{[[Korea Open 2020|Korea Open]]}																						f	Hartplatz}
	{ser	int	date	21.09.	dur	21.09.
		loc	{{{CHN|Guangzhou|Guangzhou}}}								t	{[[Guangzhou Open 2020|Guangzhou Open]]}																			f	Hartplatz}
	{ser	pr5	date	28.09.	dur	28.09.
		loc	{{{CHN|Wuhan|Wuhan}}}										t	{[[Wuhan Open 2020|Wuhan Open]]}																						f	Hartplatz}
	{ser	prm	date	05.10.	dur	06.10.
		loc	{{{CHN|Peking|Peking}}}										t	{[[China Open 2020 (Tennis)/Damen|China Open]]}																	f	Hartplatz}
	{ser	int	date	12.10.	dur	13.10.
		loc	{{{CHN|Tianjin|Tianjin}}}									t	{[[Tianjin Open 2020|Tianjin Open]]}																				f	Hartplatz}
	{ser	int	date	12.10.	dur	13.10.
		loc	{{{HKG}}}														t	{[[Prudential Hong Kong Tennis Open 2020|Prudential Hong Kong Tennis Open]]}							f	Hartplatz}
	{ser	int	date	12.10.	dur	13.10.
		loc	{{{AUT|Linz|Linz}}}											t	{[[Upper Austria Ladies Linz 2020|Upper Austria Ladies Linz]]}												f	{Hartplatz (Halle)}}
	{ser	pr		date	19.10.	dur	20.10.
		loc	{{{RUS|Moskau|Moskau}}}										t	{[[Kremlin Cup 2020/Damen|VTB Kremlin Cup]]}																		f	{Hartplatz (Halle)}}
	{ser	int	date	19.10.	dur	20.10.
		loc	{{{LUX|Luxemburg (Stadt)|Stadt Luxemburg}}}			t	{[[BGL BNP Paribas Luxembourg Open 2020|BGL BNP Paribas Luxembourg Open]]}								f	{Hartplatz (Halle)}}
	{ser	fin	date	26.10.	dur	27.10.
		loc	{{{CHN|Zhuhai|Zhuhai}}}										t	{[[WTA Elite Trophy 2020|WTA Elite Trophy Zhuhai]]}															f	Hartplatz}
	{ser	fin	date	02.11.	dur	03.11.
		loc	{{{CHN|Shenzhen|Shenzhen}}}								t	{[[WTA Championships 2020|Shiseido WTA Finals Shenzhen]]}													f	{Hartplatz (Halle)}}
}

#####

#####
set portalpage {<div style="margin-top: 10px; border: 1px solid #2E8B58; background-color: #f5f5f5; padding: 1em;">
<div style="float:right;text-align:right;"><small>{{bearbeiten|Portal:Tennis/Kommende Turniere}}</small></div>
{{Portal-head2|2E8B58|Kommende<!-- und laufende--> Turniere}}

}

set portalm {
'''[[ATP Tour 2020]]'''<br />
§| class="wikitable" style="font-size:90%"
|-
! width="50px"  |Datum
! width="195px" |Ort
! width="280px" |Turnier
! width="210px" |Serie
! width="145px" |Belag}

set portalf {
'''[[WTA Tour 2020]]'''<br />
§| class="wikitable" style="font-size:90%"
|-
! width="50px"  |Datum
! width="195px" |Ort
! width="280px" |Turnier
! width="210px" |Serie
! width="145px" |Belag}
#####

set d1 [clock add [clock seconds] -1 day]
set d4 [clock add [clock seconds] 4 weeks]

append portalpage $portalm

foreach ev $atp {
	dict with ev {
		if {$date eq {31.12.}} {set year 2019} else {set year 2020}
		set tf [clock scan $date.$year	-format %d.%m..%Y]
		set tt [clock scan  $dur.2020		-format %d.%m..%Y]
		if {$tt > $d1 && $tf < $d4} {
			switch $ser {
				 fin	{append portalpage "\n|- style=\"background:#ffffcc;\"\n| $date\n| $loc\n| $t\n| \[\[ATP World Tour Finals\]\]\n| $f"}
				  gs	{append portalpage "\n|- style=\"background:#e5d1cb;\"\n| $date\n| $loc\n| $t\n| \[\[Grand Slam (Tennis)|Grand Slam\]\]\n| $f"}
				1000	{append portalpage "\n|- style=\"background:#dfe2e9;\"\n| $date\n| $loc\n| $t\n| \[\[ATP World Tour Masters 1000\]\]\n| $f"}
				 500	{append portalpage "\n|- style=\"background:#d1eeee;\"\n| $date\n| $loc\n| $t\n| \[\[ATP World Tour 500\]\]\n| $f"}
				 250	{append portalpage "\n|-\n| $date\n| $loc\n| $t\n| \[\[ATP World Tour 250\]\]\n| $f"}
			}
		}
	}
}

append portalpage \n|\}\n$portalf

foreach ev $wta {
	dict with ev {
		if {$date in {30.12. 31.12.}} {set year 2019} else {set year 2020}
		set tf [clock scan $date.$year	-format %d.%m..%Y]
		set tt [clock scan  $dur.2020		-format %d.%m..%Y]
		if {$tt > $d1 && $tf < $d4} {
			switch $ser {
				fin	{append portalpage "\n|- style=\"background:#ffa500;\"\n| $date\n| $loc\n| $t\n| Jahresendveranstaltung\n| $f"}
				gs		{append portalpage "\n|- style=\"background:#ffff40;\"\n| $date\n| $loc\n| $t\n| \[\[Grand Slam (Tennis)|Grand Slam\]\]\n| $f"}
				prm	{append portalpage "\n|- style=\"background:#ff8247;\"\n| $date\n| $loc\n| $t\n| Premier Mandatory\n| $f"}
				pr5	{append portalpage "\n|- style=\"background:#d1eeee;\"\n| $date\n| $loc\n| $t\n| Premier 5\n| $f"}
				pr		{append portalpage "\n|- style=\"background:#dfe2d9;\"\n| $date\n| $loc\n| $t\n| Premier\n| $f"}
				int	{append portalpage "\n|-\n| $date\n| $loc\n| $t\n| International\n| $f"}
			}
		}
	}
}

append portalpage \n|\}\n</div>

if {[set portalpage [string map {§ \{} $portalpage]] ne [conts id 6901998 x]} {
	puts [edid 6901998 {Bot: Aktualisierung} $portalpage / minor]
}
