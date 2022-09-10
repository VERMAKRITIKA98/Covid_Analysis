Select * From [Covid Analysis]..covidDeath
where continent is Not Null
Order by 3, 4

--Select * From [Covid Analysis]..CovideVaccination
--Order by 3, 4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From [Covid Analysis]..covidDeath
Order by 1, 2

--Looking at Total Cases vs Total Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
From [Covid Analysis]..covidDeath
where location like '%state%' and continent is Not Null
Order by 1, 2


--Looking at total Cases vs population
--show the percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From [Covid Analysis]..covidDeath
where continent is Not Null
Order by 1, 2

--Looking at countries with highest infection rate compared to population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PopulationInfected
From [Covid Analysis]..covidDeath
Group by location, population
Order by PopulationInfected desc

--Showing countries with hiegest Death count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Analysis]..covidDeath
where continent is Not Null
Group by location
Order by TotalDeathCount desc


--Let's break things down by continent

--Showing continents with the heighest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Analysis]..covidDeath
where continent is Not Null
Group by continent
Order by TotalDeathCount desc


-- global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Covid Analysis]..covidDeath
--where location like '%state%' 
where continent is Not Null
--Group by date
Order by 1, 2


Select * from [Covid Analysis]..covidDeath dea
join [Covid Analysis]..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date


-- looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
--as RollingPeopleVaccinated
from [Covid Analysis]..covidDeath dea
join [Covid Analysis]..CovidVaccination vac
on dea.location = vac.location and dea.date= vac.date
where dea.continent is not null
order by 2, 3

-- use CTE

with popvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Covid Analysis]..covidDeath dea
join [Covid Analysis]..CovideVaccination vac
on dea.location = vac.location 
and dea.date= vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
From popvsVac

--Temp TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Covid Analysis]..covidDeath dea
join [Covid Analysis]..CovideVaccination vac
on dea.location = vac.location 
and dea.date= vac.date
where dea.continent is not null
--order by 2, 3


select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- create view to store data for VISUALIZATION
create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from [Covid Analysis]..covidDeath dea
join [Covid Analysis]..CovideVaccination vac
on dea.location = vac.location 
and dea.date= vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated