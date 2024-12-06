-----------------------------------------------------
--- ANALIZA
 -- PODEJSCIE ZE SREDNIMI WAżONYMI:
 
select * 
from happiness.all_data ad 
where "year" = 2019 
order by "Country" 

 
 /* sprawdzam min i max dla wszystkich wspolczynnikow i okreslam 
  * min jako 0 
  * max jako 1 
  * zeby miec dane w jendych jednostkach - i miec bardziej czytelna baze danych
  *
  */
 
 select min("Happiness Score") as min_happ, 
		max("Happiness Score") as max_happ,
		min("Economy (GDP per Capita)") as min_econ, 
		max("Economy (GDP per Capita)") as max_econ,
		min("Family") as min_fam, 
		max("Family") as max_fam,
		min("Health (Life Expectancy)") as min_heal, 
		max("Health (Life Expectancy)") as max_heal,
		min("Freedom") as min_free, 
		max("Freedom") as max_free,
		min("Trust (Government Corruption)") as min_trust, 
		max("Trust (Government Corruption)") as max_trust,	
		min("Generosity" ) as min_gen, 
		max("Generosity" ) as max_gen,
		min("Dystopia Residual") as min_dyst, 
		max("Dystopia Residual") as max_dyst
from happiness.all_data ad 
where "year" = 2019
 
 /* odrzucam dystorpie - 
 * która zgodnie z definicją wynosi 1,85 (najmniej szczesliwe panstwo) i dodatkowe niewyjasnione wspolczynniki, które nie zostały uwzględnione w 6 współczynnikach głownych*/

/* min_happ = 2.853
 * max_happ = 7.769
 * min_econ = 0
 * max_econ = 1.684
 * min_fam = 0
 * max_fam = 1.624
 * min_health = 0
 * max health = 1.141
 * min.freedom = 0
 * max_freedom = 0.631
 * min_trust= 0
 * max trust=0.453
 * min_gen = 0
 * max_gen = 0.566
 * 
 * */

-- tworze tabele w ktorej wartosc wspolczynnika dziele przez max - dzieki czemu uzyskuje wartosci od 0-1
-- happiness score jako jedyny ma wartosc minimalna inna niz 0 więc dla niego wartosc 1 przypada dla wartosci (x - min)/(max - min)

create table happiness.workation_unitised as
 select 
 "year",
 "Country",
 "Region",
 "Happiness Rank",
 round((("Happiness Score" - 2.853)/(7.769 - 2.853)) ::numeric, 3) as "happiness_score_unit",
 round(("Economy (GDP per Capita)"/1.684 )::numeric, 3) as "economy_unit",
 round(("Family"/1.624 )::numeric, 3) as "Family_unit",
 round(("Health (Life Expectancy)"/1.141 )::numeric, 3) as "heatlh_unit",
 round(("Freedom"/0.631 )::numeric, 3) as "freedom_unit",
 round(("Trust (Government Corruption)"/0.453 )::numeric,3) as "trust_unit",
 round(("Generosity"/0.566 )::numeric, 3) as "generosity_unit"
from happiness.all_data ad 
where "year" = 2019 

select * from happiness.workation_unitised
 
 /* mamy 7 wspolczynnikow w takiej samej skali:
 
 	Jeśli postanowimy ze idealny kraj na workation miałby wynik 100
 	to mozemy przydzielic wagi wspolczynnikom:

	Happiness score - 40		-- Wynik szczęścia odzwierciedla ogólne samopoczucie i zadowolenie populacji.
	Economy - 5					-- Dobrobyt gospodarczy przyczynia się do jakości życia i dostępnych udogodnień, ale nie chcemy drogich krajow wiec mniejsza waga
	Family - 5					-- Rodzina i wsparcie socjalnie może nie mieć zbyt dużego wpływu na workation
	Health - 20					-- Bardzo wazny dostep do opieki zdrowotnej
	Freedom - 20				-- wolnosc bardzo wazna
	Trust - 5					-- nie koniecznie duży wpływ na workation
	Generosity - 5				-- hojnosc, nie koniecznie wplyw na workation
  */


select
   "year",
   "Country",
   "Happiness Rank",
   sum("happiness_score_unit" * 40 + "economy_unit" * 5 + "Family_unit" * 5 + "heatlh_unit" * 20 + "freedom_unit" * 20 + "trust_unit"*5+ "generosity_unit"*5) as "workation_score"
from happiness.workation_unitised
group by 1,2,3
order by "workation_score" desc 

-- porównajmy czy byłaby różnica na właściwych wsółczynnikach:

select
   "year",
   "Country",
   "Happiness Rank",
   sum("Happiness Score"* 40 + "Economy (GDP per Capita)"* 5 + "Family"* 5 + "Health (Life Expectancy)"* 20 + "Freedom"* 20 + "Trust (Government Corruption)"*5+ "Generosity"*5) as "workation_score"
from happiness.all_data ad 
where "year" = 2019
group by 1,2,3
order by "workation_score" desc 

--  top to ciagle kraje top najszczesliwsze, a nie najlepsze pod workation


