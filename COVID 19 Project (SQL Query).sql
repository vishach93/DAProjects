Select *
From PortfolioProject..CovidDeaths
where continent is NOT null
order by 3,4

--	Select *
--	From PortfolioProject..CovidVaccinations
--	order by 3,4

--Select Data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is NOT null
Select  total_cases
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at total cases vs total deaths
-- shows likelyhood of dying if you contract covid in your country
-- total deaths and 2% chance that you could die from covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%' and 
where continent is NOT null
Order by 1,2


--Looking at total cases vs populpation
-- what percentage of people got covid
Select location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%india%'
Order by 1,2


--Looking at countries with highest infection rate to population

Select location,  population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%india%'
Group by location,  population
Order by PercentPopulationInfected desc

--Countries with highest death count pr population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%' and
where continent is NOT null
Group by location
Order by TotalDeathCount desc

-- where location is null

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%' and
where continent is null
Group by location
Order by TotalDeathCount desc


--Break things down by continent
-- showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%' and
where continent is NOT null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers
-- sum of new_cases will aggeregrate to total cases
--across the world a death percentage of 0.009%
--759million vs 6 million

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases) as DeathPercentage

From PortfolioProject..CovidDeaths
--where location like '%india%' and 
where continent is NOT null
--GROUP BY date
Order by 1,2

-- Looking at total population vs vaccinations
-- We can either cast or convert the nvarchar into int
-- Rolling count how many new vaccinations are happing per country
-- Divide the Maximum Rolling count by the population to see how many people in the country are vaccinated


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location  order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
-- Percentage of people that have been vaccinated
-- One way with CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--where dea.location like '%india%'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select * (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



select * from PercentPopulationVaccinated