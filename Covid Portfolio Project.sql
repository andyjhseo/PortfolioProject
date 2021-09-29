Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1,2

--Looking for total cases vs total deaths
Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1,2

--Looking for total cases vs population 
Select Location,date, total_cases, population, (total_cases/population) * 100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1,2

--Looking at countries with the highest infection percentage 
Select Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)) * 100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
Order by 4 DESC

--Looking at countries with the highest death count
Select Location, MAX(cast(total_deaths as int)) AS HighestDeathCount, population, MAX((total_deaths/population)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
Order by 2 DESC

--Looking at death count for continents
Select continent, max(cast(total_deaths as int)) AS HighestDeathCount
FROm PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by continent
Order by 2 DESC

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1,2

--Looking at total population vs vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--use cte
With PopvsVac (Continent, Location, Date, Population,New_vaccinations,peoplevaccinated)
as  
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.Location = 'Canada'
--ORDER BY 2,3
)
SELECT *, (peoplevaccinated/population) * 100 
FROM PopvsVac

--Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
peoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (peoplevaccinated/population) * 100 
FROM #PercentPopulationVaccinated


--creating view to store data for visualizations with Tableau
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

Create View ContinentDeath as
Select continent, max(cast(total_deaths as int)) AS HighestDeathCount
FROm PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by continent

Create View DeathPercentage as
Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

Create View InfectionPercentage as 
Select Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)) * 100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population

