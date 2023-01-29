select*
from Practice..Covid_Data
order by 3, 4

select*
from Practice..Covid_vaccination
order by 3, 4

-- Select Data To be Used
Select Location, date, total_cases, new_cases, total_deaths, population
from Practice..Covid_Data
order by 1,2

-- Cases vs Total Deaths in Nigeria
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Practice..Covid_Data
where location = 'Nigeria'
--where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- What Percentage of the Population got Covid?

Select Location, date, population, total_cases, round((total_cases/population)*100,5) as Percentage_Population_Infection
From Practice..Covid_Data
where location = 'Nigeria'
order by 1,2

-- Countries with the  Highest Infection Rate Compared to Population

Select Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percentage_populationInfected
From Practice..Covid_Data
group by Location, population
order by Percentage_populationInfected DESC

-- Countries with the Highest Death Count Per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from practice..covid_data
where continent is not null
group by location
order by TotalDeathCount desc

-- Continents with the Highest Death Count Per Population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from practice..covid_data
where continent is not null
group by continent
order by TotalDeathCount desc

--Daily new cases and death cases
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int)))/(sum(new_cases))*100 as percentageDaiilyDeath
from Practice..Covid_Data
where continent is not null
group by date
order by 1,2

--Total Population Vs Vaccination
select a.continent, a.location, b.total_vaccinations, b.population
from Practice..Covid_Data a
join Practice..Covid_vaccination b
on a.location = b.location
and a.date = b.date
where a.continent is not null
order by 2,3

select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(convert(bigint, b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as RollingVaccinated
from Practice..Covid_Data a
join Practice..Covid_vaccination b
on a.location = b.location
and a.date = b.date
where a.continent is not null
order by 2,3

-- Using CTS Approach
with populatioVac (continent, Location, date, population, new_vaccination, rollingvaccinated)
as
(
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as bigint)) over (partition by a.location order by a.location, a.date) as RollingVaccinated
from Practice..Covid_Data a
join Practice..Covid_vaccination b
on a.location = b.location
and a.date = b.date
where a.continent is not null
)
select*, (rollingvaccinated/population)*100 as PercentageVaccinated
from populatioVac


-- Using Temporary table
create table #populationvaccinated
(continent nvarchar(255),
location nvarchar(255),
--date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated bigint
)
insert into #populationvaccinated
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(convert(bigint, b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as RollingVaccinated
from Practice..Covid_Data a
join Practice..Covid_vaccination b
on a.location = b.location
and a.date = b.date
where a.continent is not null

select*, (rollingvaccinated/population) as PercentagePeopleVaccinated
from #populationvaccinated

-- Creating view 
create view RollingVaccinated as 
select a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(convert(bigint, b.new_vaccinations)) over (partition by a.location order by a.location, a.date) as RollingVaccinated
from Practice..Covid_Data a
join Practice..Covid_vaccination b
on a.location = b.location
and a.date = b.date
where a.continent is not null


select*
from RollingVaccinated