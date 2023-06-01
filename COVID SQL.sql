SELECT *
FROM `portifolio-project-05042023.covid_dataset.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows likelehood of diying if you contract Covid in Brazil

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_pct
FROM `portifolio-project-05042023.covid_dataset.covid_deaths`
WHERE location = 'Brazil' 
AND continent IS NOT NULL
ORDER BY 1,2 DESC


-- looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases / population)*100 AS cases_pct
FROM `portifolio-project-05042023.covid_dataset.covid_deaths`
WHERE location = 'Brazil'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to its Population

SELECT location, population, MAX(total_cases) AS highest_infection_cases, ROUND(MAX((total_cases / population))*100, 2) AS pop_infected_pct
FROM `portifolio-project-05042023.covid_dataset.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY pop_infected_pct DESC

-- Showing countries with Highes Death Count per Population

SELECT location, MAX(total_deaths) AS total_deaths_count 
FROM `portifolio-project-05042023.covid_dataset.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths_count DESC

-- Breaking down by continents
-- Showing the continents with Highest Death Count per Population

SELECT continent, MAX(total_deaths) AS total_deaths_count 
FROM `portifolio-project-05042023.covid_dataset.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths_count DESC


-- GLOBAL NUMBERS

SELECT 
  date, 
  SUM(new_cases) AS total_cases_day, 
  SUM(new_deaths) AS total_deaths_day, 
  ROUND(SUM(new_deaths) / NULLIF(SUM(new_cases), 0)*100, 2) AS death_pct_day
FROM `portifolio-project-05042023.covid_dataset.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking ant Total Population vs Vaccinations

SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location 
    ORDER BY dea.location, dea.date
    ) AS rolling_ppl_vac,
  (rolling_ppl_vac / population)
FROM `portifolio-project-05042023.covid_dataset.covid_deaths` AS dea
JOIN `portifolio-project-05042023.covid_dataset.covid_vaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PplvsVac 
AS 
(
  SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location 
    ORDER BY dea.location, dea.date
    ) AS rolling_ppl_fully_vac
  FROM `portifolio-project-05042023.covid_dataset.covid_deaths` AS dea
  JOIN `portifolio-project-05042023.covid_dataset.covid_vaccinations` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, ROUND((rolling_ppl_fully_vac / population)*100, 2) AS rolling_ppl_fully_vac_pctg
FROM PplvsVac
ORDER BY 2,3


-- Creating view to store date for later visualizations

CREATE VIEW `portifolio-project-05042023.covid_dataset.ppl_vaccinated_pctg` AS
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location 
    ORDER BY dea.location, dea.date
    ) AS rolling_ppl_fully_vac
  FROM `portifolio-project-05042023.covid_dataset.covid_deaths` AS dea
  JOIN `portifolio-project-05042023.covid_dataset.covid_vaccinations` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL

  