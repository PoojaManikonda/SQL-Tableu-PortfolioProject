Select *
From PortfolioProject..CovidDeaths


Select *
From PortfolioProject..CovidVaccinations
where continent is not null
order by 1,2

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases Vs Total Deaths (in %)
--Shows the likelihood of  dying  if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%India%'
order by 1,2

--Looking at Total cases Vs Population

Select Location, date, Population, total_cases, (total_deaths/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) AS HighestInfectionCount, MAX(total_cases/population) *100 as
InfectedPercentage
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by InfectedPercentage desc

--Showing countries with Highest Death count per Population

Select location, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount desc


--Looking at things by location to accurate count

Select location, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc

--Looking at things by continent

Select continent, Max(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage --total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
order by 1,2


---------------------------------Joining Tables: CovidDeaths, CovidVaccinations----------------------------------


Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date


--Looking at Total Population Vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location  Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


---USE CTE---for dividing population by max count of RollingPeopleVaccinated

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location  Order by dea.location, dea.date
Rows unbounded preceding) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,
cast(RollingPeopleVaccinated as Decimal(38,6))
/Nullif(cast(Population as Decimal (38, 6)), 0)*100.0
From PopvsVac

------------TEMP TABLE--------



Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location  Order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/nullif(Population,0))*100
From #PercentPopulationVaccinated

-------------views------------to store data for later visualization 

USE PortfolioProject

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(BIGINT, vac.new_vaccinations))
         OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
 AND dea.date     = vac.date
WHERE dea.continent IS NOT NULL;