select avg("happiness_score_unit"),
		avg("economy_unit"),
		avg("economy_unit"),
		avg("Family_unit"),
		avg("heatlh_unit"),
		avg("freedom_unit"),
		avg("trust_unit"),
		avg("generosity_unit")
from happiness.workation_unitised

select * from happiness.workation_unitised

-- Jak mamy każdy współczynnik opisany na jednostce od 0-1 łatwo nam nałożyć jakieś ramy i wartości, żeby ograniczyć liste krajów.

create temp table countries_for_workation as
select *
from happiness.workation_unitised wu 
where "happiness_score_unit" > 0.6  	-- Wynik szczęścia odzwierciedla ogólne samopoczucie i zadowolenie populacji.
		and "economy_unit" > 0.6 		-- Dobrobyt gospodarczy przyczynia się do jakości życia i dostępnych udogodnień - rozwinięta sieć internetowa, drogi, komunikacja etc 
		and "economy_unit" < 0.8 		-- ale nie chcemy zbyt drogich krajów więc odetnijmy część najdroższych krajów od góry
		and "Family_unit" > 0.7 		-- Wspierające środowisko społeczne, zwłaszcza pod względem więzi rodzinnych, ma kluczowe znaczenie dla zdrowej równowagi w życiu
		and "heatlh_unit" > 0.6 		-- oczekiwana długość życia odzwierciedla ogólny stan zdrowia i opieki zdrowotnej w danym kraju
		and "freedom_unit" > 0.6 		-- Wolność osobista przyczynia się do pozytywnego doświadczenia w życiu, umożliwiając jednostkom dokonywanie wyborów zgodnych z ich preferencjami i stylem życia.
order by "happiness_score_unit" desc

 select * from countries_for_workation
 
 
 -- mamy 21 wyników
 -- dobra lista pod workation
 
 
 
------------------------------------------------------------------------------------------------------
 
 -- ANALIZA 2 -  BIERZEMY POD UWAGE DYSTORPIE bez Happiness score
 
 
 
 ----------------------------------------------------------------------------------------------------
 
 -- ANALIZA 2
 
 -- Odcinamy polowe najmneij szczesliwych krajów:
 
 
select * from happiness.all_data
where "year" = 2019
order by "Happiness Rank", "year"

-- mamy 156 krajow - tworze tabele z 78 krajami

create table happiness.workation_betterhalf as
select * 
from happiness.all_data
where "year" = 2019 and "Happiness Rank" <=78
order by "Happiness Rank"
 
select *
from happiness.workation_betterhalf
order by "Region"
 
-- odrzucamy kraje, które nie do końca mogą być bezpieczne I są zbyt duże różnice kulturowe np. dla kobiet: Wywalam cały region Middle East and Northern Africa oraz Sub-Saharan Africa

create temp table workation_better as
select * 
from happiness.all_data
where "year" = 2019 and "Happiness Rank" <=78 and "Region" != 'Middle East and Northern Africa' and "Region" != 'Sub-Saharan Africa'
order by "Happiness Rank"

select *
from workation_better
order by "Economy (GDP per Capita)" desc 

-- mamy liste 70 krajów
-- Odcinam 20 najbogatszych krajów na liscie - tam gdzie GDP najwieksze

create table happiness.workation_selection as
select * 
from happiness.all_data
where "year" = 2019 and "Happiness Rank" <=78 and "Region" != 'Middle East and Northern Africa' and "Region" != 'Sub-Saharan Africa' and "Economy (GDP per Capita)" < 1.325
order by "Happiness Rank"

select *
from happiness.workation_selection
order by "Happiness Rank"

-- mamy liste 50 krajow - polowa najszczesliwszych krajow na swiecie - bez najwyzszych GDP i usunietymi krajami afrykanskimi i bliskowschodnimi
-- myśle już każdy z tych krajów mogłby być fajnym pomysłem na workation ale wybierzmy najlepsze z etego przedziału

select
   "year",
   "Country",
   "Region" 
   "Happiness Rank",
   sum("Dystopia Residual" * 20 + "Economy (GDP per Capita)"* 10 + "Family"* 10 + "Health (Life Expectancy)"* 20 + "Freedom"* 30 + "Trust (Government Corruption)"*5+ "Generosity"*5) as "workation_score"
from happiness.workation_selection
group by 1,2,3
order by "workation_score" desc 


 /* Wartosci ktore mamy nie sa w jednej skali - jesli chcemy nałożyc wagi musimy je sprowadzić do jednej skali 
  * Lub ująć już te różnice w wagach.
  * Naszą tabele z 50 krajami sprowadze do jednej skali - i przelicze ich wartości w taki sposób, że 1 maksymalna wartość dla przedziału tych państw, 0 - minimalna)
  *
  */

