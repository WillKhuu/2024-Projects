/*
Covid 19 Exploratory Data Analysis

Skills Used: Joins, CTE's, Joins, Converting Data Types

*/

Select * FROM [Covid].[dbo].[CovidVaccinations]
where continent is not null
and location like '%states%'
order by 3, 4

-- Select Data that we are going to be starting with
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 3, 4




-- Total Cases vs Total Deaths
-- Shows likelihood if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, population, (total_deaths / total_cases) * 100 as DeathPercentage
from CovidDeaths
where location = 'Canada'
order by 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
-- QUERY 2
select location, date, total_cases, new_cases, total_deaths, population, (total_cases / population) * 100 as InfectedPercentage
FROM [Covid].[dbo].[CovidDeaths]
where location = 'Canada'
order by 1, 2

-- Countries with Highest Infection Rate compared to Population
-- QUERY 3
select location, population, max(total_cases) as HighestInfectedCountry, max((total_cases / population)) * 100 as InfectedPercentage
from CovidDeaths
where total_cases is not null
group by location, population
order by InfectedPercentage desc

-- Countries with Highest Death Count per Population
select location, max(Cast(total_deaths as int)) as DeathCount, max((total_deaths / population)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by location
order by DeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
select location, max(Cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is null
group by location
order by DeathCount desc


-- GLOBAL NUMBERS
select date, sum(new_cases)as total_deaths, sum(cast(new_deaths as int)) as total_cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2 


--QUERY 1
select sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select * from CovidVaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(Cast(cd.new_vaccinations as int)) OVer (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location and
cd.date = cv.date
where cd.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(Cast(cd.new_vaccinations as int)) OVer (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location and
cd.date = cv.date
where cd.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) * 100 as Percentage 
from PopvsVac

-- Creating View to store data for later visualizations
Create View PercentPeopleVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(Cast(cd.new_vaccinations as int)) OVer (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location and
cd.date = cv.date
where cd.continent is not null


-- QUERIES USED FOR VISUALIZATIONS
select cd.location, sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage,
sum(cast(cv.new_vaccinations as int)) as total_vaccinations
from [Covid].[dbo].[CovidDeaths] cd
join [Covid].[dbo].[CovidVaccinations] cv
on cd.location = cv.location and
cd.date = cv.date
where cd.continent is not null
group by cd.location
order by 1, 2 

select location, population, date, max(total_cases) as HighestInfectedCountry, max((total_cases / population)) * 100 as InfectedPercentage,
max(Cast(total_deaths as int)) as DeathCount, max((total_deaths / population)) * 100 as DeathPercentage
from [Covid].[dbo].[CovidDeaths]
where location not in ('World', 'Europe', 'Asia', 'European Union', 'North America', 'South America', 'Africa')
group by location, date, population
order by date 

select cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(Cast(cd.new_vaccinations as int)) OVer (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from [Covid].[dbo].[CovidDeaths] cd
join [Covid].[dbo].[CovidVaccinations] cv
on cd.location = cv.location and
cd.date = cv.date
where cd.continent is not null
order by 1



