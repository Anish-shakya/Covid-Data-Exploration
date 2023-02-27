/*
Covid  Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types
*/

---selecting data that i am  going to use------

SELECT *
FROM Covid_Deaths
ORDER BY location


--- Looking at Total Cases Vs TOtal Deaths
---Shows Likehood of dying if we contact covid in Nepal

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,3) AS DeathPercentage
FROM Covid_Deaths
WHERE location LIKE '%Nepal%' AND continent IS NOT NULL
order by 1,2


----Looking at Total Cases Vs Population
---Shows what percentage of population got covid in Nepal

SELECT location, date, population, total_cases,total_deaths, ROUND((total_cases/population)* 100,3) AS InfectedPopulationPercentage
FROM Covid_Deaths
WHERE location ='Nepal'AND continent IS NOT NULL
order by 1,2

--Looking at countires with HIghest Infection Rate compared to  Population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population))*100,3) AS InfectedPopulationPercentage
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY InfectedPopulationPercentage DESC


---Looking at Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeath
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeath DESC


---LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest deth count per populatio

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeath
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC


-----Global Numbers


--Looking at Total Case  And Total Deaths each day along with Death Percentage
	
SELECT date,SUM(new_cases) AS Total_Case, SUM(CAST(new_deaths AS INT)) AS Total_Deaths ,ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases),3)* 100 AS TotalDeathPercentage
FROM Covid_Deaths
WHERE continent IS NOT NULL 
Group BY date
ORDER BY 1,2

--Looking at Total Case  And Total Deaths  with Death Percentage
	
SELECT SUM(new_cases) AS Total_Case, SUM(CAST(new_deaths AS INT)) AS Total_Deaths ,ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases),3)* 100 AS TotalDeathPercentage
FROM Covid_Deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2




---Looking at Total Population Vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vacinations	vac
	ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 1,2


--USE CTE

WITH PopVsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeoplevacinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location   ORDER BY dea.location,dea.date)  AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vacinations	vac
	ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeoplevacinated/Population)*100 
FROM PopVsVac



---TEMP Table
DROP TABLE IF EXISTS #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationvaccinated(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated  numeric
)
INSERT INTO #PercentPopulationvaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location   ORDER BY dea.location,dea.date)  AS RollingPeopleVaccinated
	FROM Covid_Deaths dea
	JOIN Covid_Vacinations	vac
		ON dea.location = vac.location AND dea.date = vac.date 
	WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationvaccinated





--- Creating View to Store Data For Later Visualizations


CREATE VIEW PercentPopulationvaccinated  AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location   ORDER BY dea.location,dea.date)  AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vacinations	vac
	ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL


SELECT * FROM PercentPopulationvaccinated
