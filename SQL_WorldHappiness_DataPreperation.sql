/*Adding the "year" column into data, to keep the information after merging the tables - gogr*/

-- For table '2015'
ALTER TABLE happiness."2015"
ADD COLUMN year INT;

UPDATE happiness."2015"
SET year = 2015;

-- For table '2019'
ALTER TABLE happiness."2016"
ADD COLUMN year INT;

UPDATE happiness."2016"
SET year = 2016;

-- For table '2017'
ALTER TABLE happiness."2017"
ADD COLUMN year INT;

UPDATE happiness."2017"
SET year = 2017;

-- For table '2018'
ALTER TABLE happiness."2018"
ADD COLUMN year INT;

UPDATE happiness."2018"
SET year = 2018;

-- For table '2019'
ALTER TABLE happiness."2019"
ADD COLUMN year INT;

UPDATE happiness."2019"
SET year = 2019;

/*-------------------------*/

/* Assembly of all tables into one database "all_data"-gogr*/

CREATE TABLE happiness.all_data AS
select 
  "year",
  "Country",
  "Region",
  "Happiness Rank" AS "Happiness Rank",
  "Happiness Score" AS "Happiness Score",
  "Economy (GDP per Capita)" AS "Economy (GDP per Capita)",
  "Family",
  "Health (Life Expectancy)" AS "Health (Life Expectancy)",
  "Freedom",
  "Trust (Government Corruption)" AS "Trust (Government Corruption)",
  "Generosity" ,
  "Dystopia Residual"
FROM
  happiness."2015" t15 
union
select 
  "year",
  "Country",
  "Region",
  "Happiness Rank" AS "Happiness Rank",
  "Happiness Score" AS "Happiness Score",
  "Economy (GDP per Capita)",
  "Family",
  "Health (Life Expectancy)",
  "Freedom",
  "Trust (Government Corruption)",
  "Generosity",
  "Dystopia Residual"
FROM
  happiness."2016" t16 
union
select 
  "year",
  "Country",
  NULL AS "Region", 
  "Happiness.Rank" AS "Happiness Rank",
  "Happiness.Score" AS "Happiness Score",
  "Economy..GDP.per.Capita." AS "Economy (GDP per Capita)",
  "Family",
  "Health..Life.Expectancy." AS "Health (Life Expectancy)",
  "Freedom",
  "Trust..Government.Corruption." AS "Trust (Government Corruption)",
  "Generosity",
  "Dystopia.Residual"
FROM
  happiness."2017" t17 
union
select 
  "year",
  "Country or region" AS "Country",
  NULL AS "Region",
  "Overall rank" AS "happiness Rank",
  "Score" AS "happiness Score",
  "GDP per capita" AS "Economy (GDP per Capita)",
  "Social support" AS "Family",
  "Healthy life expectancy" AS "Health (Life Expectancy)",
  "Freedom to make life choices" AS "Freedom",
  case when "Perceptions of corruption" = 'N/A' then null::float
  	   else cast("Perceptions of corruption" as float) 
  end
  as "Trust (Government Corruption)",
  "Generosity",
  CAST(NULL AS FLOAT) AS "Dystopia Residual"
FROM
  happiness."2018" t18 
union
select 
  "year",
  "Country or region" as "Country",
  NULL AS "Region",
  "Overall rank" as "Happiness Rank",
  "Score" as "Happiness Score",
  "GDP per capita" as "Economy (GDP per Capita)",
  "Social support" as "Family",
  "Healthy life expectancy" as "Health (Life Expectancy)" ,
  "Freedom to make life choices" as "Freedom",
  "Perceptions of corruption" as "Trust (Government Corruption)",
  "Generosity",
  CAST(NULL AS FLOAT) AS "Dystopia Residual"
FROM
  happiness."2019" t19;

/*---------------------------------------*/
 
-- Simple integrity check
  
select * from happiness.all_data
order by "Country" ;


/* Calculate "Dystopia Residual" for 2017-2019 */

UPDATE happiness.all_data
SET "Dystopia Residual" = (	"Happiness Score" - 
							"Economy (GDP per Capita)" - 
							"Family" - 
							"Health (Life Expectancy)" -
							"Freedom" -
							"Trust (Government Corruption)" - 
							"Generosity" )
WHERE "Dystopia Residual" IS null;

/* Replacing inconsistant state names in different years. */

UPDATE happiness.all_data set "Country" = case 
	when "Country" = 'Hong Kong S.A.R., China' then 'Hong Kong'
	when "Country" = 'Northern Cyprus' then 'North Cyprus'
	when "Country" = 'Somaliland region' then 'Somaliland Region'
	when "Country" = 'Taiwan Province of China' then 'Taiwan'
	when "Country" = 'Trinidad & Tobago' then 'Trinidad and Tobago'
	else "Country"
end;

select * from happiness.all_data
order by "Country", "year"  ;

-------------------------------------------

/* Update Region for 2017-2019 */

UPDATE happiness.all_data
SET "Region" = "2015"."Region"
FROM "2015" 
WHERE "2015"."Country" = all_data."Country";

UPDATE happiness.all_data
SET "Region" = "2016"."Region"
FROM "2016" 
WHERE "2016"."Country" = all_data."Country";

/*Checking which countries are missing the region*/

select * from happiness.all_data
where "Region" is null;

/*enter region for Gambia and North Macedonia*/

UPDATE happiness.all_data
SET "Region" = 'Central and Eastern Europe'
WHERE "Country" = 'North Macedonia';

UPDATE happiness.all_data
SET "Region" = 'Sub-Saharan Africa'
WHERE "Country" = 'Gambia';

select * from happiness.all_data
order by "Country", "year";

/*Checking how many results we have for countries, and the number of countries for each year */

select "Country" , count(*)  
from happiness.all_data 
group by 1
order by count(*), "Country"; 

select "year"  , count(*)  
from happiness.all_data 
group by 1
order by "year" asc; 

select distinct "Country" , "Region", count(*) 
from happiness.all_data 
group by 1, 2
order by "Country" asc;


