

select *
from CovidDeaths
where continent is not null
order by 3, 4 ------- First I started by selecting all the data from the Covid Deaths excel table to get a visual of all the data.


--select *
--from CovidVaccinations
--order by 3,4 

-- select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at total Cases vs Total Deaths
-- Shows likelihood of dying if you tracked Covid in your country 
Select Location, Date, total_cases, total_deaths, (total_deaths/(total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'Canada'
order by 1,2 --------- MY first query to explore the dataset was to see the total number of cases per country vs the total deaths of each country and to find what the percentage of each country was vs total cases and total deaths. I labelled this new column as DeathPercentage.

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location, date, total_cases, Population, (total_cases/ population)*100 as DeathPercentage
from CovidDeaths
where location like 'Canada'
Order by 1,2 ----- My next Query was looking at the total population of Canada specifically and the total cases for Canada to see the percentage of the population that was infected by Covid.  


-- Looking at Countries with highest infection rate compared to population

select Location, max(total_cases) as HighestInfectionCount, Population, max((total_cases/ population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like 'Canada'
Group by Population, Location 
Order by PercentPopulationInfected desc -- Cyprus, United states, Bahamas have the highest percent population infected. This Query generated the results showing which countries had the highest infection rates by dividing the total cases by the population. 


-- Showing Countries with highest death count per population

select Location, Max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'Canada'
where Continent is not null
Group by Location 
Order by TotalDeathCount desc -- My next query was to explore the data surrounding the highest death counts from Covid infections. using total deaths and the max function i was able to find the countries with the highest death counts. USA has the highest death count than all countries, second is brazil, Canada is 25th. 


-- Lets Break down by Continent

select continent, Max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'Canada'
where continent is not null
Group by continent 
order by TotalDeathCount desc -- North America has the highest total death count. This query is the same as the one above but instead of countries i was looking at contients. 


-- Looking at Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3 -- Now that i have explored the Covid Deaths table i moved on to the vaccinations data. I wanted to query the results to see the populations of the countries vs the vaccinations for each country. the data showed vaccinations started in 2021 for most countrties and grew significantly as the days went on as we saw first hand with more and more vaccinations becoming available. Canada started vaccinations on dec 15 2020


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3
)
select *, (RollingPeopleVaccinated/Population)
from PopvsVac------- I created a CTE called PopvsVac and use the same query input as above but demostrating my ability to perform a CTE. 

-- Temp Table 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3 ------------- I also created a Temp Table to demonstrate my ability to create not only a CTE but a temp table. 

select *, (RollingPeopleVaccinated/Population)
from #PercentPopulationVaccinated

-- Creating View to store Data later for Visulizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select * 
from PercentPopulationVaccinated -- now that we have created a view we can reference this as a sepatrte permanenent table to query off or use this for visualizatons.