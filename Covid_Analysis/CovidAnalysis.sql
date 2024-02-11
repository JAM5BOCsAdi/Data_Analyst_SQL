USE CovidAnalysis
GO

-- ********************* THIS PART IS FOR ANOTHER VIDEO ********************* 
-- Data Analyst Portfolio Project | Tableau Visualization | Project 2/4

/*
	Queries used for Tableau Project
*/

-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidAnalysis..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
--Group By date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From CovidAnalysis..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidAnalysis..CovidDeaths
--Where location like '%states%'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidAnalysis..CovidDeaths
--Where location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidAnalysis..CovidDeaths
--Where location like '%states%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC


-- ********************* THIS PART IS FOR ANOTHER VIDEO END ********************* 


-- ********************* ORIGINAL VIDEO STARTS FROM HERE ********************* 
SELECT *
FROM CovidAnalysis..CovidDeaths
ORDER BY location, date;

SELECT *
FROM CovidAnalysis..CovidVaccinations
ORDER BY location, date;

-- SELECT Data that we are going to be using:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Looking at Total Cases VS Total Deaths ( %States% )
-- Shows likelihood of dying if you contract covid in you country
SELECT	location, date, total_cases, total_deaths, 
		(total_deaths / total_cases)*100 AS death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date;

-- ********************* Possible Problem ********************* 
-- Comment:
-- To the ones stuck on 19:10 , use the following code to convert into float datatype when "Null" 

-- Looking at Total Cases VS Total Deaths ( %States% )
-- Shows likelihood of dying if you contract covid in you country
SELECT	location, date, total_cases, total_deaths, 
		(CONVERT(float, total_deaths) / NULLIF(CONVERt(float,total_cases), 0))*100 AS death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date;

-- Looking at Total Cases VS Population ( %Hungary% )
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, total_deaths, (total_cases / population)*100 AS total_cases_population_death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE location LIKE '%Hungary%' AND continent IS NOT NULL
ORDER BY location, date;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT	location, population, MAX(total_cases) AS highest_infection_count,
		MAX((total_cases / population))*100 AS percent_population_infected
FROM CovidAnalysis..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidAnalysis..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC;

-- Let's break things down by continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidAnalysis..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- ********************* Possible Problem ********************* 
-- Comment:
-- 38:23 The reason we are not getting correct total deaths when we break down by continents 
-- is that in our query we are using MAX(cast(total_deaths as int)), so what it does is it 
-- returns the maximum total_death from that particular continent(ex in Oceania continent it returned 910, 
-- which is the total death count for Australia and highest in its continent). 
-- We need to replace the query by:
SELECT continent, SUM(CONVERT(INT,new_deaths)) AS total_death_count_by_continent
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count_by_continent DESC;


-- Global numbers DAILY
SELECT	date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
		SUM(CAST(new_deaths AS INT)) / SUM(new_cases)*100 AS death_percentage
		-- total_cases, total_deaths, 
		-- (CONVERT(float, total_deaths) / NULLIF(CONVERt(float,total_cases), 0))*100 AS death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_cases;

-- Global numbers TOTAL
SELECT	SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
		SUM(CAST(new_deaths AS INT)) / SUM(new_cases)*100 AS death_percentage
		-- total_cases, total_deaths, 
		-- (CONVERT(float, total_deaths) / NULLIF(CONVERT(float,total_cases), 0))*100 AS death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY total_cases, total_deaths;



SELECT *
FROM CovidAnalysis..CovidVaccinations;

-- Looking at Total Population vs Vaccinations 
-- There is going to be an error with "rolling_people_vaccinated"
-- Error:  In SQL, you cannot reference an alias in the same SELECT clause where it's created.
-- You can use a subquery or a common table expression (CTE) to achieve your goal.
SELECT	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
		(rolling_people_vaccinated / population) * 100 -- Direct error
FROM CovidAnalysis..CovidDeaths dea 
JOIN CovidAnalysis..CovidVaccinations vac
	ON	dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


SELECT	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location) AS summed_new_vaccinations_in_each_partition
FROM CovidAnalysis..CovidDeaths dea 
JOIN CovidAnalysis..CovidVaccinations vac
	ON	dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Use CTE
WITH Pop_vs_Vac(continet, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT	
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--	(rolling_people_vaccinated / population) * 100
FROM CovidAnalysis..CovidDeaths dea 
JOIN CovidAnalysis..CovidVaccinations vac
	ON	dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated / population) * 100 AS rolling_people_vaccinated_per_population
FROM Pop_vs_Vac;


-- Temp Table
DROP TABLE IF EXISTS #temp_Percent_Population_Vaccinated;
CREATE TABLE #temp_Percent_Population_Vaccinated (
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_Vaccinations NUMERIC,
	rolling_people_vaccinated NUMERIC

);


INSERT INTO #temp_Percent_Population_Vaccinated
SELECT	
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--	(rolling_people_vaccinated / population) * 100
FROM CovidAnalysis..CovidDeaths dea 
JOIN CovidAnalysis..CovidVaccinations vac
	ON	dea.location = vac.location
		AND dea.date = vac.date;
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated / population) * 100
FROM #temp_Percent_Population_Vaccinated;


-- Creating View to Store Data for later visualization

-- You need to put GO; before and after CREATE VIEW, because there is going to be an error:
-- Incorrect syntax: 'CREATE VIEW' must be the only statement in the batch.

-- If VIEW is not generated in the "Views" ont the left panel (Object Explorer), 
-- you need to do this:
-- 1. Do USE at the beginning of everything to make sure, you use that DB
--		USE CovidAnalysis
-- 		GO

-- 2. Change available DB to your DB ( CovidAnalysis ) on the top of the left from "master" or something
-- 3. REFRESH

-- Comment that helped: https://stackoverflow.com/questions/71608321/view-created-in-sql-server-management-studio-but-not-visible-in-views-section
-- On the top left corner above the object explorer there is a dropdown option of available 
-- databases, click the dropdown menu and choose your project in your case should be covid 
-- and then run the create view query, it will run. Because your available database is set 
-- to master or some other that is why views does not show in your project views.
DROP VIEW IF EXISTS vPercentPopulationVaccinated; -- Starts with "v" as View
GO;
CREATE VIEW vPercentPopulationVaccinated AS
SELECT	
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--	(rolling_people_vaccinated / population) * 100
FROM CovidAnalysis..CovidDeaths dea 
JOIN CovidAnalysis..CovidVaccinations vac
	ON	dea.location = vac.location
		AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL;
 -- ORDER BY 2, 3;
GO;

 --EXEC sp_refreshview 'PercentPopulationVaccinated';


 SELECT *
 FROM vPercentPopulationVaccinated;

-- ********************* Possible Problem ********************* 
-- Comment:
-- For the query at 58:56, I was getting an error: 
-- "Arithmetic overflow error converting expression to data type int. 
-- Warning: Null value is eliminated by an aggregate or other SET operation."
-- For those of you getting the same thing, change the "int" into "bigint", 
-- apparently its due to the sum function.