Select * 
from [Project 1]..CovidDeaths$
order by 3,4
Select * 
from [Project 1]..CovidVaccinations$
order by 3,4

-- Select data that will be used

Select location, date, total_cases, new_cases, total_deaths, population 
from  [Project 1]..CovidDeaths$
order by 1,2


-- Compare Total Cases VS Total Deaths
-- it shows the death percentage if you had Covid in the US 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from  [Project 1]..CovidDeaths$
where location like '%states%'
order by 1,2

-- Compare Total Cases VS population 
-- it shows the percentage of population tested positive of covid in the US 

Select location, date,population, total_cases,(total_cases/population)*100 as Positivetestedpercentage
from  [Project 1]..CovidDeaths$
where location like '%states%'
order by 1,2

-- countries with the highest infection rate compared to population

Select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as Positivetestedpercentage
from  [Project 1]..CovidDeaths$
group by location, population
order by Positivetestedpercentage desc

-- countries with the highest death count per population 
Select location, max(cast(total_deaths as int)) as totaldeathcount 
from [Project 1]..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc


--Continent level
-- highest death count by continent per population
Select continent, max(cast(total_deaths as int)) as totaldeathcount 
from [Project 1]..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc 


-- Global level

-- total cases and total deaths and death percentage globally

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage 
From [Project 1]..CovidDeaths$
where continent is not null 
order by 1,2

-- Total population vs vaccinations
--use CTE to show Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [Project 1]..CovidDeaths$ dea
join [Project 1]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 as vacpercentage
FROM PopvsVac

-- Create View to store data for visualization
Create View PopvsVac1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [Project 1]..CovidDeaths$ dea
join [Project 1]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
