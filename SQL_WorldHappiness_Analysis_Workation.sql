select * from happiness.all_data
order by "Happiness Rank", "year" ;


--sprawdzenie korelacji
select 	corr ("Economy (GDP per Capita)","Happiness Score") as CorrEconomy,
		corr ("Family","Happiness Score") as CorrFamily,
		corr ("Health (Life Expectancy)","Happiness Score") as CorrHealth,
		corr ("Freedom","Happiness Score") as CorrFreedom,
		corr ("Trust (Government Corruption)","Happiness Score") as CorrTrust,		
		corr ("Generosity","Happiness Score") as CorrGenerosity,	
		corr ("Dystopia Residual","Happiness Score") as CorrDystopia
from happiness.all_data;

-- sprawdzenie wartosci max i min
select 	max("Economy (GDP per Capita)"),
		max("Family"),
		max("Health (Life Expectancy)"),
		max("Freedom"),
		max("Trust (Government Corruption)"),		
		max("Generosity"),
		max ("Dystopia Residual")
from happiness.all_data;

select 	min("Economy (GDP per Capita)"),
		min("Family"),
		min("Health (Life Expectancy)"),
		min("Freedom"),
		min("Trust (Government Corruption)"),		
		min("Generosity"),
		min ("Dystopia Residual")
from happiness.all_data;


/*pod uwage bralabym tylko: happiness score, economie, zdrowie i wolność. 
Rodzina, zafanie do rzadu, hojnosc i dystopia raczej nie maja wplywu na workation*
Zgodnie z zalozeniem ze spotkania patrzymy tylko na rok 2019
- widac bylo po wykresach ze wskazniki w kazdym roku zmieniaja sie w taki sam sposob.*/


-- TOP10 w 2019 Happiness score
select  "Country", "Region", "Happiness Score" 
from happiness.all_data ad 
where "year" = 2019
order by "Happiness Score" desc 
limit(10)

-- TOP10 w 2019 Economy
select  "Country", "Region", "Economy (GDP per Capita)"  
from happiness.all_data ad 
where "year" = 2019
order by "Economy (GDP per Capita)"  desc 
limit(10)

-- TOP10 w 2019 Zdrowie
select  "Country", "Region", "Health (Life Expectancy)"  
from happiness.all_data ad 
where "year" = 2019
order by "Health (Life Expectancy)"  desc 
limit(10)

-- TOP10 w 2019 Wolnosc
select  "Country", "Region", "Freedom"  
from happiness.all_data ad 
where "year" = 2019
order by "Freedom"  desc 
limit(10)


--sprawdzmy regiony: w jakich regionach jaka najwyzsza pozycje ma Panstwo

select distinct "Region", min("Happiness Rank") 
from happiness.all_data ad 
where "year" = 2019
group by 1 
order by 2 asc 

/*mamy 10 regionow:
Western Europe
North America
Australia and New Zealand
Middle East and Northern Africa
Latin America and Caribbean
Central and Eastern Europe
Southeastern Asia
Eastern Asia
Sub-Saharan Africa
Southern Asia*/

-- rankingi regionow odnosnie sredniej rankingu szczescia

select distinct "Region", round(avg("Happiness Rank")::numeric) as avg_happ_rank
from happiness.all_data ad 
where "year" = 2019
group by 1 
order by 2 asc 


--SPRAWDZENIE SREDNIEJ SWIATOWEJ WYNIKOW

select 	min("Happiness Score") as min_happ, 
		max("Happiness Score") as max_happ,
		avg("Happiness Score") as avg_happ,
		min("Economy (GDP per Capita)") as min_econ, 
		max("Economy (GDP per Capita)") as max_econ,
		avg("Economy (GDP per Capita)") as avg_econ,
		min("Health (Life Expectancy)") as min_heal, 
		max("Health (Life Expectancy)") as max_heal,
		avg("Health (Life Expectancy)") as avg_heal,
		min("Freedom") as min_free, 
		max("Freedom") as max_free,
		avg("Freedom") as avg_free
from happiness.all_data ad 
where "year" = 2019

select 	"Region",
		min("Happiness Score") as min_happ, 
		max("Happiness Score") as max_happ,
		avg("Happiness Score") as avg_happ,
		min("Economy (GDP per Capita)") as min_econ, 
		max("Economy (GDP per Capita)") as max_econ,
		avg("Economy (GDP per Capita)") as avg_econ,
		min("Health (Life Expectancy)") as min_heal, 
		max("Health (Life Expectancy)") as max_heal,
		avg("Health (Life Expectancy)") as avg_heal,
		min("Freedom") as min_free, 
		max("Freedom") as max_free,
		avg("Freedom") as avg_free
from happiness.all_data ad 
where "year" = 2019
group by 1


/* AVG happiness 5,407 
 * AVG Economy 0,905
 * AVG Health 0,725
 * AVG Freedom 0,392
 */


