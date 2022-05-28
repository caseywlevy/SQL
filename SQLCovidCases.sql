-- View datasets



SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4



-- COVID DEATHS DATASET
-- Select Data that we are going to be using



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2




-- Looking at Total Cases vs Total Deaths in the United States


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2




-- Looking at Total Cases vs Population in the United States


SELECT location, date,population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2




-- Looking at countries with highest infection rate compared to population


SELECT Location, Population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC




-- Showing countries with highest death count


SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC




-- Showing continents with highest death count



SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Global new cases and deaths running total



SELECT date, SUM(new_cases) AS NewCasesRunningTotal, SUM(cast(new_deaths AS INT)) AS NewDeathsRunningTotal, SUM(cast(New_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



-- Current world death percentage



SELECT SUM(new_cases) AS NewCasesTotal, SUM(cast(new_deaths AS INT)) AS NewDeathsTotal, SUM(cast(New_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- JOINING COVID VACCINATIONS DATASET
-- Looking at Total population vs vaccinations



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- Using CTE to look at population vaccinated

WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 FROM PopVsVac


-- Using Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *, (RollingPeopleVaccinated/Population)*100 FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated
