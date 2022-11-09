SELECT * 
FROM CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at the Total Cases vs. Total Deaths

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as MortalityRate
FROM CovidDeaths
WHERE Location like '%States%'
ORDER BY 1,2


-- Looking at the total cases versus the population
-- Show what percent of population contracted covid

SELECT Location, date, total_cases, Population, (Total_cases/population)*100 as InfectionRate
FROM CovidDeaths
--WHERE Location like '%States%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as HighestInfectionRate
FROM CovidDeaths
--WHERE Location like '%States%'
GROUP BY Location, Population
ORDER BY HighestInfectionRate desc


-- Showing Countries with highest Death count per population (DeathRate)

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location like '%States%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location like '%States%'
Where continent is null
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Showing continents with highest death count per population 

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location like '%States%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as MortalityRate
FROM CovidDeaths
WHERE continent is not null
--Group by date
ORDER BY 1,2

-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--MAX(RollingPeopleVaccinated)/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
ORDER BY 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--MAX(RollingPeopleVaccinated)/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locaiton nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--MAX(RollingPeopleVaccinated)/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--MAX(RollingPeopleVaccinated)/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--ORDER BY 2,3

SELECT* 
From PercentPopulationVaccinated