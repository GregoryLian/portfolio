select * from PortfolioProject..CovidVaccinations
order by 3,4


-- Looking at Total cases vs Total deaths
-- Show likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from PortfolioProject..CovidDeaths
where location like 'Singapore'
order by 1,2


-- looking at total cases vs population

select Location, date, total_cases, population, (total_cases/population)*100 as 'Infection Percentage'
from PortfolioProject..CovidDeaths
where location like 'Singapore'
order by 1,2


-- looking at countries with highest infection rate compared to population

select Location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by InfectionPercentage desc


-- looking at countries with highest death rate compared to population

select Location, max(cast(total_deaths as int)) as TotalDeathCount -- cast was done upon realising that the total_deaths columns data type is nvarchar, which may not accurately show the number for the values required
from PortfolioProject..CovidDeaths
where continent is not null -- this was added in upon realizing there were entries that had continents in the location column but blank in the continent column, hence removing all these entries that would have provided the numbers in the continents
group by Location
order by TotalDeathCount desc


-- Look at it by continents, does not look accurate as North America numbers does not include Canada, seems like it is only the USA numbers

select continent, max(cast(total_deaths as int)) as TotalDeathCount -- cast was done upon realising that the total_deaths columns data type is nvarchar, which may not accurately show the number for the values required
from PortfolioProject..CovidDeaths
where continent is not null -- this was added in upon realizing there were entries that had continents in the location column but blank in the continent column, hence removing all these entries that would have provided the numbers in the continents
group by continent
order by TotalDeathCount desc


-- The most accurate representation of the continent numbers

select location, max(cast(total_deaths as int)) as TotalDeathCount -- cast was done upon realising that the total_deaths columns data type is nvarchar, which may not accurately show the number for the values required
from PortfolioProject..CovidDeaths
where continent is null 
group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount -- cast was done upon realising that the total_deaths columns data type is nvarchar, which may not accurately show the number for the values required
from PortfolioProject..CovidDeaths
where continent is not null -- this was added in upon realizing there were entries that had continents in the location column but blank in the continent column, hence removing all these entries that would have provided the numbers in the continents
group by continent
order by TotalDeathCount desc



-- Global numbers

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null -- this was added in upon realizing there were entries that had continents in the location column but blank in the continent column, hence removing all these entries that would have provided the numbers in the continents
group by date
order by 1


-- Joining both tables together 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- rolling count for vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- to calculate the (RollingCountVaccination/Population)*100 to get the VaccinationPercentage using CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingCountVaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingCountVaccination/population)*100 as VaccinationPercentage
from PopVsVac


-- to calculate the (RollingCountVaccination/Population)*100 to get the VaccinationPercentage using temp table

Drop table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingCountVaccination numeric
)


Insert into PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingCountVaccination/population)*100 as VaccinationPercentage
from PercentPopulationVaccinated


-- Creating a view  to store data for later visualizations

Create view PercentPopulationVaccinatedView as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinatedView