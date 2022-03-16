SELECT *
FROM SQLDataExploration..COVIDDeaths
order by 3, 4

SELECT *
FROM SQLDataExploration..COVIDVaccinations

--Percentage of total cases by population globally

SELECT date, location, total_cases, population, (total_cases/population)*100 as PercOfTotalCases
FROM SQLDataExploration..COVIDDeaths

--Percentage of total cases by population in Pakistan

SELECT date, location, total_cases, population, (total_cases/population)*100 as TotalCasesByPopulation
FROM SQLDataExploration..COVIDDeaths
WHERE location LIKE 'Pakistan'

--Countries by highest infection percentage in Asia

SELECT location, MAX(total_cases) as HighestCaseCount, population, Max((total_cases/population))*100 as TotalInfectionPercentage
FROM SQLDataExploration..COVIDDeaths
WHERE continent LIKE 'Asia'
GROUP BY location, population
ORDER BY TotalInfectionPercentage desc

--Total death count by countries

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths 
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeaths desc

--Total death count by continents

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeaths 
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeaths desc

--Another way to count deaths by continents; because it's the continent itself in the location column where continent column is null, along with other categories

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths 
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeaths desc

--Total death count by income globally

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths 
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NULL and location LIKE '%income%'
GROUP BY location
ORDER BY TotalDeaths desc

--Percentage of total death count by continents per population

SELECT continent, MAX(CAST(total_deaths as int)) as HighestDeathCount, MAX(total_deaths/population)*100 as PercOfTotalDeaths 
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY PercOfTotalDeaths desc

--Total death count by countries in Asia

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths 
FROM SQLDataExploration..COVIDDeaths
WHERE continent LIKE 'Asia'
GROUP BY location
ORDER BY TotalDeaths desc

--Total death percentage by cases each day globally

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as TotalDeathsPercentage
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2 

--Total death percentage by cases globally

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as TotalDeathsPercentage
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2 

--Joining COVID Deaths and Covis Vaccinations table

SELECT *
FROM SQLDataExploration..COVIDDeaths deaths
JOIN SQLDataExploration..COVIDVaccinations vacc
ON deaths.date=vacc.date
AND deaths.location=vacc.location

--Total population vs new vaccinations globally, and calculating Total Vaccinations at every occurance 

SELECT deaths.continent, deaths.date, deaths.location, deaths.population, vacc.new_vaccinations, 
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinations
FROM SQLDataExploration..COVIDDeaths deaths
JOIN SQLDataExploration..COVIDVaccinations vacc
ON deaths.date=vacc.date
AND deaths.location=vacc.location
WHERE deaths.continent is NOT NULL
--Group BY vacc.location
ORDER BY 3, 2

--Total population vs new vaccinations in Pakistan

SELECT deaths.continent, deaths.date, deaths.location, deaths.population, vacc.new_vaccinations, 
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinations
FROM SQLDataExploration..COVIDDeaths deaths
JOIN SQLDataExploration..COVIDVaccinations vacc
ON deaths.date=vacc.date
AND deaths.location=vacc.location
WHERE deaths.location LIKE 'Pakistan' AND deaths.continent is NOT NULL
--Group BY vacc.location
ORDER BY 3, 2

--Using Common Table Expression (CTE) - Total Percentage of population vaccinated in Globally
--Creating a new table as PopVsVacc, adding a new columnn as TotalVaccinations and calcuting VaccinatedPopulationPercentage by population

WITH PopvsVacc (Continent, Date, Location, Population, New_vaccinations, TotalVaccinations)
as
(
SELECT deaths.continent, deaths.date, deaths.location, deaths.population, vacc.new_vaccinations, 
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinations
--,SUM(TotalVaccinations/population)*100 
FROM SQLDataExploration..COVIDDeaths deaths
JOIN SQLDataExploration..COVIDVaccinations vacc
ON deaths.date=vacc.date
AND deaths.location=vacc.location
WHERE deaths.continent is NOT NULL
--Group BY vacc.location
--ORDER BY 3, 2
)
SELECT*, (TotalVaccinations/population)*100 as VaccinatedPopulationPercentage
FROM PopvsVacc

--Creating a Temp Table and getting percentage of population vaccinated in Pakistan using the same above method

DROP TABLE if exists VaccinatedPercentage
CREATE TABLE VaccinatedPercentage (
Continent varchar(255), Date datetime, Location varchar(255), Population numeric, New_vaccinations numeric, VaccinatedPopulationPercentage numeric)

INSERT INTO VaccinatedPercentage
SELECT deaths.continent, deaths.date, deaths.location, deaths.population, vacc.new_vaccinations, 
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as VaccinatedPopulationPercentage
--,SUM(TotalVaccinations/population)*100 
FROM SQLDataExploration..COVIDDeaths deaths
JOIN SQLDataExploration..COVIDVaccinations vacc
ON deaths.date=vacc.date
AND deaths.location=vacc.location
WHERE deaths.location LIKE 'Pakistan' AND deaths.continent is NOT NULL
--Group BY vacc.location
--ORDER BY 3, 2

SELECT*, (VaccinatedPopulationPercentage/population)*100 as VaccinatedPopulationPercentage
FROM VaccinatedPercentage


-- Creating VIEWs

CREATE VIEW PercentageOfTotalCases as
SELECT date, location, total_cases, population, (total_cases/population)*100 as PercOfTotalCases
FROM SQLDataExploration..COVIDDeaths

SELECT * FROM PercentageOfTotalCases

--

CREATE VIEW HighestInfectionPercentage as
SELECT location, MAX(total_cases) as HighestCaseCount, population, Max((total_cases/population))*100 as TotalInfectionPercentage
FROM SQLDataExploration..COVIDDeaths
--WHERE continent LIKE 'Asia'
GROUP BY location, population
--ORDER BY TotalInfectionPercentage desc

SELECT * FROM HighestInfectionPercentage

--

CREATE VIEW TotalDeathsGlobal as
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths 
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NOT NULL
GROUP BY location
--ORDER BY TotalDeaths desc

SELECT * FROM TotalDeathsGlobal

--

CREATE VIEW DeathPercDaily as
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as TotalDeathsPercentage
FROM SQLDataExploration..COVIDDeaths
WHERE continent is NOT NULL
GROUP BY date
--ORDER BY 1,2 

--

CREATE VIEW PopulationVsVaccinated as
SELECT deaths.continent, deaths.date, deaths.location, deaths.population, vacc.new_vaccinations, 
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinations
FROM SQLDataExploration..COVIDDeaths deaths
JOIN SQLDataExploration..COVIDVaccinations vacc
ON deaths.date=vacc.date
AND deaths.location=vacc.location
WHERE deaths.continent is NOT NULL
--Group BY vacc.location
--ORDER BY 3, 2

SELECT * FROM PopulationVsVaccinated

--
DROP VIEW if exists NewVaccinatedVsTotal
CREATE VIEW NewVaccinatedVsTotal as
WITH PopvsVacc (Continent, Date, Location, Population, New_vaccinations, TotalVaccinations)
as
(
SELECT deaths.continent, deaths.date, deaths.location, deaths.population, vacc.new_vaccinations, 
SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinations
--,SUM(TotalVaccinations/population)*100 
FROM SQLDataExploration..COVIDDeaths deaths
JOIN SQLDataExploration..COVIDVaccinations vacc
ON deaths.date=vacc.date
AND deaths.location=vacc.location
WHERE deaths.continent is NOT NULL
--Group BY vacc.location
--ORDER BY 3, 2
)
SELECT*, (TotalVaccinations/population)*100 as VaccinatedPopulationPercentage
FROM PopvsVacc

SELECT * FROM NewVaccinatedVsTotal