select min("Happiness Score") as min_happ, 
		max("Happiness Score") as max_happ,
		min("Economy (GDP per Capita)") as min_econ, 
		max("Economy (GDP per Capita)") as max_econ,
		min("Family") as min_fam, 
		max("Family") as max_fam,
		min("Health (Life Expectancy)") as min_heal, 
		max("Health (Life Expectancy)") as max_heal,
		min("Freedom") as min_free, 
		max("Freedom") as max_free,
		min("Trust (Government Corruption)") as min_trust, 
		max("Trust (Government Corruption)") as max_trust,	
		min("Generosity" ) as min_gen, 
		max("Generosity" ) as max_gen,
		min("Dystopia Residual") as min_dyst, 
		max("Dystopia Residual") as max_dyst
from happiness.workation_selection
 
 /* dystopia:
 * zgodnie z definicją wynosi 1,85 (najmniej szczesliwe panstwo) i dodatkowe niewyjasnione wspolczynniki, które nie zostały uwzględnione w 6 współczynnikach głownych*/

/* min_happ = 5.386
 * max_happ = 7.307
 * min_econ = 0.493
 * max_econ = 1.324
 * min_fam = 0.886
 * max_fam = 1.557
 * min_health = 0.535
 * max health = 1.062
 * min.freedom = 0.159
 * max_freedom = 0.631
 * min_trust= 0
 * max trust=0.380
 * min_gen = 0.04
 * max_gen = 0.375
 * min dyst= 1.39
 * max_dyst = 2.93
 *
 * */

-- tworze tabele w ktorej wartosc wspolczynnika dziele przez max - dzieki czemu uzyskuje wartosci od 0-1
-- (x - min)/(max - min)

create table happiness.workation_select_unit as
 select 
 "year",
 "Country",
 "Region",
 "Happiness Rank",
 round((("Happiness Score" - 5.386)/(7.307 - 5.386)) ::numeric, 3) as "happiness_score_unit",
 round((("Dystopia Residual" - 1.39)/(2.93 - 1.39)) ::numeric, 3) as "dystopia_score_unit",
 round((("Economy (GDP per Capita)" - 0.493)/(1.324 - 0.493) )::numeric, 3) as "economy_unit",
 round((("Family" - 0.886)/(1.557 - 0.886) )::numeric, 3) as "Family_unit",
 round((("Health (Life Expectancy)" - 0.535)/(1.062 - 0.535) )::numeric, 3) as "heatlh_unit",
 round((("Freedom" - 0.159)/(0.631 - 0.159))::numeric, 3) as "freedom_unit",
 round(("Trust (Government Corruption)"/0.380 )::numeric,3) as "trust_unit",
 round((("Generosity" -0.04)/(0.375 - 0.04 ))::numeric, 3) as "generosity_unit"
from happiness.workation_selection

select * from happiness.workation_select_unit 

 /* 
  * 
  * mamy 7 wspolczynnikow w takiej samej skali:
 
 	Jeśli postanowimy ze idealny kraj na workation miałby wynik 100 
 	to mozemy przydzielic wagi wspolczynnikom:

	Dystorpia - 20				-- dodatkowe niewyjasnione wspolczynniki, które nie zostały uwzględnione w 6 współczynnikach głownych + 1,85 najmniej szczesliwe panstwo
	Economy - 15				-- Dobrobyt gospodarczy przyczynia się do jakości życia i dostępnych udogodnień - rozwinięta sieć internetowa, drogi, komunikacja etc 
	Family - 15					-- Wspierające środowisko społeczne, zwłaszcza pod względem więzi rodzinnych, ma kluczowe znaczenie dla zdrowej równowagi w życiu
	Health - 20					-- oczekiwana długość życia odzwierciedla ogólny stan zdrowia i opieki zdrowotnej w danym kraju
	Freedom - 20				-- Wolność osobista przyczynia się do pozytywnego doświadczenia w życiu, umożliwiając jednostkom dokonywanie wyborów zgodnych z ich preferencjami i stylem życia.
	Trust - 5					-- nie koniecznie duży wpływ na workation
	Generosity - 5				-- hojnosc, nie koniecznie wplyw na workation
  */


select
   "year",
   "Country",
   "Happiness Rank",
   sum("dystopia_score_unit" * 20 + "economy_unit" * 15 + "Family_unit" * 15 + "heatlh_unit" * 20 + "freedom_unit" * 20 + "trust_unit" * 5 + "generosity_unit" * 5) as "workation_score"
from happiness.workation_select_unit   
group by 1,2,3
order by "workation_score" desc

select * from happiness.workation_select_unit 
 
create table happiness.workation_top as 
select 
"year", 
"Country", 
"Region", 
"Happiness Rank", 
"happiness_score_unit", 
"dystopia_score_unit", 
"economy_unit", 
"Family_unit", 
"heatlh_unit", 
"freedom_unit", 
"trust_unit", 
"generosity_unit",
sum("dystopia_score_unit" * 20 + "economy_unit" * 15 + "Family_unit" * 15 + "heatlh_unit" * 20 + "freedom_unit" * 20 + "trust_unit" * 5 + "generosity_unit" * 5) as "workation_score"
from workation_select_unit  
group by 1,2,3,4,5,6,7,8,9,10,11,12


create table happiness.workation_top20 as 
select *
from workation_top 
where "workation_score" > 59
order by "workation_score" desc

select * from happiness.workation_top20 

 