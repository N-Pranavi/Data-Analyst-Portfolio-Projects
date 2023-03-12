SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3,4;


--Data Exploration - Selecting data to use for further analysis

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

--Total cases Vs Total deaths
--Results: There's 1% of chance dying if you get in contact with covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2;

--Total cases Vs Population
--Results:

SELECT location, date, population, total_cases, (total_cases/population)*100 as percentage_population_affected
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2;

--Countries with the most covid cases
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percentage_population_affected
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location,population
ORDER BY percentage_population_affected desc;

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc;

--Continents with highest death count by population 
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc;

--Covid deaths globally

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as INT)) AS total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPrecentage
--   total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


--Joined Deaths and Vaccinations tables

--Total Population Vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_Vaccination_count
--(rolling_vaccination_count/population)*100
FROM ProjectPortfolio..CovidDeaths d
JOIN ProjectPortfolio..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null	
ORDER BY 2,3;

--Using CTE


WITH PopVSVac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_Vaccination_count
--(rolling_vaccination_count/population)*100
FROM ProjectPortfolio..CovidDeaths d
JOIN ProjectPortfolio..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null	
--ORDER BY 2,3
)

select *, (rolling_vaccination_count/population)*100
From PopVSVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(300),
	Location nvarchar(300),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.Continent, d.Location, d.Date, d.Population, v.new_vaccinations,
    SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.Location ORDER BY d.Location, d.Date) AS RollingPeopleVaccinated
FROM ProjectPortfolio.dbo.CovidDeaths d
JOIN ProjectPortfolio.dbo.CovidVaccinations v
	ON d.Location = v.Location 
	AND d.Date = v.Date;

--where dea.Continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating Views for later


Create View PercentPopulationVaccinate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio.dbo.CovidDeaths dea
Join ProjectPortfolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
