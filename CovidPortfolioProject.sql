Select *
From PortfolioProject..CovidDeaths
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as bigint) * 100) as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%nam%'
Order by 1, 2

-- Looking at total cases vs population
-- Shows what percantage of population got Covid

Select location, date, total_cases, population, (cast(total_cases as bigint)/population * 100) as infection_percentage
From PortfolioProject..CovidDeaths
-- Where location like 'vietnam'
Order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(cast(total_cases as bigint)) as highest_infection_country, MAX(cast(total_cases as bigint)/population * 100) as percent_population_infected 
From PortfolioProject..CovidDeaths
Group by location, population
Order by percent_population_infected desc


--Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as bigint)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by total_death_count desc

--Breaking things down by continent

Select continent, MAX(cast(total_deaths as bigint)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by total_death_count desc

-- Global number

Select date, SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by date

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, total_vaccinations, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as total_vaccinations_by_location
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order by 2, 3

-- Use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, total_vaccinations_by_location)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select * , total_vaccinations_by_location/population  *100 as percent_population_vaccinated
From PopvsVac
Order by location, date

-- temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
rolling_people_vaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null

Select * , rolling_people_vaccinated/population *100 as percent_rolling_people_vaccinated
From #PercentPopulationVaccinated
--Order by location, date

--create view
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by location, date 

Select * from PercentPopulationVaccinated

