SELECT *
FROM Project_Portfolio_1..CovidDeaths
order by 3,4

--SELECT *
--FROM Project_Portfolio_1..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from Project_Portfolio_1..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows Likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from Project_Portfolio_1..CovidDeaths
Where location like '%states%'
order by 1,2 

--Looking at Total cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as Population_Percentage 
from Project_Portfolio_1..CovidDeaths
Where location like '%states%'
order by 1,2 


--Looking at countries with highest infection rate compared to population

Select Location, max(total_cases) as highest_infection_count,Max((total_cases/population))*100 as Percent_Population_infected 
from Project_Portfolio_1..CovidDeaths
--Where location like '%states%'
Group by location, population
order by Percent_Population_infected desc

--Showing countries with highest death count or per population 

Select Location, max(cast(total_deaths as int)) as total_death_count
from Project_Portfolio_1..CovidDeaths
--Where location like '%states%'
where continent is not null
--where clause to make sure that the continent are not being shown in the location as the null values contained the location as the continents and not countries.
Group by location
order by total_death_count desc


-- Let's BREAK THINGS  DOWN BY CONTINENT
-- Showing continents with the highest death count per population 

Select continent, max(cast(total_deaths as int)) as total_death_count
from Project_Portfolio_1..CovidDeaths
--Where location like '%states%'
where continent is not null
--where clause to make sure that the continent are not being shown in the location as the null values contained the location as the continents and not countries.
Group by continent
order by total_death_count desc


--GLOBAL NUMBERS 


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Project_Portfolio_1..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Looking at total population as vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from Project_Portfolio_1..CovidDeaths dea
join Project_Portfolio_1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

with pop_vs_vac (continent, location, date, population, new_vaccinations,rolling_people_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from Project_Portfolio_1..CovidDeaths dea
join Project_Portfolio_1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, (rolling_people_vaccinated/population)*100
from pop_vs_vac


-- Temp Table 

drop table if exists #percent_population_vaccinated
Create Table #Percent_population_vaccinated 
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric 
)


insert into #Percent_population_vaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from Project_Portfolio_1..CovidDeaths dea
join Project_Portfolio_1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
select* ,  (rolling_people_vaccinated/population)*100
from #Percent_population_vaccinated 
 


create view Percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from Project_Portfolio_1..CovidDeaths dea
join Project_Portfolio_1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * 
from Percent_population_vaccinated

