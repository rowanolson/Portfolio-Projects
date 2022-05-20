/*
Queries used for Tableau Project
*/

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2

--Total Death Count Per Continent
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NULL AND location NOT IN ('World', 'European Union', 'International') AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Percent Population Infected
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Percent Population Infected
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

