SELECT *
FROM CovidDeaths$
where continent is not null
order by 3 ,4 


--select *
--from CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

--Looking at Total cases vs Total Deaths
-- shows the likehood of dying if you contract covod
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%state%'
order by 1,2

--loking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as PercentageOfPopulationInfected
from CovidDeaths$
--where location like '%state%'
order by 1,2

--looking at Countries with Highest infection Rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulationInfected
from CovidDeaths$
--where location like '%state%'
group by Location, Population
order by PercentageOfPopulationInfected desc

--LET'S BREAK THINGS BY CONTINENT

--showing countries with Highest Death Count Per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%state%'
where continent is null
group by location
order by TotalDeathCount desc

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%state%'
where continent is null
group by continent
order by TotalDeathCount desc

--Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--group by dea.population, dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2,3

--cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Ghana%'
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TempTable
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from  #PercentPopulationVaccinated 


--Creating view to store date for later visualization
create view PercentagePopulationVaccinated as
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
--order by 1,2