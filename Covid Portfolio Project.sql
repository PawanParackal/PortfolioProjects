--Observe Total Cases Vs Total Deaths
--Shows the likelihood of dying if you had come up with Covid in India

select location,date, total_cases, total_deaths,round((total_deaths/total_cases)*100,3) AS DeathPercentage
from PortfolioProject.dbo.CovidDeath
where location like '%india%'
order by 1,2;

--Seeing What percent of population got covid
select location,date, total_cases, population,round((total_cases/population)*100,3) AS TotalCasesPercentage
from PortfolioProject.dbo.CovidDeath
where location like '%india%'
order by 1,2;
--Looking for the highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount,round(MAX((total_cases/population))*100,3) AS MaxCasesPercentage
from PortfolioProject.dbo.CovidDeath
--where location like '%india%'
Group By location,population
order by 3 desc;
--Showing Countries with Highest Death Count per population
--Removing the irregularites from the table(such as world, high income)
select location,population,MAX(cast(total_deaths as int)) as HighestDeathCount,round(MAX((total_deaths/population))*100,3) AS MaxDeathPercentage
from PortfolioProject.dbo.CovidDeath
--where location like '%india%'
where continent is not null
Group By location,population
order by 3 desc;

--GLOBAL NUMBER

select sum(new_cases) as  total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeath
--where location like '%india%'
where continent is not null
--Group By date
order by 1,2;

--Looking Total Population vs Vaccination
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(CONVERT(float,vac.new_vaccinations)) OVER(PARTITION BY dth.location order by dth.location,dth.date) as TotalVaccineTakenUptoDate
from PortfolioProject.dbo.CovidDeath as dth
join PortfolioProject.dbo.CovidVaccination as vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2, 3;

--USE CTE Method 
with PopVsVac (Continent,Location,Date,Population,New_vaccinations,TotalVaccineTakenUptoDate)
as
(
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dth.location order by dth.location,dth.date) as TotalVaccineTakenUptoDate
from PortfolioProject.dbo.CovidDeath as dth
join PortfolioProject.dbo.CovidVaccination as vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 2, 3
)
select *, (TotalVaccineTakenUptoDate/Population)*100 as VaccinationPercent
from PopVsVac
where Location LIKE'%india%'

--Temp Table Method
drop table if EXISTS #PopulationVsVaccination
Create Table #PopulationVsVaccination (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	TotalVaccineTakenUptoDate numeric
)

Insert into #PopulationVsVaccination
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(CONVERT(numeric,vac.new_vaccinations)) OVER(PARTITION BY dth.location order by dth.location,dth.date) as TotalVaccineTakenUptoDate
from PortfolioProject.dbo.CovidDeath as dth
join PortfolioProject.dbo.CovidVaccination as vac
	on dth.location = vac.location
	and dth.date = vac.date
--where dth.continent is not null
--order by 2, 3


--Creating View for later Viz
Create View PercentPopulaionVaccinated as 
(select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
sum(CONVERT(numeric,vac.new_vaccinations)) OVER(PARTITION BY dth.location order by dth.location,dth.date) as TotalVaccineTakenUptoDate
from PortfolioProject.dbo.CovidDeath as dth
join PortfolioProject.dbo.CovidVaccination as vac
	on dth.location = vac.location
	and dth.date = vac.date)

select * 
from PercentPopulaionVaccinated