-- jesli wezmiemy pod uwage wszystko co jest powyzej sredniej - lub mozemy przyjac np 75% top wynikow...

select *
from happiness.all_data
where "year" = 2019 and "Happiness Score" > 5.407 and "Economy (GDP per Capita)" > 0.905 and "Health (Life Expectancy)" > 0.725 and "Freedom" > 0.392
order by "Happiness Score" desc

--wynikiem jest 47 krajow

--Jesli by zapisac to jako tabele i przeprowadzic analize regionami
create temp table above_avg as
select *
from happiness.all_data
where "year" = 2019 and "Happiness Score" > 5.407 and "Economy (GDP per Capita)" > 0.905 and "Health (Life Expectancy)" > 0.725 and "Freedom" > 0.392
order by "Happiness Score" desc


--tabela krajow powyzej sredniej segregowana po regionach
select *
from above_avg
order by "Region", "Happiness Score" desc

--tabela krajow powyzej sredniej - segregowana po GDP
select *
from above_avg
order by "Economy (GDP per Capita)" desc


-- posegregowac tabele regionami
select "Region", count(*) 
from above_avg
group by 1
order by "Region"

-- widac ze odpadl nam region 
-- Southern Asia 
-- Sub-Saharan Africa ma tylko 1 wynik (ze wzgledu na zdrowie, bezpieczenstwo i wolnosc - mozna by wyeliminowac
-- te dwa regiony bardzo slabo wszedzie wypadaja
-- Middle East and Northern Africa (ze wzgledu na konflikty, wolnosc i bezpieczenstwo - kobiety i LGBTQ) - tez bym wyeliminowala - qatar arabia saudyjska zjednoczone emiraty itd.

-- reszte analizy poprowadzilabym regionami:
-- np dla western europe moze wybrac same kraje z niskim GDP? 
-- lub odciac od gory jeszcze z 10 % krajow ktych GDP jest najwyzsze (ze wzgledow budzetowych)
-- Odcielabym wszsytsko powyzej 1,34 GDP - Finlandia - jakies 15% calosci

-- tabela z wynikami krajow powyzej sredniej bez krajow afrykanskich i arabskich oraz bez najdrozszych krajow (najwyzsze GDP)

create temp table workation_countries as
select *
from above_avg
where "Economy (GDP per Capita)" < 1.34 and "Region" != 'Middle East and Northern Africa' and "Region" != 'Sub-Saharan Africa'


-- MAMY LISTE 24 KRAJOW dosc szczesliwych z dobra opieka zdrowotna i ok wspolczynnikiem wolnosci oraz z ekonomia na poziomie srednim/wysokim
select *
from workation_countries
order by "Happiness Score" desc
 
-------------------------------------------------------------------


-- inne sprawdzenia do analizy:

-- TABELA ZE SREDNIMI WYNIKAMI DLA REGIONOW ORAZ SUMA TYCH SREDNICH WYNKOW
with
	avg_happ_t as (select distinct "Region", round(avg("Happiness Score")::numeric,3) as avg_happ_sc 
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc),
	avg_econ_t as (select distinct "Region", round(avg("Economy (GDP per Capita)")::numeric,3) as avg_econ_sc
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc), 
	avg_health_t as (select distinct "Region", round(avg("Health (Life Expectancy)")::numeric,3) as avg_health_sc
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc),
	avg_freedom_t as (select distinct "Region", round(avg("Freedom")::numeric,3) as avg_freedom_sc 
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc)
select avg_happ_t."Region", "avg_happ_sc", "avg_econ_sc", "avg_health_sc", "avg_freedom_sc", ("avg_happ_sc" + "avg_econ_sc" + "avg_health_sc" + "avg_freedom_sc") as sum_avg 
from avg_happ_t
	left join avg_econ_t on avg_happ_t."Region" = avg_econ_t."Region"
	left join avg_health_t  on avg_happ_t."Region" = avg_health_t."Region"	
	left join avg_freedom_t on avg_happ_t."Region" = avg_freedom_t."Region"
order by "avg_happ_sc" desc 


--- tabela porownanie regionow z max i min wartosciami
with
	avg_rank_t2 as (select distinct "Region", max("Happiness Rank") as worst_rank_sc, min("Happiness Rank") as best_rank_sc 
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc),
	avg_happ_t2 as (select distinct "Region", max("Happiness Score") as max_happ_sc, min("Happiness Score") as min_happ_sc 
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc),
	avg_econ_t2 as (select distinct "Region", max("Economy (GDP per Capita)") as max_econ_sc, min("Economy (GDP per Capita)") as min_econ_sc
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc), 
	avg_health_t2 as (select distinct "Region", max("Health (Life Expectancy)") as max_health_sc, min("Health (Life Expectancy)") as min_health_sc
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc),
	avg_freedom_t2 as (select distinct "Region", max("Freedom") as max_freedom_sc, min("Freedom") as min_freedom_sc 
					from happiness.all_data ad 
					where "year" = 2019
					group by 1 
					order by 2 desc)
select avg_happ_t2."Region", "best_rank_sc", "worst_rank_sc", "max_happ_sc", "min_happ_sc", "max_econ_sc", "min_econ_sc", "max_health_sc", "min_health_sc", "max_freedom_sc", "min_freedom_sc" 
from avg_rank_t2
	left join avg_happ_t2 on avg_rank_t2."Region" = avg_happ_t2."Region"
	left join avg_econ_t2 on avg_rank_t2."Region" = avg_econ_t2."Region"
	left join avg_health_t2  on avg_rank_t2."Region" = avg_health_t2."Region"	
	left join avg_freedom_t2 on avg_rank_t2."Region" = avg_freedom_t2."Region"
order by "worst_rank_sc" asc 



-- INNE PODEJSCIE ANALIZA REGIONAMI:

/*zeby miec jakies ograniczenia - po analizie tych danych nie bralabym pod uwage regionow 
Middle East and Northern Africa (ze wzgledu na konflikty, wolnosc i bezpieczenstwo)
Sub-Saharan Africa(ze wzgledu na zdrowie, bezpieczenstwo i wolnosc)
Southern Asia (jak powyzej)*/


-- top 5 krajow zgdonie z regionami:


-- TOP5 w 2019 Happiness score dla Western Europe
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Western Europe'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Western Europe
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Western Europe'
order by "Economy (GDP per Capita)"  desc 
limit(5)

-- TOP5 od konca w 2019 Economy dla Western Europe i uszeregowona po happiness rank
with 
	minEconomy_highRank as (select  "Country", "Region", "Economy (GDP per Capita)", "Happiness Rank" 
    						from all_data ad 
    						where "year" = 2019 and "Region" = 'Western Europe'
    						order by "Economy (GDP per Capita)" asc 
    						limit(5))
select "Country", "Region", "Economy (GDP per Capita)", "Happiness Rank"
from minEconomy_highRank
order by "Happiness Rank" asc 


/*North America - tylko Canada i USA - nie ma sensu glebiej tego analizowac*/

-- TOP5 w 2019 Happiness score dla North America
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'North America'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla North America
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'North America'
order by "Economy (GDP per Capita)"  desc 
limit(5)

-- TOP5 w 2019 Health dla North America
select  "Country", "Region", "Health (Life Expectancy)" 
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'North America'
order by "Health (Life Expectancy)"  desc 
limit(5)

-- TOP5 w 2019 Freedom dla North America
select  "Country", "Region", "Freedom"  
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'North America'
order by "Freedom"  desc 
limit(5)


/*Australia and New Zealand - tylko 2 kraje - nie ma sensu glebiej tego analizowac*/

-- TOP5 w 2019 Happiness score dla Australia and New Zealand
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Australia and New Zealand'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Australia and New Zealand
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Australia and New Zealand'
order by "Economy (GDP per Capita)"  desc 
limit(5)



-- TOP5 w 2019 Happiness score dla Middle East and Northern Africa
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Middle East and Northern Africa'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Middle East and Northern Africa
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Middle East and Northern Africa'
order by "Economy (GDP per Capita)"  desc 
limit(5)



-- TOP5 w 2019 Happiness score dla Latin America and Caribbean
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Latin America and Caribbean'
order by "Happiness Score" desc 
limit(5)



-- TOP5 w 2019 Economy dla Latin America and Caribbean
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Latin America and Caribbean'
order by "Economy (GDP per Capita)"  desc 
limit(5)

-- TOP5 w 2019 Happiness score dla Central and Eastern Europe
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Central and Eastern Europe'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Central and Eastern Europe
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Central and Eastern Europe'
order by "Economy (GDP per Capita)"  desc 
limit(5)

-- TOP5 w 2019 Happiness score dla Southeastern Asia
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Southeastern Asia'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Southeastern Asia
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Southeastern Asia'
order by "Economy (GDP per Capita)"  desc 
limit(5)


-- TOP5 w 2019 Happiness score dla Eastern Asia
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Eastern Asia'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Eastern Asia
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Eastern Asia'
order by "Economy (GDP per Capita)"  desc 
limit(5)

-- TOP5 w 2019 Happiness score dla Sub-Saharan Africa
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Sub-Saharan Africa'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Sub-Saharan Africa
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Sub-Saharan Africa'
order by "Economy (GDP per Capita)"  desc 
limit(5)

-- TOP5 w 2019 Happiness score dla Southern Asia
select  "Country", "Region", "Happiness Score"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Southern Asia'
order by "Happiness Score" desc 
limit(5)

-- TOP5 w 2019 Economy dla Southern Asia
select  "Country", "Region", "Economy (GDP per Capita)"
from happiness.all_data ad 
where "year" = 2019 and "Region" = 'Southern Asia'
order by "Economy (GDP per Capita)"  desc 
limit(5)

