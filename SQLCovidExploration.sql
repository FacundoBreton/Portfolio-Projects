Select *
from PortfolioProject..CovidDeaths

Select *
from PortfolioProject..CovidVaccinations


-- Covid 19 Data Exploration 
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases) * 100), 2) as 'Death%'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'arg%' --You can insert whatever country you want
ORDER BY 1,2 

--Total Cases vs Population
-- Shows what percentage of population was infected with Covid

SELECT location, date, total_cases, population, ROUND(((total_cases/population) * 100), 4) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%arg%' --You can insert whatever country you want
ORDER BY 1,2 

-- Countries with Highest Infection Rate compared to Population

SELECT 
	location, 
	CONVERT( VARCHAR(100), CAST(population as money), 1) as Population, 
	CONVERT( VARCHAR(100), CAST(MAX(total_cases) as money),1) as HighestInfectionCount, 
	ROUND(MAX((total_cases/population) * 100),2) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%arg%' --You can insert whatever country you want
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
	AND continent != ''
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Deleting unnecessary rows

DELETE FROM PortfolioProject..CovidDeaths WHERE location LIKE '%income'

DELETE FROM PortfolioProject..CovidDeaths WHERE location LIKE 'world'


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
	AND continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAR NUMBERS

SELECT 
	CONVERT(VARCHAR(100), CAST(SUM(new_cases) as money),1) AS Total_Cases, 
	CONVERT(VARCHAR(100), CAST(SUM(CAST(new_deaths as int)) as money),1) AS Total_Deaths, 
	ROUND((((SUM(CAST(new_deaths as int)))/SUM(new_cases)) * 100), 2) as 'Death%'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
	AND continent != ''
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(float,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS SummingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL 
	AND CD.continent != ''
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopulationvsVaccination (Continent, location, date, population,new_vaccinations ,SummingPeopleVaccinated)
AS(
	SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CONVERT(float,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS SummingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS CD
	JOIN PortfolioProject..CovidVaccinations AS CV
		ON CD.location = CV.location
		AND CD.date = CV.date
	WHERE CD.continent IS NOT NULL 
		AND CD.continent != ''
)
SELECT *, (SummingPeopleVaccinated / population) * 100
FROM PopulationvsVaccination


-- Using TEMP TABLE to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations float,
	SummingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

	SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
	SUM(CONVERT(float,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.location, CD.Date) AS SummingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths CD
	JOIN PortfolioProject..CovidVaccinations CV
		ON CD.location = CV.location
		AND CD.date = CV.date
--	WHERE CD.continent IS NOT NULL 
--		AND CD.continent != ''

SELECT *, (SummingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS

	SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
		SUM(CONVERT(float,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS SummingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths CD
	JOIN PortfolioProject..CovidVaccinations CV
		ON CD.location = CV.location
		AND CD.date = CV.date
	WHERE CD.continent IS NOT NULL
		AND CD.continent != ''

