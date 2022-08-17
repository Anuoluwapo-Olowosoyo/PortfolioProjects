--SKIMMING THROUGH DATASET
select * from PUBLIC.covid_deaths cd
where continent is not null 
order by 3,4

-- SELECTING DATA TO BE USED IN THE COURSE OF PROJECT
select location, date, total_cases, new_cases, total_deaths, population
from PUBLIC.covid_deaths cd
where (total_cases, new_cases, total_deaths, population, continent) is not null
order by 1,2 

-- TAKING A LOOK AT TOTAL CASES Vs TOTAL DEATHS
-- Showing likelihood of dying if you contract covid in your country/continent
select location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PUBLIC.covid_deaths cd
where continent like '%Africa%'
--and "location" like '%Nigeria%'
and (total_cases, total_deaths) is not null
order by 3,4 

--LOOKING AT TOTAL CASES Vs POPULATION
--Showing population that has contracted covid
select location, continent, date, population, total_cases, (total_cases/population)*100 as contracted_percentage
from PUBLIC.covid_deaths cd
where total_cases is not null 
--and continent like '%Africa%'
order by 3,4


-- COUNTRIES WITH THE HIGHEST INFECTION RATE IN COMPARISON TO POPULATION
select location, population, MAX(total_cases) as HIGHESTINFECTIONCOUNT, 
MAX((total_cases/population))*100 as INFECTED_POPULATIONPERCENTAGE
from PUBLIC.covid_deaths
where (continent, total_cases, population) is not null
--and continent like '%Africa%'
--and "location" like '%Nigeria%'
group by location, population 
order by INFECTED_POPULATIONPERCENTAGE desc 


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select location, MAX(total_deaths) as TotalDeathCounts
from PUBLIC.covid_deaths
where (total_deaths,continent) is not null
--and continent like '%Africa%'
--and location like '%Nigeria%'
group by location
order by TotalDeathCounts desc 

--BREAKING THINGS DOWN BY CONTINENTS

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
select continent, MAX(total_deaths) as TotalDeathCount
from PUBLIC.covid_deaths 
where (total_deaths,continent) is not null
--and continent like '%Africa%'
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select SUM(new_cases) as SUM_TOTALNEWCASES, SUM(new_deaths)  as SUM_TOTALNEWDEATHS, 
SUM(new_deaths)/SUM(new_cases)*100 as Totaldeath_percentage
from PUBLIC.covid_deaths cd
--where location like '%Nigeria%'
where (new_cases, new_deaths) is not null
and continent is not null
--group by "date" 
order by 1,2


--LOOKING AT TOTAL POPULATION Vs VACCINATIONS
--Shows Percentage of Population that has recieved at least one dose of Covid Vaccination 
select cd.continent, cd."location", cd."date", cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) over (partition by cd."location" order by cv."location", cv."date")
as Rollingnumber_peoplevaccinated
from public.covid_deaths cd 
JOIN public.covid_vaccinations cv 
   on cd."location" =cv."location" 
   and cd."date" = cv."date" 
where cd.continent is not null
and cv.new_vaccinations is not null 
order by 2,3

-- USING CTE TO PERFORM CALCULATION ON "PARTITION BY" IN PREVIOUS QUERY
with PopuvsVacc (continent, location, date, population, new_vaccinations, Rollingnumber_peoplevaccinated)
as
(   
Select cd.continent, cd."location", cd."date", cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) over (partition by cd."location" order by cv."location", cv."date")
as Rollingnumber_peoplevaccinated
from public.covid_deaths cd 
JOIN public.covid_vaccinations cv 
   on cd."location" =cv."location" 
   and cd."date" = cv."date" 
where cd.continent is not null
and cv.new_vaccinations is not null
)
select *, (Rollingnumber_peoplevaccinated/population)*100 as Percentage_rollingnovaccinated_overpopulation
from PopuvsVacc


-- USING TEMPORARY TABLE TO PERFORM CALCULATION ON "PARTITION BY" IN PREVIOUS QUERY
--creating the Temp table
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent varchar, --varchar not set to any limit because it brings up an integer out of range error
Location varchar,
Date date,
Population real,
New_vaccinations real,
Rollingnumber_peoplevaccinated real
)
-- inserting previous query into Temp table
Insert into PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as Rollingnumber_peoplevaccinated
--, (Rollingnumber_peoplevaccinatedd/population)*100
From public.covid_deaths cd
Join public.covid_vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where (cd.continent, cv.new_vaccinations) is not null 
order by 2,3
--selecting the new table
Select *, (Rollingnumber_peoplevaccinated/Population)*100
From PercentPopulationVaccinated
where new_vaccinations is not null 
and continent is not null  


-- CREATING VIEW FOR STORING DATA FOR VISUALIZATIONS LATER USING TABLEAU/POWER BI

--1/7
Create View Percent_Population_Vaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as Rollingnumber_peoplevaccinated
--, (Rollingnumber_peoplevaccinatedd/population)*100
From public.covid_deaths cd
Join public.covid_vaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where (cd.continent, cv.new_vaccinations) is not null

--2/7
create view global_numbers as
select SUM(new_cases) as SUM_TOTALNEWCASES, SUM(new_deaths)  as SUM_TOTALNEWDEATHS, 
SUM(new_deaths)/SUM(new_cases)*100 as Totaldeath_percentage
from PUBLIC.covid_deaths cd
--where location like '%Nigeria%'
where (new_cases, new_deaths) is not null
and continent is not null
--group by "date" 
order by 1,2

--3/7
create view COUNTRIES_WITH_HIGHEST_DEATH_COUNT_PER_POPULATION as 
select location, MAX(total_deaths) as TotalDeathCounts
from PUBLIC.covid_deaths
where (total_deaths,continent) is not null
--and continent like '%Africa%' and location like '%Nigeria%'
group by location
order by TotalDeathCounts desc 
