select * 
from PortfolioProject..CovidDeaths$ 
where continent is not null
order by  3,4 ;

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4;


select location, date, total_cases ,  new_cases, total_deaths,population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2;




-- looking at total_cases vs total_deaths
--shows likelihood of dying if you contract covid in your country
select location, date, CAST(total_cases AS float) AS total_cases, 
    CAST(total_deaths AS float) AS total_deaths,
    (CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0)) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where  continent is not null
order by 1,2;



--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT 
    location, 
    date, 
    CAST(total_cases AS float) AS total_cases, 
    population,
    (CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0)) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
WHERE  continent is not null
ORDER BY  
    1,2;



--Looking at Countries with Highest Infection Rate compared to population 

SELECT 
    location, 
    MAX(CAST(total_cases AS float)) AS highestInfectionCount, 
    population,
    MAX((CAST(total_cases AS float)) / NULLIF(CAST(population AS float), 0)) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY  PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per population

SELECT 
    location, 
    MAX(cast(Total_deaths AS int)) AS TotalDeathCount

FROM 
    PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc




-- LET'S  BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

SELECT 
    continent, 
    MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

 SELECT 
    date, 
    SUM(new_cases) AS total_new_cases,
    SUM(CAST(new_deaths AS int)) AS total_new_deaths,
    (SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1,2;



-- Looking at Total Population vs Vaccinations


SELECT 
    dea.continent, 
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths$ dea
JOIN 
    PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, 
    dea.date;




-- USE CTE
WITH PopvsVac(continent,location, Date,Population, New_Vaccination,RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent, 
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths$ dea
JOIN 
    PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
--ORDER BY 
    --dea.location, 
   -- dea.date
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths$ dea
JOIN 
    PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
--ORDER BY 
    --dea.location, 
   -- dea.date

   SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM #PercentPopulationVaccinated



--Creating view to store for later visualizations


CREATE VIEW  PercentPopulationVaccinated2 AS 
SELECT 
    dea.continent, 
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths$ dea
JOIN 
    PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
--ORDER BY 
  --dea.location, 
  --dea.date

  SELECT *
  FROM PercentPopulationVaccinated