/*
COVID19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 3,4

--Select data that we are going to be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths in my country (United States)
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Population
--Shows what percentage of population infected with covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breakdown by Continent
--Showing continents with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NULL AND NOT location LIKE '%income'
GROUP BY location
ORDER BY TotalDeathCount DESC

----Showing highest death count per income
SELECT iso_code, location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NULL AND location LIKE '%income'
GROUP BY location, iso_code
ORDER BY TotalDeathCount DESC

--Global Numbers per Day
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL 
GROUP BY date
ORDER BY 1

--Global death percentage as of 5/15/22
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL

--Total Population vs Vaccinations
--Shows % of Population that has recieved at least one COVID Vaccine
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed, SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.total_cases IS NOT NULL
ORDER BY 2,3

--Use CTE to perform calculation on PARTITION BY in previous query
WITH PopvsVac (continent, location, date, population, new_people_vaccinated_smoothed, RollingPeopleVaccinated)
AS 
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed, SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.total_cases IS NOT NULL AND dea.location NOT LIKE '%income'
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PopvsVac

--TEMP TABLE to perform calculation on PARTITION BY in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_people_vaccinated_smoothed numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed, SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.total_cases IS NOT NULL

SELECT *,
	location, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


SELECT
	*, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


--CREATE VIEW to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed, SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.total_cases IS NOT NULL