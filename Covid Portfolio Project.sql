/****** Script for SelectTopNRows command from SSMS  ******/


--Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
select location,date,total_cases, new_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage
from CovidDeaths
where continent is not NULL
order by 1,2;


--Looking at Total cases vs Total Population
-- Shows what percentage of people got Covid
select location,date,total_cases, population, round((total_cases/population)*100,2) as PercentagePopulationInfected--Covid_Infected_Percentage
from CovidDeaths
where continent is not NULL
order by 1,2;


--Looking at countries with Highest Infection Rate Compared to Population
select location, population,max(total_cases) as HighestInfectionCount, round(max((total_cases/population))*100,2) as PercentagePopulationInfected
from CovidDeaths
where continent is not NULL
group by location, population
order by PercentagePopulationInfected desc;


-- Showing Countries with highest death count per polupation
select location, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc;


-- Showing Continent by Highest Death Count per population
select continent, max(total_deaths) as Max_Count_Death
from CovidDeaths
where continent is not NULl
group by continent 
order by Max_Count_Death desc;


--Global Numbers
select sum(new_cases) as New_Cases, sum(new_deaths) as New_Deaths, round((sum(new_deaths)/NULLIF(sum(new_cases),0))*100,2) as DeathPercentage
from CovidDeaths
where continent is not NULl
order by 1,2;


---------------Looking at Total Population VS Vaccinations	
select CD.continent, CD.location, CD.date,CD.population, CV.new_vaccinations, 
	sum(convert(bigint,CV.new_vaccinations)) over(partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
from CovidDeaths as CD join CovidVacinations as CV on CD.location = CV.location and CV.date = CD.date
where CD.continent is not null
order by 2,3;


---------------With CTE
with PopvsVac as(
select
	CD.continent,CD.location,
	CD.date,CD.population,CV.new_vaccinations,
	sum(convert(bigint,CV.new_vaccinations)) over(partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
from CovidDeaths as CD join CovidVacinations as CV on CD.location = CV.location and CV.date = CD.date
where CD.continent is not null
)
select *, (Rolling_People_Vaccinated/population)*100 as Rate_Rolling_People_Vaccinated
from PopvsVac


-------------Temp Table--------------
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #PercentagePopulationVaccinated
select
	CD.continent,CD.location,
	CD.date,CD.population,CV.new_vaccinations,
	sum(convert(bigint,CV.new_vaccinations)) over(partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
from CovidDeaths as CD join CovidVacinations as CV on CD.location = CV.location and CV.date = CD.date


select *, (Rolling_People_Vaccinated/population)*100 as Rate_Rolling_People_Vaccinated
from #PercentagePopulationVaccinated


---------Creating View to store data for later  visualizations

create view PercentagePopulationVaccinated as 
select
	CD.continent,CD.location,
	CD.date,CD.population,CV.new_vaccinations,
	sum(convert(bigint,CV.new_vaccinations)) over(partition by CD.location order by CD.location, CD.date) as Rolling_People_Vaccinated
from CovidDeaths as CD join CovidVacinations as CV on CD.location = CV.location and CV.date = CD.date
where CD.continent is not null;

select * 
from PercentagePopulationVaccinated
