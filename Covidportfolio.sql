select*
from [dbo].[CovidDeaths$]
where continent is not null
order by 3,4

--Select*
--from [dbo].[CovidVaccinations$]
--order by 3,4

-- Select data that we are going to be using

select location, date, total_Cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths$]
order by 1,2

-- Looking at Total cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_Cases, total_deaths, (Total_deaths/total_cases*100) as DeathPercentage
from [dbo].[CovidDeaths$]
where location like '%Kingdom%'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid
select location, date, Population,total_Cases,  (Total_cases/population*100) as Percentageofpopulationinfected
from [dbo].[CovidDeaths$]
where location like '%Kingdom%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_Cases) as HighestInfectionCount, Max((Total_cases/population*100)) as Percentagepopulationinfected
from [dbo].[CovidDeaths$]
--where location like '%Kingdom%'
Group by location, population
order by Percentagepopulationinfected desc

-- Showing with the highest death count per population
select location, MAX(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[CovidDeaths$]
--where location like '%Kingdom%'
where continent is not null
Group by location
order by Totaldeathcount desc

-- Break things down by continent
select location, MAX(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[CovidDeaths$]
--where location like '%Kingdom%'
where continent is not null
Group by location
order by Totaldeathcount desc

-- Showing the continents with the highest death counts
select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[CovidDeaths$]
--where location like '%Kingdom%'
where continent is not null
Group by continent
order by Totaldeathcount desc

-- global numbers

select SUM(new_Cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as deathpercentage
from [dbo].[CovidDeaths$]
-- where location like '%Kingdom%'
where continent is not null
--group by date 
order by 1,2

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
,(Rollingpeoplevaccinated /population)*100
from [dbo].[CovidVaccinations$] vac
join [dbo].[CovidDeaths$] dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rollingpeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100
from [dbo].[CovidVaccinations$] vac
join [dbo].[CovidDeaths$] dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select*,(Rollingpeoplevaccinated/Population)*10
from PopvsVac


-- TEMP table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeoplevaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100
from [dbo].[CovidVaccinations$] vac
join [dbo].[CovidDeaths$] dea
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
-- order by 2,3

Select*,(Rollingpeoplevaccinated/Population)*10
from #PercentPopulationVaccinated


-- creating view to store data for later visulizations


Create view #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100
from [dbo].[CovidVaccinations$] vac
join [dbo].[CovidDeaths$] dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3