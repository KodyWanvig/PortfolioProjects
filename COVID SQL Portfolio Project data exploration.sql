

select *
from CovidDeaths
where continent is not null
order by 3, 4


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
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location, date, total_cases, Population, (total_cases/ population)*100 as DeathPercentage
from CovidDeaths
where location like 'Canada'
Order by 1,2

-- Looking at Countries with highest infection rate compared to population

select Location, max(total_cases) as HighestInfectionCount, Population, max((total_cases/ population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like 'Canada'
Group by Population, Location 
Order by PercentPopulationInfected desc -- Cyprus, UNited states, Bahamas have the highest percent population infected.

-- Showing Countries with highest death count per population

select Location, Max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'Canada'
where Continent is not null
Group by Location 
Order by TotalDeathCount desc -- USA has the highest death count than all countries, second is brazil, Canada is 25th. 

-- Lets Break down by Continent

select continent, Max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'Canada'
where continent is not null
Group by continent 
order by TotalDeathCount desc -- North America has the highest total death count. 

-- Looking at Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3 -- Canada started vaccinations on dec 15 2020

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
from PopvsVac

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
-- Order by 2,3

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